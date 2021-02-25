%CATT_BOOTSTRAP_CORR permutation test of association for linear or
%circular data (in radians)
%
%   usage: [pval, stats] = catt_bootstrap_corr(DV1, type1, DV2, type2, [optional])
%
%    INPUTS:
%     DV1        - an n x 1 vector of data for dependent variable 1
%     type1      - 'circular' (if DV1 is angular data) or 'linear' (otherwise)
%     DV2        - an n x 1 vector of data for dependent variable 2
%     type2      - 'circular' (if DV2 is angular data) or 'linear' (otherwise)
%
%     If you use circular data, these should be in radians, not degrees.
%
%     Optional inputs
%      npermuations -  The number of permutations you want to use. Minimum 100.
%                      Default is 10,000.
%      method       - 'pearson' or 'spearman' [default is 'spearman']
%                      Note that this only applies if both DV1 and DV1 are
%                      linear.
%                      If they are not, 'method' will be ignored.
%      direction    -  For a two-tailed test write 'twotailed'
%                      For a one-tailed test for a positive association, write 'higher'
%                      For a one-tailed test for a negative association, write 'lower'
%                      Default is two-tailed.
%
%    OUTPUTS:
%       pval        - pvalue for your test
%       stats       - a structure containing the parameters for the
%                     permutation test, the p-value and association statistic (r or rho)
%
%      Example:
%        1. For a pearsons correlation between age and memory score with 5000
%        permutations, call:
%        [pval, stats] = catt_bootstrap_corr( age, 'linear, memory, 'linear, 5000, 'pearson')
%
%        2. For a circular-linear correlation between the phase of the
%           cardiac cycle at stimulus onset (in radians) and memory score,
%           call:
%           [pval, stats] = catt_bootstrap_corr( cardiac, 'circular',
%           memory, 'linear' );
% ========================================================================
%  CaTT TOOLBOX v1.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% ========================================================================

function [pval,stats] = catt_bootstrap_corr(DV1, type1, DV2, type2, varargin)

%% ========================================================================
%  Set defaults
%  ========================================================================

stats.opt.nloops    = 10000;
stats.opt.test_type = 'spearman';
stats.opt.direction = 'twotailed';

%% ========================================================================
%  Check required inputs
%  ========================================================================

% check group1 & group2 have at least 3 data points
assert(numel(DV1)>2,'Error in <strong>catt_bootstrap_corr</strong>: need at least 3 datapoints in DV1');
assert(numel(DV2)>2,'Error in <strong>catt_bootstrap_corr</strong>: need at least 3 datapoints in DV2');

% check DV1 and DV2 are nx1 or 1xn
assert(min(size(DV1))==1,'Error in <strong>catt_bootstrap_corr</strong>: DV1 should be 1xn or nx1');
assert(min(size(DV2))==1,'Error in <strong>catt_bootstrap_corr</strong>: DV2 should be 1xn or nx1');

% check DV1 and DV2 are 'cicular' or 'linear'
assert(ismember(type1,{'circular','linear','Circular','Linear'}),'Error in <strong>catt_bootstrap_corr</strong>: type1 should be linear or circular');
assert(ismember(type2,{'circular','linear','Circular','Linear'}),'Error in <strong>catt_bootstrap_corr</strong>: type2 should be linear or cicular');

% reshape group1 and group2
DV1 = reshape(DV1, numel(DV1), 1);
DV2 = reshape(DV2, numel(DV2), 1);

% check there's the same number of datapoints in DV1 and DV2.
assert(numel(DV1)==numel(DV2),'Error in <strong>catt_bootstrap_corr</strong>: DV1 and DV2 should have the same number of datapoints.');

%% ========================================================================
%  Interpret optional inputs
%  ========================================================================

