%CATT_IMPORT import data into the catt toolbox
%   usage: catt = catt_import(ECG, times_ms, onsets_ms, [responses]  )
%
%   INPUTS:
%       ECG: an nx1 or 1xn vector with the ECG voltage
%
%       times_ms: an nx1 or 1xn vector with timestamps for each ECG sample,
%       in msecs
%
%       onsets_ms: an mx1 or 1xm vector with stimulus onsets OR response
%       times you want to timelock cardiac data to. Express in msecs
%
%       responses: a kx1 or 1xk vector with each behavioural response in
%       the experiment. If no responses were collected then enter an empty
%       vector
%
%       
%  EXAMPLES:
%
%  Suppose I have 5 minutes of ECG data, collected at 1024Hz.
%  Then ECG is a 1 x 307200 vector of samples.
%
%  times_ms is also 1 x 307200, and the last value is 300,000 (300,000
%  msecs = 5 minutes)
%
%  Suppose participants complete 10 trials in these 5 minutes.
%  On each trial, people reported whether they saw an angry face
%  (response = 1) or a neutral face (response = 0).
%  Your responses vector may look like this:
%  responses = [0 0 0 1 1 0 1 1 0 1];
%
%  And finally, suppose that a face was presented every 20 seconds,
%  starting after 1 minute of data collection. Then we would have:
%  onsets_ms = [ 60000 80000 100000 120000 140000 160000 180000 200000
%  220000 240000];
%
%  To import the data into CaTT, call the following:
%  catt = catt_import( ECG, times_ms, onsets_ms, responses)
%
%  If participants didn't make a response, you could call:
%  catt = catt_import( ECG, times_ms, onsets_ms );

% ========================================================================
%  CaTT TOOLBOX v2
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  06/08/2021
% ========================================================================

function catt = catt_import( ecg, times_ms, onsets_ms, responses )

% responses is optional
if nargin == 3; responses = []; end

% check size of ecg = size of times
assert( numel(ecg) == numel(times_ms),'You should have the same number of ECG samples in ECG as timepoints in times_ms');

% put everything into columns & load into catt
catt.ECG.raw      = reshape(ecg, numel(ecg), 1);
catt.ECG.times    = reshape(times_ms, numel(times_ms), 1);
catt.onsets_ms    = reshape(onsets_ms, numel(onsets_ms), 1);
catt.responses    = reshape(responses, numel(responses), 1);

end
