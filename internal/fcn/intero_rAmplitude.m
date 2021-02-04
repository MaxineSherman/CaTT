%INTERO_RAMPLITUDE compute the relative amplitude of r-peaks
%   usage: y = intero_rAmplitude( ECG , rpeaks )
%
%   This code gives the amplitudes of each r-peak in one or several trials.
%   It gives two separate estimates of r-peak amplitude.
%
%   The first takes a percentile approach. Separately for each trial, the
%   entire ECG trial data is binned into percentiles so that the highest
%   voltages take the highest values. The code returns the r-peak
%   percentiles. In this way, r-peak amplitudes are quantified relative to
%   the other ECG data in the epoch.
%
%   The second takes a z-score approach. Separately for each trial, the raw
%   r-peak amplitude is taken. These amplitudes are then z-scored so that
%   each r-peak amplitude is relative only to the other r-peaks in that
%   trial. The reason for not z-scoring all of the ECG data is that ECG is
%   severely negatively skewed (by the QRS complex).
%
%   INPUTS:
%      ECG     - an ntrials x 1 cell array.
%                Each cell is an ntimes x 1 vector containing the ECG data
%                for that trial. 
%                It's probably best to use pre-processed data here, but
%                it's not a requirement.
%
%      rpeaks  - An ntrials x 1 cell array.
%                Each cell is an npeaks x 1 vector containing the samples 
%                (not msec time points) at which each r-peak occurred.
%
%  OUTPUTS:
%     y       - A structure containing two fields:
%                  y.ramp_prc: an ntrials x 1 cell array containing the
%                              r-peak amplitudes using the percentile method.
%                  y.ramp_z:   an ntrials x 1 cell array containing the 
%                              r-peak amplitudes using the z-score method.
%     
% ========================================================================
%  INTERO TOOLBOX v1.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% ========================================================================

function y = intero_rAmplitude( ECG, rpeaks  )

%% Loop through each trial and get ECG trial data
for i = 1:numel( ECG )
    
    %% method 1: get amplitudes as a percentile of all the ECG data for that trial
    binned          = bin_data( ECG{i}, prctile( ECG{i} , 1:100) );
    y.ramp_prc{i,1} = binned( rpeaks{i} );
    
    %% method 2: zscore the rpeaks
    y.ramp_z{i,1}   = zscore( ECG{i}(rpeaks{i}) );
    
end

end