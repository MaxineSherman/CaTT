%CATT_IBI2BPM convert BPM to IBI (in msec)
%   usage: ibi = catt_bpm2ibi(bpm)
%
%   INPUTS:
%      bpm          - beats per minute. This can be a number, or a vector
%      with n elements.
%
% OUTPUTS:
%      ibi          - interbeat interval (in msec). Where multiple BPMs
%      have been passed to the function, the user will get back one BPM for
%      each IBI.
% ========================================================================
%  CaTT TOOLBOX v2.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  08/08/2021
% ========================================================================

function ibi = catt_bpm2ibi(bpm)

% do we have more than 1 bpm here?
if numel(bpm)>1
    bpm = reshape(bpm,numel(bpm),1);
    bpm = nanmean(bpm);
end

% convert bpm to ibi
ibi = 1000.*60./bpm;

end