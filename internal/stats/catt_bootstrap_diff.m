%CATT_BOOTSTRAP_DIFF permutation test of difference
%   usage: [pval, stats] = catt_bootstrap_diff(group1, group2, design, [optional])
%
%    INPUTS:
%     group1     - an n x 1 vector of data for group/condition 1
%     group2     - an m x 1 vector of data for group/condition 2
%     design     - 'within' or 'between'. If 'within', you should have the
%                  same number of data points in group1 and group2.
%
%     Optional inputs
%      npermuations - The number of permutations you want to use. Minimum 100.
%                     Default is 10,000.
%      method       - How to compute your differences, 'mean' or 'median'
%                     Default is 'mean'.
%      data_type    - Whether your data are linear (non-circular) or
%                     circular (e.g. angles), use 'linear' or 'circular'.
%                     Circular data should be expressed in radians.
%                     Default it 'linear'.
%      direction    - For a two-tailed test write 'twotailed'
%                     For a one-tailed test on group1>group2, write 'higher'
%                     For a one-tailed test on group1<group2, write 'lower'
%                     Default is two-tailed.
%
%    OUTPUTS:
%       pval        - pvalue for your test
%       stats       - a structure containing the parameters for the
%                     permutation test, the p-value, difference score, and if
%                     appropriate, the distribution of t-statistics over all
%                     permutations.
%                     The difference score will be group1 - group2
%                     (either the circular or linear subtraction, depending on your
%                     inputs)
%
%      Examples:
%
%        1. For a default test of difference on means for a between-subjects
%        design (e.g. patients vs controls), call:
%        [pval, stats] = catt_bootstrap_diff( patients, controls, 'between')
%
%        2. If you predict patients > controls and want a one-tailed test, call:
%        [pval, stats] = catt_bootstrap_diff( patients, controls, 'between', 'higher')
%
%        3. For a within-subjects circular test of difference based on medians,
%           e.g. testing for differences in median cardiac time (expressed 
%           in radians) for incorrect vs correct responses, call:
%          [pval, stats] = catt_bootstrap_diff( correct,...
%                                               incorrect, ...
%                                               'within', ...
%                                               'median', ...
%                                               'circular');
% ========================================================================
%  CaTT TOOLBOX v1.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% ========================================================================

function [pval,stats] = catt_bootstrap_diff(group1, group2, design, varargin )

%% ========================================================================
%  Set defaults
%  ========================================================================

%% fix rng 
rng(11);

stats.opt.method    = 'mean';
stats.opt.nloops    = 10000;
stats.opt.data_type = 'linear';
stats.opt.direction = 'twotailed';

%% ========================================================================
%  Check required inputs
%  ========================================================================

% check group1 & group2 have at least 3 data points
assert(numel(group1)>2,'Error in <strong>catt_bootstrap_diff</strong>: need at least 3 datapoints in group 1');
assert(numel(group2)>2,'Error in <strong>catt_bootstrap_diff</strong>: need at least 3 datapoints in group 2');

% check group1 and group2 are nx1 or 1xn
assert(min(size(group1))==1,'Error in <strong>catt_bootstrap_diff</strong>: group1 should be 1xn or nx1');
assert(min(size(group1))==1,'Error in <strong>catt_bootstrap_diff</strong>: group2 should be 1xn or nx1');

% reshape group1 and group2
group1 = reshape(group1, numel(group1), 1);
group2 = reshape(group2, numel(group2), 1);

% check the design input is within or between, and if within, that there's
% the same number of datapoints in group1 and group2.
if strcmpi(design,'between')
elseif strcmpi(design,'within')
    assert(numel(group1)==numel(group2),'Error in <strong>catt_bootstrap_diff</strong>: group1 and group2 should have the same number of datapoints for a Within-subjects design.');
else
    error('Error in <strong>catt_bootstrap_diff</strong>: unknown design. Please enter within or between');
end
stats.opt.design    = design;

%% ========================================================================
%  Interpret optional inputs
%  ========================================================================

