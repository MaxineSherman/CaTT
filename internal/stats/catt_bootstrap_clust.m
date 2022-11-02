%CATT_BOOTSTRAP_CLUST permutation test for testing uniformity of angles.
%IThe question here is do we see *more* clustering when locking to the
%correct cardiac time than when shuffling the cardiac times.
%
%   usage: [pval, stats, catt] = catt_bootstrap_clust(catt, [test],[optional])
%
%    INPUTS:
%     catt            - your catt structure
%
%     Optional inputs
%
%     test          - a string describing the test of circular
%                     uniformity you want to use.
%                     Options are:
%                          - 'rayleigh' - Rayleigh's test.
%                             Assumes a Von Mises distribution. Works best
%                             when distribution of angles is unimodal (or
%                             uniform).
%                              Higher test statistics -> less uniform
%                          - 'rao' - Test for circular uniformity
%                              with no distributional assumptions.
%                              Higher test statistics -> less uniform
%                          - 'otest' [default] - Omnibus test. Works well
%                          on multimodal data. Permutation test behaves
%                          well with this.
%                          Lower test statistics -> less uniform
%
%      npermuations -  The number of permutations you want to use. Minimum 100.
%                      Default is 10,000.
%
%    OUTPUTS:
%       pval        - pvalue for your test
%       stats       - a structure containing the parameters for the
%                     permutation test, the p-value and association statistic (r or rho)
%       catt        - load the output back into your catt structure. This
%                     is important if you want to run group analyses later on
%
%      Example:
%        1. To test whether people are more likely to give a motor response
%           at some point in the cardiac cycle, first wrap your onsets to the
%           cardiac cycle by calling intero_wrap2heart. To run your analysis
%           using the rayleigh test and 5000 permutations, call:
%           [pval, stats, catt] = catt_bootstrap_clust( catt, 'rayleigh', 5000)
%
%        2. To perform this for all participants, you would do:
%           for subj = 1:n
%                 [pval(subj), stats{subj}, group(subj).catt] =
%                 catt_bootstrap_clust( group(subj).catt, 'rayleigh', 5000);
%           end
%
% % Update: v2.1, 2022/04/21
%     - pseudo-shuffling is now performed by catt_shuffle
%     - catt_shuffle requires a rehuffling of catt.qt - this is now done
%     too
% ========================================================================
%  CaTT TOOLBOX v2.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  08/08/2021
% ========================================================================

function [pval, stats, catt] = catt_bootstrap_clust(catt, varargin)

%% ========================================================================
%  Set defaults
%  ========================================================================
global catt_opts
stats.opt.nloops    = 10000;
stats.opt.test      = 'otest';
t0                  = tic;

% extract relevant info from the structure
IBIs                = [catt.RR.IBI];
onsets              = [catt.RR.onset];

% bin IBIs without an onset
IBIs                = IBIs( ~isnan(onsets) );
onsets              = onsets( ~isnan(onsets) );

%% ========================================================================
%  Check required inputs
%  ========================================================================

% check IBI & onsets have at least 5 data points
assert(numel(IBIs)>2,'Error in <strong>catt_bootstrap_clust</strong>: need at least 5 IBIs');
assert(numel(onsets)>2,'Error in <strong>catt_bootstrap_clust</strong>: need at least 5 onsets');

% check IBIs & onsets is nx1 or 1xn
assert(min(size(IBIs))==1,'Error in <strong>catt_bootstrap_clust</strong>: intero.IBI should be 1xn or nx1');
assert(min(size(onsets))==1,'Error in <strong>catt_bootstrap_clust</strong>: intero.onsets should be 1xn or nx1');

% reshape IBIs and onsets
IBIs   = reshape(IBIs, numel(IBIs), 1);
onsets = reshape(onsets, numel(onsets), 1);

%% ========================================================================
%  Interpret optional inputs
%  ========================================================================

for i = 1:numel(varargin)
    if strcmpi(varargin{i},'otest')
        stats.opt.test = 'otest';
    end
    if strcmpi(varargin{i},'rao')
        stats.opt.test = 'rao';
    end
    if strcmpi(varargin{i},'rayleigh')
        stats.opt.test = 'rayleigh';
    end
    if isnumeric(varargin{i})
        stats.opt.nloops = varargin{i};
        assert( stats.opt.nloops>=100, 'Error in <strong>catt_bootstrap_clust</strong>: use at least 100 permutations');
    end

    % check for nonsense
    if ischar(varargin{i}) & ...
            ~strcmpi(varargin{i},'rao') & ...
            ~strcmpi(varargin{i},'rayleigh') & ...
            ~strcmpi(varargin{i},'otest');

        warning(['Warning in <strong>catt_bootstrap_clust<\strong>: input ' varargin{i} ' is unknown. Ignoring...']);

    end
end


%% ========================================================================
%  Set association function stats.opt.r_fcn, based on test
%  ========================================================================

if strcmpi(stats.opt.test,'rao')
    stats.opt.r_fcn = @(x) circ_raotest(x);

elseif strcmpi(stats.opt.test,'rayleigh')
    stats.opt.r_fcn = @(x) circ_rtest(x);

elseif strcmpi(stats.opt.test,'otest')
    stats.opt.r_fcn = @(x) circ_otest(x);

end

%% ========================================================================
%  Get empirical associations & boostrap
%  ========================================================================

%% first, wrap to heart and calculate true test stat
catt.wrapped = catt_wrap2heart( onsets, IBIs, catt.qt );
[~,stats.test_stat] = stats.opt.r_fcn(catt.wrapped.onsets_rad);

for i = 1:stats.opt.nloops

    % shuffle & rewrap
    [sIBI, sOnset] = catt_shuffle(IBIs, onsets);

    V = catt_wrap2heart(sOnset, sIBI, catt.qt);
    V = wrapTo2Pi(V.onsets_rad);

    % run test
    [~,stats.null(i,1)] = stats.opt.r_fcn(V);

end

% get the pvalue
pval = sum( stats.null >= stats.test_stat )./stats.opt.nloops;

% get the zscore, for combining across participants
if strcmpi(stats.opt.test,'otest') % lower is better
    stats.zscore = -(stats.test_stat - mean(stats.null))./std(stats.null);
else % higher is better
    stats.zscore = (stats.test_stat - mean(stats.null))./std(stats.null);
end

% finally, load everything into catt
catt.stats = stats;
catt.stats.pval = pval;

% also, log what we've wrapped to
catt.stats.opt.wrap2 = catt_opts.wrap2;
catt.stats.opt.qt    = catt.qt;
catt.stats.runtime   = toc(t0);
toc(t0);
end







