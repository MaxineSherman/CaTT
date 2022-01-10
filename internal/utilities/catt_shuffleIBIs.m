%CATT_SHUFFLE_IBIS shuffle IBIs in catt structure only if IBI has an onset
%   usage: catt = catt_shuffleIBIs( catt )
%
% ========================================================================
%  CaTT TOOLBOX v2
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  08/08/2021
% ========================================================================

function catt = catt_shuffleIBIs( catt )

% extract IBIs & shuffle
IBI = shuffle([catt.RR.IBI]);

% load back in [try to find a more efficient way to do this!]
for i = 1:numel(IBI)
    catt.RR(i).IBI = IBI(i);
end

end