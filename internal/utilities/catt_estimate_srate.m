%CATT_ESTIMATE_SRATE estimate sample rate from ECG data and timestamp vector
%   usage: srate = catt_estimate_srate( ecg, times )
%
%  INPUTS:
%    ecg            your raw ECG data
%    times_ms       timstamps for ECG data, in msecs
%
%  OUTPUTS:
%    srate          sample rate, in hz
%
% ========================================================================
%  CaTT TOOLBOX v2
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  07/08/2021
% ========================================================================

function srate = catt_estimate_srate( ecg, times_ms )

nsamples      = numel(ecg);
total_time    = times_ms(end)-times_ms(1); % in msec
total_time    = total_time/1000; % in sec
srate         = round(nsamples/total_time);

end
