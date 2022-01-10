%CATT_IBI2BPM convert IBI (in msec) to BPM
%   usage: bpm = catt_ibi2bpm(ibi)
%
%   INPUTS:
%      ibi          - your IBIs, or a single mean IBI. If you enter a
%                     vector of IBIs then the function will take a mean
%                     and calculate BPM
%                     from that.
%
% OUTPUTS:
%      bpm          - beats per minute
% ========================================================================
%  CaTT TOOLBOX v2.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  08/08/2021
% ========================================================================

function bpm = catt_ibi2bpm(ibi)

% do we have more than 1 ibi here?
if numel(ibi)>1
    ibi = reshape(ibi,numel(ibi),1);
    ibi = nanmean(ibi);
end

% convert ibi to bpm
bpm = 1000*60/ibi;

end