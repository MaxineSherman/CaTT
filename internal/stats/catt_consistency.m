%CATT_CONSISTENCY test for consistency across the circular distribution
%of cardiac-wrapped onsets across participants
%   usage: output = catt_consistency(catt_group, [nbins], [verbose])
%
%   INPUTS:
%     catt_group        - your cell array containing each participant's catt
%                          structure. Takes the form catt_group{1},
%                          catt_group{2}, etc.
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
%                 output.diff_perc         as above, but expressed as a
%                                          percentage
%
% ========================================================================
%  CaTT TOOLBOX v2.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  08/08/2021
% =========================================================================

function output = catt_consistency(catt_group, nbins, verbose)

%% evaluate inputs
if nargin == 2; verbose = true; end
if nargin == 1; verbose = true; nbins = 8; end

%% get opts
global catt_opts

switch catt_opts.wrap2

    %% ============================================================
    %  Procedure for wrapping to r-peak
    %  ============================================================
    case 'rpeak'

        % define bins
        bins = 0:(2*pi/nbins):2*pi;

        % loop participants
        for i = 1:numel(catt_group)

            % get thetas & wrap
            wrapped            = catt_wrap2heart( catt_group{i} );
            thetas             = wrapped.onsets_rad;

            % bin data
            binned   = catt_bin_circ_data( thetas, nbins );

            % convert to proportions
            for j = 1:numel(unique(binned))
                props(i,j) = sum(binned==j)./numel(binned);
            end

        end

        %% ============================================================
        %  Procedure for wrapping to t-wave
        %  ============================================================
    case 'twav'

        % this will only work with even bin sizes
        assert( mod(nbins,2) == 0, 'When wrapping to t-wave you need an even number of bins.');

        % define bins
        bins = -pi:(2*pi/nbins):pi;

        % loop participants
        for i = 1:numel(catt_group)

            % get thetas & wrap
            wrapped            = catt_wrap2heart( catt_group{i} );
            thetas             = wrapped.onsets_rad;

            % bin data
            [binned_data,bin_centres,LL,UL] = catt_bin_circ_data(thetas,nbins);

            % convert to proportions, separately for pre and post t
            for j = 1:(nbins/2)
                props(i,j) = sum(binned_data==j)./sum(binned_data<(nbins/2 + 1));
            end
            for k = 1:(nbins/2)
                props(i,j+k) = sum(binned_data==(k+j))./sum(binned_data>(nbins/2));
            end
            props(i,:) = props(i,:)/2;
        end
end

%% ============================================================
% Run stats
%  ============================================================

% for each section, calculate distance from expected value
expectation = repmat(1/nbins,numel(catt_group),1);

for i = 1:nbins
    [output.pval(i,1), stats] = catt_bootstrap_diff(props(:,i),expectation,'within','linear');
    output.difference(i,1)    = stats.difference;
    output.diff_perc(i,1)     = 100*output.difference(i,1)/expectation(1);
end

% get the proportions
output.proportions  = mean(props,1);

% get bin limits for each bin
output.bins         = [bins(1:end-1)', bins(2:end)'];
output.bins_degrees = circ_rad2ang(output.bins);

% is anything significant after correction?
output.FDR_threshold = fdr_correct(output.pval,0.05);

if ~isempty(output.FDR_threshold)
    output.significant   = output.pval <= output.FDR_threshold;
else
    output.significant   = zeros(size(output.pval));
end

% finally, present results from each test if requested
if verbose
    disp('====================================');
    disp('Results from catt_consistency:');
    disp('====================================');
    for i = 1:nbins
        disp(sprintf('Bin %d, %.2fpi-%.2fpi: difference = %.2f percent, pval = %.3f, significant = %d',...
            [i,output.bins(i,1)/pi,output.bins(i,2)/pi, output.diff_perc(i),output.pval(i),output.significant(i)]));
    end
    disp('====================================');
end
end