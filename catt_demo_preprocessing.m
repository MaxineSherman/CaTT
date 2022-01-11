%CATT_DEMO_PREPROCESSING a demo for the toolbox, from importing raw data to preprocessing
%
%   usage: catt_demo
% ========================================================================
%  CaTT TOOLBOX v2
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  06/07/2021
% ========================================================================

function catt_demo_preprocessing
try
    % ==================================================
    % Initialise the toolbox and set any parameters you
    % need
    % ==================================================

    global catt_opts % make the options structure available
    catt_init; % initialise the toolbox, generating the options structure

    disp('<strong> % -------------------------------------------------------- %</strong>');
    disp('<strong> %                 CaTT Demo</strong>');
    disp('<strong> %             Preprocessing data</strong>');
    disp('<strong> % -------------------------------------------------------- %</strong>');

    disp('Welcome to the CaTT demo for preprocessing data.')
    disp('First, we need set the options structure catt_opts to global.');
    disp('We do this by calling <strong>global catt_opts</strong>.')
    disp('Then we call <strong>catt_init</strong> to initialise the toolbox.')

    input('Press any key to continue');disp(sprintf('\n'));

    % ==================================================
    % Download the data
    % ==================================================

    % if the data haven't already been downloaded, download them
    dload = exist('demo data/sample_behaviour.csv')==0 | exist('demo data/sample_ECG.tsv')==0;

    if dload
        disp('We need to get the data. The data can be found here: https://osf.io/e9df4/');
        disp('The code will download the data for you now.');
        input('Press any key to continue');disp(sprintf('\n'));

        % make demo data folder if it doesn't already exist
        if ~exist('demo data','dir'); mkdir('demo data'); end

        % download the sample behaviour & sample ECG
        disp('downloading sample behavioural data...'); % update researcher
        websave('demo data/sample_behaviour.csv','https://osf.io/82kwf/download'); % download to arg1 from arg2
        disp('done.');

        % download the sample ECG
        disp('downloading sample ECG data...');
        websave('demo data/sample_ECG.tsv','https://osf.io/n5ksd/download'); % download to arg1 from arg2
        disp('done.');
    end

    % add to path
    addpath(genpath('demo data'));disp(sprintf('\n'));

    % ==================================================
    % Import the data
    % ==================================================
    disp('The ECG data is called sample_ECG.tsv.');
    disp('To extract it we will use the function <strong>importdata</strong>.');
    % Our sample data are in a text file called sample_ECG.tsv
    ecg_data = importdata('sample_ECG.tsv'); % open the data
    ecg      = ecg_data(:,2); % get the ecg data from column 2
    times_ms = ecg_data(:,1)*1000; % express time in milliseconds

    disp('We need to enter the sample rate (here, 1000Hz) into catt_opts.');
    disp('Do this by calling <strong>catt_opts.fs = 1000;</strong>');
    % The sample rate of our ECG data is 1000hz.
    catt_opts.fs = 1000; % tell CaTT that the sample rate of the ECG is 1000hz

    disp(sprintf('\n'));
    disp('Note that if you don''t know the sample rate you can estimate it from');
    disp('Your ECG data + the time stamps by calling <strong>catt_opts.fs = catt_estimate_srate(ecg,times_ms);</strong>');
    disp(sprintf('\n'));
    % Note that if we didn't know the sample rate, we could estimate it like
    % this:
    %catt_opts.fs = catt_estimate_srate( ecg, times_ms );

    % or alternatively, if we didn't have the times_ms then we could estimate
    % it from ecg and srate:
    %times_ms = catt_estimate_times( ecg, srate);

    % We also have some behavioural data that we need to load
    disp('The behavioural data is called sample_behaviour.csv.');
    disp('To extract it we will use the function <strong>readtable</strong>.');

    beh_data  = readtable('sample_behaviour.csv');
    onsets_ms = beh_data.stimulus_onset_ms;
    responses = beh_data.response_accuracy;

    input('Press any key to continue');disp(sprintf('\n'));

    % ==================================================
    % Put the data into a format that catt can deal with
    % ==================================================
    disp('Next, we need to import the data into catt.');
    disp('We will use this code: <strong>catt = catt_import(ecg, times_ms, onsets_ms, responses);</strong>');
    catt = catt_import(ecg, times_ms, onsets_ms, responses);

    disp('Using the function catt_import, we have now imported the data and the basic catt structure has been created.');
    disp('This structure gathers your ECG and behavioural data and creates:');
    disp('catt.ECG.raw - your raw ECG voltage data');
    disp('    catt.ECG.times     - the timestamps for raw ECG data');
    disp('    catt.onsets_ms     - your onsets, in milliseconds');
    disp('    catt.ECG.responses - your responses');
    input('Press any key to continue');disp(sprintf('\n'));

    % ==================================================
    % Denoise the data
    % ==================================================
    disp('<strong>catt_demo_preprocessing:</strong> denoising data...');
    disp('We will use this code: <strong>catt = catt_denoise( catt );</strong>');

    catt = catt_denoise( catt );

    disp('Using the function catt_denoise, we have now denoised the data.');
    disp('This function removes baseline drifts & filters the data.');
    disp('You will now find a new entry in your catt structure:');
    disp('    catt.ECG.processed     - your denoised ECG data');

    input('Press any key to continue');disp(sprintf('\n'));

    % ==================================================
    % Detect r-peaks & t-waves
    % ==================================================
    disp('<strong>catt_demo_preprocessing:</strong> detecting r and t...');
    disp('We will use this code: <strong>catt = catt_heartbeat_detection(catt);</strong>');

    catt = catt_heartbeat_detection(catt);

    disp('Using the function catt_heartbeat_detection we have detected rpeaks, ');
    disp('tpeaks and the end of the twave.');
    disp('This function has created many new entries into your catt structure.');
    disp('They can be found in catt.tlock:');
    disp('    catt.tlock.rPeaks_idx   - where in the catt.ECG.processed vector the r-peaks are');
    disp('    catt.tlock.rPeaks_msec  - when the r-peaks are (in msec)');
    disp('    catt.tlock.tPeaks_idx   - where in the catt.ECG.processed vector the t-peaks are');
    disp('    catt.tlock.tPeaks_v     - voltage of the t-peaks');
    disp('    catt.tlock.tPeaks_msec  - when the t-peaks are (in msec)');
    disp('    catt.tlock.tEnds_idx    - where in the catt.ECG.processed vector the t-wave ends are');
    disp('    catt.tlock.tEnds_v      - voltage of the ends of the t-waves');
    disp('    catt.tlock.tEnds_msec   - when the t-wave ends are (in msec)');
    disp('    catt.tlock.RT_idx       - where in the catt.ECG.processed vector the RT interval is');
    disp('    catt.tlock.RT_msec      - the length of the RT intervals, in msec');

    input('Press any key to continue');disp(sprintf('\n'));
    % ==================================================
    % Epoch into RR intervals
    % ==================================================
    disp('<strong>catt_demo_preprocessing:</strong> epoching...');
    disp('We will use this code: <strong>catt = catt_epoch( catt );</strong>');

    catt = catt_epoch( catt );

    disp('Using the function catt_epoch we have "epoched" the data into RR-intervals.');
    disp('This function has created many new entries into your catt structure.');
    disp('They can be found in catt.RR.');
    disp(['We detected ' num2str(numel(catt.tlock.rPeaks_idx)) ' r-peaks, so there are ' num2str(numel(catt.RR)) ' entries in catt.RR']);
    disp('For each RR interval, i, catt.RR(i) contains:');
    disp('    catt.RR(i).idx_RR    - where in the catt.ECG.processed vector the RR interval is');
    disp('    catt.RR(i).idx_twav  - where in the catt.ECG.processed vector the t-peak to t-end interval is');
    disp('    catt.RR(i).ECG       - processed ECG data for this RR interval');
    disp('    catt.RR(i).times     - timestamps for this RR interval');
    disp('    catt.RR(i).RR_t0     - when this RR interval started (in msec)');
    disp('    catt.RR(i).RT        - RT interval (in msec)');
    disp('    catt.RR(i).tPeak     - when the peak of the t-wave was (in msec since the r-peak)');
    disp('    catt.RR(i).tEnd      - when the end of the t-wave was (in msec since the r-peak)');
    disp('    catt.RR(i).onset     - if present, when the onset was (in msec since the r-peak). NaN means no onset present');
    disp('    catt.RR(i).response  - if present, what the associated response was. NaN means no response present.');

    input('Press any key to continue');disp(sprintf('\n'));
    % ==================================================
    % Manual artefact rejection
    % ==================================================
    disp('<strong>catt_demo_preprocessing:</strong> manual rejection...');
    disp('We will use this code: <strong>catt = catt_manualRejection( catt );</strong>');

    disp(sprintf('\n'));
    disp('You are about to do manual rejection of the RR intervals.');
    disp('You will be prompted to enter the number of RR intervals you want to see at once.');
    disp('If you want, just click enter for the default of 10. I usually use 30 to speed things along.');
    disp('You will see the ECG data plotted in grey.');
    disp('Detected rpeaks will be indicated by red circles.');
    disp('Detected t-waves (peak to end) will be indicated by blue lines.');
    disp('Click r-peaks (red circles) to remove bad RR intervals. They will turn grey');
    disp('You can remove as many as needed.');
    disp('Click enter to move to the next piece of the data when you are ready.');
    input('Press any key to begin manual rejection.');

    catt = catt_manualRejection( catt );

    disp('catt.RR now only includes those RR intervals you chose to keep.');
    disp('You also have a new field in your catt structure called catt.rej.');
    disp('Your original data can be found in catt.rej.orig, along with indices for removed and retained RRs.');
    disp(sprintf('You rejected %.2f percent of RR intervals.',100*catt.rej.prop_RRs_removed));
    disp(sprintf('You now have %.2f percent of your onsets remaining.',100*catt.rej.prop_onsets_retained));

    input('Press any key to continue');disp(sprintf('\n'));
    % ==================================================
    % Calculate IBI and HRV
    % ==================================================
    disp('<strong>catt_demo_preprocessing:</strong> calculating IBI & HRV...');
    disp('We will use this code: <strong>plot_on = true;</strong>');
    disp('                       <strong>catt    = catt_IBI( catt, plot_on );</strong>');

    plot_on = true;
    catt    = catt_IBI( catt, plot_on );

    disp('We have just run the function catt_IBI.');
    disp('We set plot_on to true, and then called catt = catt_IBI(catt,plot_on);');
    disp('You will now find that catt.RR includes the entry catt.RR.IBI');
    disp('This tells you the interbeat interval, in msecs');
    disp('Extreme IBIs (>2SD from mean, shorter than 400msec or longer than 1800msec) have been removed.');
    disp('You can find these in catt.rej.removed_for_bad_IBI');
    disp(sprintf('The function removed %.2f percent of the retained onsets.',100*catt.rej.prop_IBIs_removed));
    disp(sprintf('We have %.2f percent of the original onsets remaining.',100*sum(~isnan([catt.RR.onset]))/numel(catt.onsets_ms)));

    input('Press any key to continue');disp(sprintf('\n'));

    disp('Now we are going to calculate heart rate variability.');
    disp('The default method is RMSSD, but we will use SDNN (standard deviation of IBIs) instead.');
    disp('We do this by settings catt_opts.HRV_method to SDNN');
    disp('We will use this code: <strong>catt_opts.HRV_method = ''SDNN'';</strong>');
    disp('                       <strong>catt = catt_HRV( catt );</strong>');
    catt_opts.HRV_method = 'SDNN';
    catt = catt_HRV( catt );

    disp(sprintf('HRV = %.2f msec',catt.HRV'));
    input('Press any key to continue');disp(sprintf('\n'));

    % ==================================================
    % Convert onsets to phase angles
    % ==================================================

    disp('<strong>catt_demo_preprocessing:</strong> converting onsets to cardiac phase angles...');

    disp('First, we get the qt intervals from our data (r and t wave detection) and load them into catt.qt.');
    disp('We will set catt_opts to estimate qt from data, by calling:');
    disp('<strong>catt_opts.qt_method = ''data'';</strong>');
    disp('Then we will use this code: <strong>catt = catt_estimate_qt( catt );</strong>');
    catt = catt_estimate_qt(catt);
    disp(sprintf('\n'));
    disp('This has given us a new entry in catt called catt.qt.');
    disp(['It has ' num2str(numel(catt.qt)) ' elements - one for each RR interval.']);
    disp('To convert onsets to cardiac phase angles, we use the code:');
    disp('<strong>catt = catt_wrap2heart(catt);</strong>');
    catt.wrapped    = catt_wrap2heart( catt );

    disp('We now have a new field called catt.wrapped.');
    disp('This contains: ');
    disp('    catt.wrapped.onsets_msec  - This is the same as [catt.RR.onset]; timings of the onsets, in msec post r-peak.');
    disp('    catt.wrapped.IBIs         - This is the same as [catt.RR.IBI]; IBIs for each RR interval that contains a retained onset.');
    disp('    catt.wrapped.responses    - This is the same as [catt.RR.response]; responses for each RR interval that contains a retained onset.');
    disp('    catt.wrapped.method       - Method for wrapping onsets to IBIs');
    disp('    catt.wrapped.onsets_rad   - Onsets wrapped to the cardiac cycle, in radians');
    disp('    catt.wrapped.rt           - R-T latency used in the calculation');
    input('Press any key to continue');disp(sprintf('\n'));

    % ==================================================
    % Finish up
    % ==================================================

    save catt_demo_processed catt
    disp(sprintf('\n'));
    disp('<strong>% -----------------------------------------------------------------------%</strong>');
    disp('<strong>This demo is now over.</strong>');
    disp('<strong>By adapting this code you will hopefully be able to</strong>');
    disp('<strong>preprocess all your participant data.</strong>');
    disp('<strong>You can find the catt structure in the file catt_demo_processed.mat.</strong>');
    disp('<strong>% -----------------------------------------------------------------------%</strong>');

    %% ----------------------------------------------------------------------
    %  End of demo
    %  ----------------------------------------------------------------------
catch err
    try save err_demo_preproc catt; catch; end
    rethrow(err)
end
