%CATT_DETECT_RPEAKS detect r-peaks
%   usage: catt = catt_detect_rpeaks(catt)
%
%  This function does the following:
%    1. detects r-peaks
%    2. calculates IBI
%    3. calculates HRV
%
%  R-peak detection is performed using the method in Manikandan &
%  Sabarimalai (2012).
%  This function calls on the authors' code, which can be found here:
%  https://github.com/hongzuL/A-novel-method-for-detecting-R-peaks-in-electrocardiogram-signal
%  Manikandan, M. Sabarimalai, and K. P. Soman. "A novel method for detecting R-peaks in electrocardiogram (ECG) signal." Biomedical Signal Processing and Control 7.2 (2012): 118-128.
%
% ========================================================================
%  CaTT TOOLBOX v1.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% ========================================================================

function catt = catt_detect_rpeaks( catt )

% get opts
global catt_opts

% calculate qt interval (only relevant if we're locking to the t-wave)
catt = catt_estimate_qt( catt );

% confirm BP filter based on sampling frequency
catt_opts.BP_filter = chebyshevI_bandpass(catt_opts.fs);

% loop trials and detect r-peaks
for itrial = 1:numel(catt.ECG.processed)
    
    % peak detection based on processed data
    [~, rPeakTimes] = SEHT(catt.ECG.processed{itrial},catt_opts.fs,catt_opts.BP_filter);
    
    % Load in the r-peak data into the field tlock (i.e. timelocked)
    catt.tlock.rPeaks{itrial,1}      = rPeakTimes;
    catt.tlock.rPeaks_msec{itrial,1} = times(rPeakTimes);

    % load in IBI 
    [ catt.IBI(itrial,1),...
      catt.onset(itrial,1),...
      catt.all_IBI{itrial}]      = intero_IBI( times(rPeakTimes), Onsets(itrial) );
    
    % load in HRV
    catt.HRV(itrial,1)           = intero_HRV( times(rPeakTimes), 'r' );
 
    % assume for now that all trials are retained.
    % later you can do manual rejection
    catt.keepTrial                  = logical(ones(ntrials,1));
    catt.retained_idx               = [1:ntrials]';
    
end

end
