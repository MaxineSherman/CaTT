%CATT_IBI get the IBI of the cycle in which onset appeared, the onset
%expressed as time since the last R peak, and a vector of all IBIs.
%   usage: [onset_IBI , onset_tsinceR , all_IBI ] = catt_IBI(rpeaks_msec, onset)
%
%    INPUTS: 
%       - rpeaks_msec       A vector containing each r-peak time, in milliseconds
%       - onset             The onset for the trial, in milliseconds. Time
%                           0 is the start of the trial.
%
%    OUTPUTS:
%       - onset_IBI         The IBI (in msec) of the R-R interval in which the onset
%                           occurred. Only given when onset is an input.
%                           Otherwise the value is nan.
%       - onset_tsinceR     Onset time (in msec) since the last R peak
%       - all_IBI           A vector containing each IBI, in milliseconds
%
%
% ========================================================================
%  CaTT TOOLBOX v1.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% ========================================================================

function [onset_IBI, onset_tsinceR, allIBI] = catt_IBI( rpeaks_msec, onset )

% get all IBI
all_IBI  = diff(rpeaks_msec);

% get onset IBI
r_minus_onset = rpeaks_msec - onset;
idx1 = find(diff(sign(r_minus_onset))~=0);
onset_IBI = rpeaks_msec(idx1+1) - rpeaks_msec(idx1);

% get time since last R peak
onset_tsinceR = onset - rpeaks_msec(idx1);
end