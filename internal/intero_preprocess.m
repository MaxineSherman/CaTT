%INTERO_PREPROCESS import data into the interoception toolbox & preprocess
%   usage: intero = intero_preprocess(ECG, Times, Response, Onsets, [method])
%
%   We need:
%
%   EGC: an ntrials x 1 cell array.
%           Each cell contains the ECG voltage for that trial.
%           Example: ECG{1} is a 100 x 1 numeric vector, because there were
%           100 time points.
%
%  Times_ms: an ntrials x 1 cell array.
%           Each cell contains the time (in msec) at which ECG was sampled for that
%           trial.
%           Example: Times{1} is a 100 x 1 numeric vector going from 0ms to
%           1000 because trial 1 was 1000ms long and we sampled every 10ms
%   
%  Response: an ntrials x 1 vector
%            Each value contains the response you want to map to cardiac
%            data.
%            For example, if there were 30 trials on which people reported
%            either 1 (angry face) or 0 (not angry face), then this would
%            be a 30 x 1 vector of 0s and 1s.
%
%  Onsets: an ntrials x 1 vector
%            Each value contains the sample time that you want to timelock
%            to. This could be the time the response was made, or this
%            could be the time the stimulus appeared on the screen. The
%            time should be on the same scale as the times given in the input Times.
%            For example, if there were 30 trials on which people reported
%            either 1 (angry face) or 0 (not angry face), and on every
%            trial the stimulus appeared after 500ms then this would be a
%            30 x 1 vector all containing 500.
%
%  Method [optional]: a string with the method for computing HRV
%                     Method options are explained in intero_HRV.
%                     Options are: 'RMSSD' [default] 
%                                  'SDNN'  
%                                  'SDSD' 
%                                  'pNN50' 
%                                  'pNN20' 

%  Pre-processing:
%
%  1. Remove baseline drift using a combination of 200ms and 600ms median
%  filters
%
%  2. Wavelet denoising
%
%  3. R-peak detection is performed using the method in Manikandan &
%  Sabarimalai (2012).
%  This function calls on the authors' code, which can be found here:
%  https://github.com/hongzuL/A-novel-method-for-detecting-R-peaks-in-electrocardiogram-signal
%  Manikandan, M. Sabarimalai, and K. P. Soman. "A novel method for detecting R-peaks in electrocardiogram (ECG) signal." Biomedical Signal Processing and Control 7.2 (2012): 118-128.
% ========================================================================
%  INTERO TOOLBOX v1.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================

function intero = intero_preprocess(ECG, Times_ms, Response, Onsets, method)

%% check inputs
if nargin < 5 | isempty(method); method = 'RMSSD'; end

% ========================================================================
%  Organise the data 
% =========================================================================

%% 1. Do we have the same number of trials in each input?
assert( numel(ECG)==numel(Times_ms) & numel(ECG)==numel(Response) & numel(ECG)==numel(Onsets) , 'Error in intero_importData: unequal number of trials in ECG, Trials, Response and Onsets. Please check your inputs');
ntrials = numel(ECG);

%% 2. Make sure everything is ntrials x 1 & load into intero
intero.ECG.raw       = reshape(ECG,ntrials,1);
intero.ECG.times     = reshape(Times_ms,ntrials,1);
intero.responses     = reshape(Response,ntrials,1);
intero.onsets_ms     = reshape(Onsets,ntrials,1);

%% get the sampling rate
itimes      = intero.ECG.times{ 1 };
nsamples    = numel(intero.ECG.times{ 1 });
epochLength = itimes(end)-itimes(1);
fs          = round(1000*nsamples/epochLength);

%% build the filter we'll use later for R-peak detection
BP_filter = chebyshevI_bandpass(fs);

% ========================================================================
%  For each trial, we want to get:
%  - The interbeat interval, IBI
%  - The time since the previous R peak
%  - The ECG signal from the previous R peak until the time of stimulus
%    onset
% =========================================================================

for itrial = 1:ntrials
    
    % get the ecg data for the ith trial
    ecg   = intero.ECG.raw{ itrial };
    times = intero.ECG.times{ itrial };
    
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
    intero.ECG.processed{itrial} = ecg;
    
    % peak detection
    [~, rPeakTimes] = SEHT(ecg,fs,BP_filter);
    
    % Load in the r-peak data into the field tlock (i.e. timelocked)
    intero.tlock.rPeaks{itrial,1}      = rPeakTimes;
    intero.tlock.rPeaks_msec{itrial,1} = times(rPeakTimes);

    % load in IBI & HRV 
    [ intero.IBI(itrial,1),...
      intero.onset(itrial,1)]      = intero_IBI( times(rPeakTimes), Onsets(itrial) );
    intero.HRV(itrial,1)           = intero_HRV( times(rPeakTimes), 'r', method );
    intero.HRV_method              = method;
 
    % assume for now that all trials are retained.
    % later you can do manual rejection
    intero.keepTrial                  = logical(ones(ntrials,1));
    intero.retained_idx               = [1:ntrials]';
    
end

end