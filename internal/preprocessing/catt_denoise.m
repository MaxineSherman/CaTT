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
%  CaTT TOOLBOX v1.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% ========================================================================

function catt = catt_denoise( catt )

%% get opts
global catt_opts

%% get the sampling rate from data
itimes        = catt.ECG.times{ 1 };
nsamples      = numel(catt.ECG.times{ 1 });
epochLength   = itimes(end)-itimes(1);
catt_opts.fs  = round(1000*nsamples/epochLength);

%% loop trials & denoise
for itrial = 1:numel(catt.ECG.raw)
    
    % get the ecg data for the ith trial
    ecg   = catt.ECG.raw{ itrial };
    times = catt.ECG.times{ itrial };
    
    % detrend the data.
    % First, use a median filter with 200ms width.
    % Filter that again with a 600ms width.
    % Subtract this baseline from the ECG.
    baseline = medfilt1(ecg,fs/(1000/200));
    baseline = medfilt1(baseline,fs/(1000/600));
    ecg      = ecg-baseline;
    
    % wavelet denoising with db1
    ecg = wdenoise(ecg,3,'Wavelet','db1');
    
    % save the processed data in our structure
    catt.ECG.processed{itrial} = ecg;
    
end
end