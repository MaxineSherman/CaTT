%CATT_PREPROCESS import data into the catt toolbox & preprocess
%   usage: catt = catt_preprocess(ECG, Times, Response, Onsets )
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
%
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
%  CaTT TOOLBOX v1.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================

function catt = catt_preprocess(ECG, Times_ms, Response, Onsets, method)

%% check inputs
if nargin < 5 | isempty(method); method = 'RMSSD'; end

% ========================================================================
%  Organise the data and load into catt structure
% =========================================================================

% 1. Do we have the same number of trials in each input?
assert( numel(ECG)==numel(Times_ms) & numel(ECG)==numel(Response) & numel(ECG)==numel(Onsets) , 'Error in intero_importData: unequal number of trials in ECG, Trials, Response and Onsets. Please check your inputs');
ntrials = numel(ECG);

% 2. Make sure everything is ntrials x 1 & load into catt
catt.ECG.raw       = reshape(ECG,ntrials,1);
catt.ECG.times     = reshape(Times_ms,ntrials,1);
catt.responses     = reshape(Response,ntrials,1);
catt.onsets_ms     = reshape(Onsets,ntrials,1);

% ========================================================================
%  Denoise the data
% =========================================================================

catt = catt_denoise( catt );

% ========================================================================
%  For each trial, we want to get:
%  - The interbeat interval, IBI
%  - The time since the previous R peak
%  - The ECG signal from the previous R peak until the time of stimulus
%    onset
% =========================================================================

catt = catt_detect_rpeaks( catt );

% ========================================================================
%  Perform manual rejection, then update catt structure
%  to boot out rejected trials
% =========================================================================
catt = catt_manual_rejection( catt );
catt = catt_update( catt, catt.retained_idx );

% ========================================================================
%  Finally, we want to estimate the corrected qt interval (only matters if
%  you're timelocking to t-wave, then wrap onsets to t or r
%  Change the parameters in catt_opts to edit this.
% =========================================================================

catt = catt_estimate_qt( catt );
catt = catt_wrap2heart( catt );

end