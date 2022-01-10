%CATT_ESTIMATE_TIMES estimate timestamps from ECG data and sample rate
%   usage: times_ms = catt_estimate_srate( ecg, srate )
%
%  INPUTS:
%    ecg            your raw ECG data
%    srate          sample rate, in hz
%
%  OUTPUTS:
%    times_ms       estimated timestamps, in msecs
%
% ========================================================================
%  CaTT TOOLBOX v2
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  07/08/2021
% ========================================================================

function times_ms = catt_estimate_times( ecg, srate )

interval      = 1000/srate;
times_ms      = interval*[1:numel(ecg)];

end
