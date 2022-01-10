%CATT_HEARTBEAT_DETECTION detect rpeak, tpeak and end of t-wave.
%   usage: catt = catt_heartbeat_detection(catt)
%
%  This function does the following:
%    1. detects r-peak
%    2. detects t-wave peak
%    3. detects t-wave end
%    4. calculates RT interval
%
%  See functions catt_detect_rpeaks and catt_detect_t for more information.
%
% ========================================================================
%  CaTT TOOLBOX v2
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  21/06/2021
% ========================================================================

function catt = catt_heartbeat_detection(catt)

catt = catt_detect_rpeaks(catt);
catt = catt_detect_t(catt);

end