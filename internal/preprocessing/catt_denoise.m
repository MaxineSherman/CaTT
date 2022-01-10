%CATT_detect_rpeaks detect r-peaks
%   usage: catt = catt_denoise(catt)
%
%  Pre-processing:
%
%  1. Remove baseline drift using a combination of 200ms and 600ms median
%  filters
%
%  2. Wavelet denoising
%
%  Inputs are taken from catt.ECG.raw
%  Denoised data are loaded into catt.ECG.processed
%
% ========================================================================
%  CaTT TOOLBOX v2
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  07/08/2021
% ========================================================================

function catt = catt_denoise( catt )

%% get opts
global catt_opts

%% denoise
% get the ecg data for the ith trial
ecg   = catt.ECG.raw;
times = catt.ECG.times;

% detrend the data.
% First, use a median filter with 200ms width.
% Filter that again with a 600ms width.
% Subtract this baseline from the ECG.
baseline = medfilt1(ecg,round(catt_opts.fs/(1000/200)));
baseline = medfilt1(baseline,round(catt_opts.fs/(1000/600)));
ecg      = ecg-baseline;

% wavelet denoising with db1
ecg = wdenoise(ecg,3,'Wavelet','db1');

% save the processed data in our structure
catt.ECG.processed = ecg;


end