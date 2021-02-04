%INTERO_DEMO demo for interoception toolbox  
%   usage: intero_demo
%
%   The demo will simulate data and use the various functions of the
%   toolbox to show what can be done with it.
%
% ========================================================================
%  INTERO TOOLBOX v1.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================

function intero_demo

%% ========================================================================
%  Initialise the global variable intero_opts with all settings.
%  Go into intero_init to change them.
%  Change them however you want!
%  ========================================================================

global intero_opts
intero_init;

%% ========================================================================
%  Simulate some data.
%  ========================================================================

% Imagine we have 10 participants, each of whom complete 40 trials. 
% On each trial, they give a binary report of how threatening an ambiguous
% face was, where 0 is not threatening and 1 is threatening. 
% ECG is collected while they perform this task.
% Each trial is 6sec long and the face appears some time between 3.5 and
% 5.5 seconds after the trial begins.
%
% This is the default setup for the simulate function.
%
% We can see these parameters in param.sim:
%
% intero_opts.sim.nsubj      = 10;
% intero_opts.sim.ntrials    = 40;
% intero_opts.sim.length     = 6000; % in msec
% intero_opts.sim.fs         = 500; % 500Hz sampling rate
% intero_opts.sim.HRs        = 50:100; % the heart rates to sample frendom
% intero_opts.sim.ECG_noise  = 0.1:0.02:0.36; % the ECG noise to sample from
% intero_opts.sim.onsetTimes = [3500,5500]; % the first and last timestamp the onset can be drawn from.
% intero_opts.sim.responses  = [0,1]; % what are the possible responses? For continuous responses you can change this to e.g. 0:100.
%
% Again, you can either change these in the script, like this...
intero_opts.sim.ntrials = 40; 
% ...or change the defaults in intero_init and save the file.

% Simulate data
dat = intero_simulate; 

% An alternative would be to load each of your 10 participants' data
% into a seperate intero_data_importer.csv spreadsheet.
% Suppose all those data are saved in a folder called Data.
% Then, you could call: 

% dat = intero_import;

%% ========================================================================
%  For each participant, preprocess the data
%  ========================================================================

for isubj = 1:numel(dat)
    
    % update researcher
    clc;disp(['<strong>intero:</strong>' sprintf('preprocessing subj %d of %d...',[isubj,numel(dat)])]);
    
    % pre-process + import into an intero structure.
    % we're going to quantify HRV with RMSSD
    Y(isubj).intero = intero_preprocess(dat(isubj).ECG, ...
                                        dat(isubj).times, ...
                                        dat(isubj).response, ...
                                        dat(isubj).onsets, ...
                                        dat(isubj).condition,...
                                        'RMSSD');
   
    % manual peak detection/rejection
    % will add gui at some point. for now, just plot + use keyboard inputs
    Y(isubj).intero = intero_manualRejection( Y(isubj).intero );
    
    % based on the rejected trials, boot out the bad ones from the
    % structure and recompute IBI, HRV etc
    Y(isubj).intero = intero_update( Y(isubj).intero , Y(isubj).intero.retained_idx);
      
    % get timings of the r-peaks, both in seconds, and relative
    % to their place in the cardiac cycle.
    % We're going to wrap onsets to the t-wave (systole).
    % We assume that t always comes 300msec after the R-peak.
    % We need to pass these assumptions into a parameter structure
    param.proc.wrap2     = 'twav'; % to wrap to the r-peak instead enter 'rpeak'
    param.proc.r2t       = 300;    % assuming 300msec fixed length. You don't need this if wrapping to r-peak.
    
    Y(isubj).intero = intero_get_times( Y(isubj).intero );
    
    % plot when each stimulus was presented in the cardiac cycle,
    % separately for the 2 responses. If the 2 response types are clustered
    % separately then there may be an effect of cardiac timing on response class.
    % If dots aren't uniform across the x-axis (i.e. on a broadly straight x=y
    % line) then onsets aren't uniformly distributed over the cardiac
    % cycle. If you timed stimulus onsets according to systole/diastole
    % then this is to be expected. If this was an RT task then cardiac
    % cycle predicts action (maybe). Otherwise, you have a problem.
    figure('units','pixel','position',[100,100,900,600]);
    subplot(1,2,1);intero_plot_onset_dist( Y(isubj).intero  ); 
    
    % also, plot heart times over ecg
    subplot(1,2,2);intero_plot_over_ECG( Y(isubj).intero ); 
    
    %% ========================================================================
    %  Assume timelocked responses
    %
    %  So far, responses were simulated such that were randomly
    %  positioned within the cardiac cycle.
    %
    %  Now, we'll simulate data that assumes that R1 
    %  is clustered around systole and R2 is clustered
    %  around diastole.
    %  ========================================================================
    
    % First, we need to update the simulation parameters.
    % We want to set the responses such that there is a correlation
    % between cardiac timing and response.
    intero_opts.sim.association = 'correlation';
    intero_opts.sim.effect_size = 0.5;
    
    % You could also set association to 'difference'.
    % A negative correlation would require a negative number (up to -1).
    Y(isubj).intero.responses = Y(isubj).intero.tlock.onsets_r_rad < normrnd(0,0.5,numel( Y(isubj).intero.tlock.onsets_r_rad ), 1);
    figure;
    subplot(1,3,1); intero_plot_onset_dist( Y(isubj).intero ); 
    subplot(1,3,2); intero_plot_over_ECG( Y(isubj).intero ); 
    
    %% test whether there's a difference in response times
    R0 = Y(isubj).intero.tlock.onsets_r_rad( Y(isubj).intero.responses==0 );
    R1 = Y(isubj).intero.tlock.onsets_r_rad( Y(isubj).intero.responses==1 );
    pval = intero_bootstrap_diff(R0,R1,'between','circular');
    
    %% now let's plot the results over a circular histogram + give the pvalue as the title
    subplot(1,3,3)
    intero_plot_circ( {R0,R1}, {'R0','R1'}, 'participants','on' );
    title(sprintf('pval = %.3f',pval),'FontSize',13);
    
    clc;input('continue?')
    
    
end

  disp('')