for i = 1:numel(varargin)
    if strcmpi(varargin{i},'pearson') | strcmpi(varargin{i},'pearsons')
        stats.opt.method = 'pearson';
    end
    if isnumeric(varargin{i})
        stats.opt.nloops = varargin{i};
        assert( stats.opt.nloops>=100, 'Error in <strong>catt_bootstrap_corr</strong>: use at least 100 permutations');
    end
    if strcmpi(varargin{i},'higher')
        stats.opt.direction = 'higher';
    end
    if strcmpi(varargin{i},'lower')
        stats.opt.direction = 'lower';
    end
    
    % check for nonsense
    if ischar(varargin{i}) & ...
            ~strcmpi(varargin{i},'spearman') & ...
            ~strcmpi(varargin{i},'spearmans') & ...
            ~strcmpi(varargin{i},'pearson') & ...
            ~strcmpi(varargin{i},'pearsons') & ...
            ~strcmpi(varargin{i},'twotailed') & ...
            ~strcmpi(varargin{i},'higher') & ...
            ~strcmpi(varargin{i},'lower')
        
        warning(['Warning in <strong>catt_bootstrap_corr<\strong>: input ' varargin{i} ' is unknown. Ignoring...']);
        
    end
end

%% ========================================================================
%  If we're using circular data, wrap to 2pi.
%  Also, check it's in radians and not in degrees.
%  Finally, if one variable is circular and the other is linear, make sure
%  circular is first
%  ========================================================================

str = 'Warning in <strong>catt_bootstrap_corr<\strong>: Your data look like degrees, not radians. Please check and re-run if neccessary';

% process DV1
if strcmpi(type1,'linear'); stats.opt.dv1 = 'linear';
else;                       stats.opt.dv1 = 'circular';
    
    % check we're in radians, not degrees
    if max( abs(DV1) ) > 10
        warning(str);
        stats.opt.warning{1} = ['DV1: ' str];
    end
    
    % wrap data to 2pi
    DV1 = wrapTo2Pi( DV1 );
end

% process dv2
if strcmpi(type2,'linear'); stats.opt.dv2 = 'linear';
else;                       stats.opt.dv2 = 'circular';
    
    % check we're in radians, not angles
    if max( abs(DV2) ) > 10
        warning(str);
        stats.opt.warning{2} = ['DV2: ' str];
    end
    
    % wrap data to 2pi
    DV2 = wrapTo2Pi( DV2 );
end

%% ========================================================================
%  Set association function stats.opt.r_fcn, based on circular vs linear
%  correlations
%  ========================================================================

if strcmpi(stats.opt.dv1,'circular') & strcmpi(stats.opt.dv2,'circular')
    stats.opt.r_fcn = @(x,y) circ_cc(x,y);
    
elseif strcmpi(stats.opt.dv1,'circular') & strcmpi(stats.opt.dv2,'linear')
    stats.opt.r_fcn = @(x,y) circ_cl(x,y);
    
elseif strcmpi(stats.opt.dv1,'linear') & strcmpi(stats.opt.dv2,'circular')
    stats.opt.r_fcn = @(x,y) circ_cl(y,x);
    
elseif strcmpi(stats.opt.dv1,'linear') & strcmpi(stats.opt.dv2,'linear')
    if strcmpi(stats.opt.test_type,'spearman')
        stats.opt.r_fcn = @(x,y) corr(y,x,'type','spearman');
    elseif strcmpi(stats.opt.test_type,'pearson')
        stats.opt.r_fcn = @(x,y) corr(y,x,'type','pearson');
    end
end

%% ========================================================================
%  Get empirical associations & boostrap
%  ========================================================================

stats.rho = stats.opt.r_fcn(DV1,DV2);

for i = 1:stats.opt.nloops
    
    % shuffle DV2
    dv2 = DV2(randsample(1:numel(DV2),numel(DV2)));
    
    % compute association
    stats.null(i,1) = stats.opt.r_fcn(DV1,dv2);
    
end

switch stats.opt.direction
    case 'twotailed'
        pval = sum(abs(stats.null) >= abs(stats.rho))./stats.opt.nloops;
    case 'higher'
        pval = sum( stats.null >= stats.rho )./stats.opt.nloops;
    case 'lower'
        pval = sum( stats.null <= stats.rho )./stats.opt.nloops;
end

end