for i = 1:numel(varargin)
    
    if strcmpi(varargin{i},'median');   stats.opt.method    = 'median';   end
    if strcmpi(varargin{i},'circular'); stats.opt.data_type = 'circular'; end
    if strcmpi(varargin{i},'higher');   stats.opt.direction = 'higher';   end
    if strcmpi(varargin{i},'lower');    stats.opt.direction = 'lower';    end
    
    % check for minimum 100 permutations
    if isnumeric(varargin{i})
        stats.opt.nloops = varargin{i};
        assert( stats.opt.nloops>=100, 'Error in <strong>catt_bootstrap_diff</strong>: use at least 100 permutations');
    end
    
    % check for nonsense string inputs
    if ischar(varargin{i}) & ...
            ~strcmpi(varargin{i},'circular') & ...
            ~strcmpi(varargin{i},'linear') & ...
            ~strcmpi(varargin{i},'mean') & ...
            ~strcmpi(varargin{i},'median') & ...
            ~strcmpi(varargin{i},'twotailed') & ...
            ~strcmpi(varargin{i},'higher') & ...
            ~strcmpi(varargin{i},'lower')
        
        warning(['Warning in <strong>catt_bootstrap_diff<\strong>: input ' varargin{i} ' is unknown. Ignoring...']);
        
    end
end

%% ========================================================================
%  If we're using circular data, wrap to 2pi.
%  Also, check it's in radians and not in degrees.
%  ========================================================================

if strcmpi(stats.opt.data_type,'circular')
    
    % check we're in radians, not degrees [this is a weak test!!]
    if max( abs(group1) ) > 12 | max( abs(group2) ) > 12
        warning('Warning in <strong>catt_bootstrap_diff<\strong>: Your data look like degrees, not radians. Please check & rerun if neccessary...');
    end
    
    % wrap data to 2pi
    group1 = wrapTo2Pi( group1 );
    group2 = wrapTo2Pi( group2 );
    
end

%% ========================================================================
%  Set difference function stats.opt.diff_fcn, based on circular vs linear
%  differences and mean vs median
%  ========================================================================

switch stats.opt.method
    
    %% mean difference
    case 'mean'
        switch stats.opt.data_type
            
            case 'linear'; stats.opt.diff_fcn = @(g1,g2) mean(g1)-mean(g2);
            
            case 'circular'
                switch stats.opt.design
                    case 'within';  stats.opt.diff_fcn = @(g1,g2) circ_mean( circ_dist(g1,g2) );
                    case 'between'; stats.opt.diff_fcn = @(g1,g2) circ_dist(circ_mean(g1),circ_mean(g2));
                end
        end
    
    %% median difference
    case 'median'
        
        switch stats.opt.data_type
            
            case 'linear'; stats.opt.diff_fcn = @(g1,g2) median(g1)-median(g2);
            
            case 'circular'
                switch stats.opt.design
                    case 'within';  stats.opt.diff_fcn = @(g1,g2) circ_median( circ_dist(g1,g2) );
                    case 'between'; stats.opt.diff_fcn = @(g1,g2)  circ_dist(circ_median(g1),circ_median(g2));
                end
        end
end

%% ========================================================================
%  Get empirical difference & boostrap
%  ========================================================================

stats.difference = stats.opt.diff_fcn(group1,group2);

switch stats.opt.design
    
    case 'between'
        for i = 1:stats.opt.nloops
            
            % shuffle data
            dat = [group1;group2]; % pool the data
            n1  = numel(group1); n2 = numel(group2); % get n for each group
            k1  = randsample(1:numel(dat),n1); % get datapoints for shuffled group 1
            k2  = setdiff(1:numel(dat),k1); % datapoints for shuffled group 2 are those not in group 1
            G1  = dat(k1); G2 = dat(k2);
            
            % compute difference
            stats.null(i,1)   = stats.opt.diff_fcn(G1,G2);
            
        end
        
    case 'within'
        for i = 1:stats.opt.nloops
            
            % shuffle data
            order = rand(numel(group1),1) < 0.5; % for each participant randomly flip the condition labels
            G1    = group1; G1(order==1) = group2(order==1);
            G2    = group2; G2(order==1) = group1(order==1);
            
            % compute difference
            stats.null(i,1) = stats.opt.diff_fcn(G1,G2);
            
        end
end

%% get pvalue
switch stats.opt.direction
    case 'twotailed'
        pval = sum(abs(stats.null) >= abs(stats.difference))./stats.opt.nloops;
    case 'higher'
        pval = sum( stats.null >= stats.difference )./stats.opt.nloops;
    case 'lower'
        pval = sum( stats.null <= stats.difference )./stats.opt.nloops;
end


end







