%INTERO_BOOTSTRAP_FCN permutation test for custom function
%
%   usage: [pval, stats] = intero_bootstrap_fcn( function, inputs, [nloops])
%
%    INPUTS:
%     function   - String. The name of the test function you want to bootstrap,
%                  e.g. 'ttest2' for matlab's between-subjects t-test
%     inputs     - A cell array containing the inputs for the function.
%                  For example, for ttest2 you need group 1 data (G1, in an
%                  nx1 vector) and group 2 data (F2, in an mx1 vector). So,
%                  inputs here would be {G1,G2}.
%
%     Optional inputs
%      npermuations - The number of permutations you want to use. Minimum 100.
%                     Default is 10,000
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
%        1. To bootstrap the circstat function circ_rtest, which has only
%        one input - a vector of angles (in radians) and using 20,000
%        permutations you would call:
%        [pval, stats] = intero_bootstrap( 'circ_rtest', {my_angles}, 20000 )
%
% ========================================================================
%  INTERO TOOLBOX v1.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% ========================================================================

function [pval,stats] = intero_bootstrap_fcn( fcn, inputs, nloops )

%% ========================================================================
%  Set defaults
%  ========================================================================

%% fix rng 
rng(11);

%% enter nloops
if nargin < 3 | isempty(nloops)
    stats.opt.nloops    = 10000;
end

%% enter function
eval(['stats.opt.fcn = @' fcn ';']);

%% ========================================================================
%  Get empirical difference & boostrap
%  ========================================================================

X.stat = stats.opt.fcn(G1,G2)
switch numel(inputs)
    
    case 1
        for i = 1:stats.opt.nloops
            
            % shuffle data
            dat = [group1;group2]; % pool the data
            n1  = numel(group1); n2 = numel(group2); % get n for each group
            k1  = randsample(1:numel(dat),n1); % get datapoints for shuffled group 1
            k2  = setdiff(1:numel(dat),k1); % datapoints for shuffled group 2 are those not in group 1
            G1  = dat(k1); G2 = dat(k2);
            
            % compute statistic
            stats.null(i,1)   = stats.opt.fcn(G1,G2);
            
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







