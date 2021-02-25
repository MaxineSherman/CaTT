%CATT_Z2PL Combine z-scores from all participants' individual tests
%using Stouffer's method to get a group-level z-score and a group-level
%pvalue
%
%   usage: [P, Z] = catt_z2p( group );
%
%      OR  [P, Z] = catt_z2p( z );
%
%    INPUTS:
%     group         - Your group catt structure
%                         This has the form group(1).catt,
%                         group(2).catt,... group(n).intero
%                         for your n participants' data.  
%                    Use this for calculating a group Z value and group P
%                    value from the combined, participant-wise z-values
%                    contained in the structure 'group'.
%
%    z            - A single z-score, or a set of z-scores arranged in a
%                   vector. Enter this to get a p-value and z-score. If one
%                   single z-score is entered, then the function will
%                   return a single p-value for that z-score, and Z will be
%                   equal to z. If a set of z-scores is entered, then P and
%                   Z will be the combined, group-level p-value and
%                   z-score.
%                  
%     .
%
%    OUTPUTS:
%       P           - The p-value, either for a single z-score or for the
%                     group
%       Z           - The combined group-level z-score
%
% ========================================================================
%  CaTT TOOLBOX v1.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% ========================================================================

function [Z , P] = catt_z2p( X )

%% Are we working on a single or set of z-scores?
if ~isstruct(X) & ismatrix(X)
    
    if numel(X) == 1 % convert a single z-score to a p-value
        Z = X;
        
    elseif numel(X) > 1 % we're in a group
        Z = nansum(X)/sqrt(numel(X));
    end
    
elseif isstruct(X) % we've got the group structure
    for i = 1:numel(X)
        z(i) = X(i).catt.stats.zscore;
    end
    Z = nansum(z)/sqrt(numel(z));
    
else error('Error in <strong>catt_zval2pval</strong>: unknown input. Please check the documentation for the function');
end

%% get two-tailed p-value
P = 2*(1 - normcdf( abs(Z) ));

end
    
    