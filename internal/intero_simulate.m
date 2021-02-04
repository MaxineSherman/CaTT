%INTERO_SIMULATE simulate an ECG + behaviour dataset according to the
%settings in param.
%
%   usage: dat = intero_simulate
%
%   This function doesn't have inputs.
%   Instead, it uses the parameters stored in intero_opts.sim
%
%   These parameters are:
%
%      - intero_opts.sim.nsubj        Number of participants, e.g. 10
%      - intero_opts.sim.ntrials      Number of trials per participant, e.g. 50
%      - intero_opts.sim.length       Length of each trial in msec, e.g. 6000
%      - intero_opts.sim.fs           Sampling rate in Hz, e.g. 500
%      - intero_opts.sim.HRs          A vector of possible heart rates for each participant, e.g.
%                                     50:100. The assumption here is that possible HRs are uniformly
%                                     distributed.
%      - intero_opts.sim.ECG_noise    A vector containing possible ECG noise levels, e.g.
%                                     0.1:0.02:0.36. This is additive white noise, i.e. for each simulated
%                                     ECG trial data, we add to each time point some value drawn from
%                                     N(0,ECG_noise).
%      - intero_opts.sim.onsetTimes   A 1 x 2 vector containing the earliest and latest time that an onset
%                                     (e.g. stimulus onset or response) can be, in msec. 
%                                     E.g. [3000 5500] would mean that a stimulus appears at any
%                                     time between 3sec and 5.5sec after the trial starts.
%      - intero_opts.sim.responses    a 1 x n vector containing the possible responses
%                                     the participant can give, e.g. [0,1] would mean binary
%                                     responses. For a 0-100 integer scale you could enter 0:100.
%
%      - intero_opts.sim.association  'none', 'correlation', 'difference'
%     
%      - intero_opts.sim.effect_size   a number between -1 and 1
%
%   OUTPUTS:
%
%   dat - An nsubj x 1 structure containing the following fields:
%           - dat(isubj).times, an ntrials x 1 cell array with timestamps
%             for each ECG sample
%           - dat(isubj).ECG, an ntrials x 1 cell array with ECG voltage
%             at each ECG sample
%           - dat(isubj).Response, an ntrials x 1 vector with a response
%           on each trial
%           - dat(isubj).Onsets, an ntrials x 1 vector with the time of the
%           onset on each trial.
%
%   Reference:
%   This function calls upon the toolbox written by Karthik Raviprakash
%   karthik raviprakash (2020).
%   ECG simulation using MATLAB
%   https://www.mathworks.com/matlabcentral/fileexchange/10858-ecg-simulation-using-matlab
%   MATLAB Central File Exchange. Retrieved October 8, 2020.
%
% ========================================================================
%  INTERO TOOLBOX v1.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================


function dat = intero_simulate

% get options
global intero_opts

for isubj = 1:intero_opts.sim.nsubj % loop participants
    
    % update researcher
    clc;disp(['<strong>intero: </strong>' sprintf('simulating subj %d of %d...',[isubj,intero_opts.sim.nsubj])]);
    
    % get participant's mean heart rate and noise of ECG signal
    mHR   = randsample(intero_opts.sim.HRs,1);
    noise = randsample(intero_opts.sim.ECG_noise,1); 
    
    % load in ECG
    for itrial = 1:intero_opts.sim.ntrials
        hr                            = round(normrnd(mHR,1)); % HR on this trial
        dat(isubj).times{itrial,1}    = [1:(1000/intero_opts.sim.fs):intero_opts.sim.length]; % Time stamps each sample
        dat(isubj).ECG{itrial,1}      = simulate_ECG([],hr,noise,dat(isubj).times{itrial,1}+randsample(0:1000,1)); % simulate ECG
   
        % depending on intero_opts, set condition/onset/response
        switch intero_opts.sim.association
            
            case 'none' % no cardiac-behaviour relationship
                dat(isubj).Response(itrial,1) = randsample(intero_opts.sim.responses,1); % get some random response
                dat(isubj).Onsets(itrial,1)   = randsample(intero_opts.sim.onsetTimes(1):(1000/intero_opts.sim.fs):intero_opts.sim.onsetTimes(2),1); % get some random onset time
            
            case 'difference' % effect of condition
                
            case 'correlation' % correlation between 
                
        end
    end
end

end