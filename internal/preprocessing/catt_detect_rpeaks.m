%CATT_DETECT_RPEAKS detect r-peaks
%   usage: catt = catt_detect_rpeaks(catt)
%
%  This function detects r-peaks and expresses them both as ECG samples
%  (catt.tlock.rPeaks_idx) and in msecs (catt.tlock.rPeaks_msec)
%
%  R-peak detection is performed using the method in Manikandan &
%  Sabarimalai (2012).
%  This function calls on the authors' code, which can be found here:
%  https://github.com/hongzuL/A-novel-method-for-detecting-R-peaks-in-electrocardiogram-signal
%  Manikandan, M. Sabarimalai, and K. P. Soman. "A novel method for detecting R-peaks in electrocardiogram (ECG) signal." Biomedical Signal Processing and Control 7.2 (2012): 118-128.
%
% ========================================================================
%  CaTT TOOLBOX v2
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  07/08/2021
% ========================================================================

function catt = catt_detect_rpeaks( catt )

% get opts
global catt_opts

% confirm BP filter based on sampling frequency
catt_opts.BP_filter = chebyshevI_bandpass(catt_opts.fs);

% detect r-peaks
[~, rPeakTimes] = SEHT(catt.ECG.processed,catt_opts.fs,catt_opts.BP_filter);

% Load in the r-peak data into the field tlock (i.e. timelocked)
catt.tlock.rPeaks_idx       = rPeakTimes;
catt.tlock.rPeaks_msec      = catt.ECG.times(rPeakTimes);

end


