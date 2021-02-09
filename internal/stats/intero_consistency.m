%INTERO_CONSISTENCY test for consistency across the circular distribution
%of cardiac-wrapped onsets across participants
%   usage: output = intero_consistency(intero_group, [nbins], [verbose])
%
%   INPUTS:
%     intero_group       - your structure containing each participant's intero
%                          structure. Takes the form intero_group(1).intero,
%                          intero_group(2).intero, etc.
%     nbins [optional]   - number of bins to use. Default is 8.
%     verbose [optional] - true or false. Print results in command line.
%                          Default is true
%
%    OUTPUTS:
%       output - a structure containing the following fields:
%                output.bins         -     Bin limits, in radians
%                output.bins_degrees -     As above, but in degrees
%                output.pvals        -     pvales for each bin
%                output.significant  -     Whether each pvalue is
%                                          significant after FDR correction
%                                          for multiple comparisons
%                output.proportions  -     Observed mean proportions for
%                                          each bin
%                output.difference   -     difference from expected proportion.
%                                          Negative/positive values mean that
%                                          there is a disproportionately low/high
%                                          number of onsets occuring in the bin.
%
% ========================================================================
%  INTERO TOOLBOX v1.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% ========================================================================

function output = intero_consistency(intero_group, nbins, verbose)

%% evaluate inputs
if nargin == 2; verbose = true; end
if nargin == 1; verbose = true; nbins = 8; end

%% get opts 
global intero_opts

%% define bins
bins = 0:(2*pi/nbins):2*pi;

%% loop participants
for i = 1:numel(intero_group)
    
    %% get thetas, wrapped to rpeak
    intero_opts.wrap2 = 'rpeak';
    thetas            = intero_wrap2heart( intero_group(i).intero.onsets,intero_group(i).intero.IBI );
    thetas            = wrapTo2Pi(thetas);
    
    %% bin data
    binned   = bin_data_by_Q( thetas, bins(2:end) );
    
    %% convert to proportions
    for j = 1:numel(unique(binned))
        props(i,j) = sum(binned==j)./numel(binned);
    end
    
end

%% for each section, calculate distance from expected value
expectation = repmat(1/nbins,numel(intero_group),1);

for i = 1:nbins
    [output.pval(i,1), stats] = intero_bootstrap_diff(props(:,i),expectation,'within','data_type','linear');
    output.difference(i,1)    = stats.difference;
end

%% get the proportions
output.proportions  = mean(props,1);

%% get bin limits for each bin
output.bins         = [bins(1:end-1)', bins(2:end)'];
output.bins_degrees = circ_rad2ang(output.bins);

%% is anything significant after correction?
output.FDR_threshold = fdr_correct(output.pval,0.05);

if ~isempty(output.FDR_threshold)
    output.significant   = output.pval <= output.FDR_threshold;
else
    output.significant   = zeros(size(output.pval));
end

%% finally, present results from each test if requested
if verbose
disp('====================================');
disp('Results from intero_consistency:');
disp('====================================');
for i = 1:nbins
disp(sprintf('Bin %d, %.2fpi-%.2fpi: difference = %.4f, pval = %.3f, significant = %d',...
             [i,output.bins(i,1)/pi,output.bins(i,2)/pi, output.difference(i),output.pval(i),output.significant(i)]));
end
disp('====================================');
end
end