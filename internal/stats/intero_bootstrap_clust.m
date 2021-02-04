%INTERO_BOOTSTRAP_CLUST permutation test for testing uniformity of angles.
%IThe question here is do we see *more* clustering when locking to the
%correct cardiac time than when shuffling the cardiac times.
%
%   usage: [pval, stats, intero] = intero_bootstrap_clust(intero, [test],[optional])
%
%    INPUTS:
%     intero            - your intero structure
%               
%     Optional inputs
%  
%     test          - a string describing the test of circular
%                     uniformity you want to use. 
%                     Options are:
%                          - 'rayleigh' [default] - Rayleigh's test.
%                             Assumes a Von Mises distribution. Works best
%                             when distribution of angles is unimodal (or
%                             uniform).
%                          - 'omnibus' - Omnibus test for circular
%                             uniformity
%                             No distributional assumptions.   
%
%      npermuations -  The number of permutations you want to use. Minimum 100.
%                      Default is 10,000.
%
%    OUTPUTS:
%       pval        - pvalue for your test
%       stats       - a structure containing the parameters for the
%                     permutation test, the p-value and association statistic (r or rho)
%       intero      - load the output back into your intero structure. This
%                     is important if you want to run group analyses later on 
%                     
%      Example:
%        1. To test whether people are more likely to give a motor response
%           at some point in the cardiac cycle, first wrap your onsets to the
%           cardiac cycle by calling intero_wrap2heart. To run your analysis
%           using the omnibus test and 5000 permutations, call:
%           [pval, stats, intero] = intero_bootstrap_clust( intero, 'omnibus', 5000)
%
%        2. To perform this for all participants, you would do:
%           for subj = 1:n
%                 [pval(subj), stats{subj}, group(subj).intero] =
%                 intero_bootstrap_clust( group(subj).intero, 'omnibus', 5000);
%           end
%
% ========================================================================
%  INTERO TOOLBOX v1.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% ========================================================================

function [pval, stats, intero] = intero_bootstrap_clust(intero, varargin)

%% ========================================================================
%  Set defaults
%  ========================================================================
global intero_opts
stats.opt.nloops    = 10000;
stats.opt.test      = 'rayleigh';

% extract relevant info from the structure
IBIs                = intero.IBI;
onsets              = intero.onsets;

%% ========================================================================
%  Check required inputs
%  ========================================================================

% check IBI & onsets have at least 5 data points
assert(numel(IBIs)>2,'Error in <strong>intero_bootstrap_clust</strong>: need at least 5 IBIs');
assert(numel(onsets)>2,'Error in <strong>intero_bootstrap_clust</strong>: need at least 5 onsets');

% check IBIs & onsets is nx1 or 1xn
assert(min(size(IBIs))==1,'Error in <strong>intero_bootstrap_clust</strong>: intero.IBI should be 1xn or nx1');
assert(min(size(onsets))==1,'Error in <strong>intero_bootstrap_clust</strong>: intero.onsets should be 1xn or nx1');

% reshape IBIs and onsets
IBIs   = reshape(IBIs, numel(IBIs), 1);
onsets = reshape(onsets, numel(onsets), 1);

%% ========================================================================
%  Interpret optional inputs
%  ========================================================================

for i = 1:numel(varargin)
    if strcmpi(varargin{i},'rao') 
        stats.opt.test = 'rao';
    end
    if strcmpi(varargin{i},'rayleigh') 
        stats.opt.test = 'rayleigh';
    end
    if isnumeric(varargin{i})
        stats.opt.nloops = varargin{i};
        assert( stats.opt.nloops>=100, 'Error in <strong>intero_bootstrap</strong>: use at least 100 permutations');
    end
    
    % check for nonsense
    if ischar(varargin{i}) & ...
            ~strcmpi(varargin{i},'rao') & ...
            ~strcmpi(varargin{i},'rayleigh');
            
        warning(['Warning in <strong>intero_bootstrap_clust<\strong>: input ' varargin{i} ' is unknown. Ignoring...']);
        
    end
end


%% ========================================================================
%  Set association function stats.opt.r_fcn, based on test
%  ========================================================================

if strcmpi(stats.opt.test,'rao')
    stats.opt.r_fcn = @(x) circ_raotest(x);
    
elseif strcmpi(stats.opt.test,'rayleigh') 
    stats.opt.r_fcn = @(x) circ_rtest(x);
 
end

%% ========================================================================
%  Get empirical associations & boostrap
%  ========================================================================

%% first, wrap to heart and calculate true test stat
thetas = intero_wrap2heart( onsets, IBIs );
[~,stats.test_stat] = stats.opt.r_fcn(thetas);

for i = 1:stats.opt.nloops
    
    % Now, wrap behaviour to shuffled IBIs
    V{i}     = intero_wrap2heart( onsets, Shuffle(IBIs) );
    
    % run test
    [~,stats.null(i,1)] = stats.opt.r_fcn(V{i});
    
 
end

% get the pvalue
pval = sum( stats.null >= stats.test_stat )./stats.opt.nloops;

 % get the zscore, for combining across participants
stats.zscore = (stats.test_stat - mean(stats.null))./std(stats.null);
    
% finally, load everything into intero
intero.stats = stats;
intero.stats.pval = pval;

% also, log what we've wrapped to
intero.stats.opt.wrap2 = intero_opts.wrap2;
end







