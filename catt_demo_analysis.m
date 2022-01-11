%CATT_DEMO_ANALYSIS demo for analysing data using the catt toolbox
%   usage: catt_demo_analysis
%
%   The demo will use previously published data to illustrate how to do
%   group-level analyses.
%
%   The data come from Galvez-Pol, A., McConnell, R., & Kilner, J. M. (2020).
%  Active sampling in visual search is coupled to the cardiac cycle.
%  Cognition, 196, 104149.
%
%
% ========================================================================
%  CaTT TOOLBOX v2.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  08/08/2021
% =========================================================================

function catt_demo_analysis

try

    %% ========================================================================
    %  First, we will initialise the toolbox
    %  ========================================================================

    global catt_opts
    catt_init;
    rng(1); % fix random seed for reproducability

    disp('<strong> % -------------------------------------------------------- %</strong>');
    disp('<strong> %                 CaTT Demo</strong>');
    disp('<strong> %             Analysing data</strong>');
    disp('<strong> % -------------------------------------------------------- %</strong>');

    disp('Welcome to the CaTT demo for preprocessing data.')
    disp('First, we need set the options structure catt_opts to global.');
    disp('We do this by calling <strong>global catt_opts</strong>.')
    disp('Then we call <strong>catt_init</strong> to initialise the toolbox.')

    input('Press any key to continue');disp(sprintf('\n'));

    disp('For this dataset we are going to assume that the q-t interval is fixed at 400ms.');
    disp('We are making this assumption because the data we are using does not have continuous ECG.');
    disp('We therefore cannot extract qt intervals from the data.');
    disp('To tell CaTT we are making this assumption, call:');
    disp('<strong>catt_opts.qt_method = ''fixed'';</strong>');
    disp('<strong>catt_opts.qt_default = 400;</strong>');

    catt_opts.qt_method  = 'fixed'; % set q-t interval to default of 400ms. We don't have the HR data so can't do BPM correction or t detection
    catt_opts.qt_default  = 400;

    input('Press any key to continue');disp(sprintf('\n'));

    %% ========================================================================
    %  Download the data
    %
    %  We'll be running analyses on the data presented in Galvez-Pol et al.
    %  (2019), which can be found here: https://osf.io/ye3rg/
    %
    %  Galvez-Pol, A., McConnell, R., & Kilner, J. M. (2020).
    %  Active sampling in visual search is coupled to the cardiac cycle.
    %  Cognition, 196, 104149.
    %  ========================================================================

    dload = exist('demo data/blinks')==0 | exist('demo data/saccades and fixations')==0;

    if dload
        disp('We need to get the data. The data can be found here: https://osf.io/ye3rg/');
        disp('The code will download the data for you.');
        input('Press any key to continue');disp(sprintf('\n'));

        % make demo data folder if it doesn't already exist
        if ~exist('demo data','dir'); mkdir('demo data'); end

        % download the blinks data + unzip
        disp('downloading & unzipping blinks data...');
        websave('demo data/Blinks.zip','https://osf.io/h5x84/download');
        unzip('Blinks.zip','demo data/blinks');
        disp('done.');

        % download the saccades & fixations data + unzip
        disp('downloading & unzipping saccades and fixations data...');
        websave('demo data/Saccades and Fixations.zip','https://osf.io/rbt7w/download');
        unzip('Saccades and Fixations.zip','demo data/Saccades and Fixations');

        disp('done');
        disp(sprintf('\n'));
    end

    %% ========================================================================
    %  Load the data
    %  ========================================================================

    addpath(genpath('demo data/Saccades and Fixations'));
    addpath(genpath('demo data/blinks'));

    disp('Using the function <strong>dir</strong> we are going to find all the saccades and blinks datasets.')

    % download both dataset from this OSF project https://osf.ip/ye3rg/
    % unzip and move the filders to `Galvez-Pol`
    datafiles_saccades = dir(['demo data/Saccades and Fixations/Sub*.mat']);
    datafiles_saccades = arrayfun(@(x) ['demo data/Saccades and Fixations/' x.name],datafiles_saccades,'UniformOutput',false);

    datafiles_blinks = dir(['demo data/Blinks Data/Sub*.mat']);
    datafiles_blinks = arrayfun(@(x) ['demo data/Blinks Data/' x.name],datafiles_blinks,'UniformOutput',false);

    %% ========================================================================
    %  Saccades & fixations data: load subj files & put into catt format
    %  ========================================================================
    disp('Make sure you set catt_opts.fs. Here we will write <strong>catt_opts.fs=1000;</strong>');
    %  the sample rate is 1000hz
    catt_opts.fs       = 1000;

    disp('Then, we''ll loop over participants and extract the saccade, fixation and blink onsets,');
    disp('plus the IBIs of the cardiac cycle they fell in.');

    for subj = 1:numel(datafiles_saccades)

        % load data
        load( datafiles_saccades{subj} );

        % extract relevant info
        onsets_ms_saccade  = Saccades_Mx3(:,2);
        onsets_ms_fixation = Saccades_Mx3(:,9);
        IBI                = Saccades_Mx3(:,4);

        % we need to create the kind of structure we'd be getting from
        % catt_epoch
        for iR = 1:numel(IBI)
            catt_saccades{subj}.RR(iR).idx_RR      = 1:IBI(iR);
            catt_saccades{subj}.RR(iR).times       = 1:IBI(iR);
            catt_saccades{subj}.RR(iR).onset       = onsets_ms_saccade(iR);
            catt_saccades{subj}.RR(iR).response    = nan;
        end

        for iR = 1:numel(IBI)
            catt_fixations{subj}.RR(iR).idx_RR      = 1:IBI((iR));
            catt_fixations{subj}.RR(iR).times       = 1:IBI((iR));
            catt_fixations{subj}.RR(iR).onset       = onsets_ms_fixation((iR));
            catt_fixations{subj}.RR(iR).response    = nan;
        end

        % exclude extreme IBIs
        catt_saccades{subj}  = catt_IBI(catt_saccades{subj});
        catt_fixations{subj} = catt_IBI(catt_fixations{subj});

        % estimate qt
        catt_saccades{subj}  = catt_estimate_qt(catt_saccades{subj});
        catt_fixations{subj} = catt_estimate_qt(catt_fixations{subj});
    end

    input('Press any key to continue');disp(sprintf('\n'));

    %% ========================================================================
    %  Blinks data: load subj files & put into catt format
    %  ========================================================================

    disp('Loading blinks data...');
    for subj = 1:numel(datafiles_blinks)

        % load data
        load( datafiles_blinks{subj} );

        % extract relevant info
        onsets_ms_blink   = Saccades_Mx2(:,2);
        IBI               = Saccades_Mx2(:,3);

        % let's pretend that the sample rate is 1000hz
        catt_opts.fs       = 1000;

        % we need to create the kind of structure we'd be getting from
        % catt_epoch
        for iR = 1:numel(IBI)
            catt_blinks{subj}.RR(iR).idx_RR      = 1:IBI(iR);
            catt_blinks{subj}.RR(iR).times       = 1:IBI(iR);
            catt_blinks{subj}.RR(iR).onset       = onsets_ms_blink(iR);
            catt_blinks{subj}.RR(iR).response    = nan;
        end

        % exclude extreme IBIs
        catt_blinks{subj}  = catt_IBI(catt_blinks{subj});

        % estimate qt
        catt_blinks{subj}  = catt_estimate_qt(catt_blinks{subj});
    end


    %% ========================================================================
    %  Loop wrapping (to r vs t) and data (fixations vs saccades vs blinks)
    %  ========================================================================
    for i_wrap = 1:2 % loop over wrapping to R vs T
        switch i_wrap
            case 1; catt_opts.wrap2 = 'rpeak';
            case 2; catt_opts.wrap2 = 'twav';
        end

        for i_analysis = 1:3 % loop through the 3 types of event
            switch i_analysis
                case 2; group = catt_saccades;  analysis_name = 'saccades';
                case 1; group = catt_fixations; analysis_name = 'fixations';
                case 3; group = catt_blinks;    analysis_name = 'blinks';
            end

            Z_subjs = []; % initialise a new vector for saving z-scores

            %% ========================================================================
            %  The question here is as follows: are blinks more likely to occur at some
            %  particular point in the cardiac cycle.
            %
            %  To test this, we first need to place the data into a form the toolbox
            %  can understand (i.e. into aca structure).
            %
            %  Next, we'll run a range of different analyses for comparison purposes.
            %  ========================================================================

            for subj = 1:numel(group)

                % update researcher:
                clc;disp(['<strong>' analysis_name, ' wrapped to ' catt_opts.wrap2 ': </strong>' sprintf('running subj %d/%d',[subj,numel(group)])]);

                %  Run permutation testing.
                %  This will be done separately for rpeak and t-wave.
                %  We need to save the stats output so we can combine over participants
                %  later on.

                [~, stats, group{subj}] = catt_bootstrap_clust( group{subj}, 'rao', 1000 );
                Z_subjs(subj)   = stats.zscore;

            end

            %% ========================================================================
            %  Combine z-scores using schouffer's method
            %  ========================================================================

            disp(['===============================================']);
            disp(['% Group stats:' analysis_name ', wrap to ' catt_opts.wrap2]);
            disp(['===============================================']);

            [P_group,Z_group] = catt_z2p( group );
            disp(sprintf('Group zval = %.3f, group pval = %.3f',[Z_group,P_group])); % display results


            %% ========================================================================
            %  Plot results
            %  ========================================================================

            %% prepare figure
            figure; box on; hold on;
            lw    = 3;
            fs    = 16;

            %% plot & format
            h = histogram( Z_subjs , 20 );
            h.LineWidth = 2;
            h.FaceColor = [.8 .6 .7];
            set(gca,'LineWidth',lw,...
                'FontSize',fs,...
                'TickLength',[0,0]);
            xlabel('Z score','FontSize',fs);
            ylabel('# Participants','FontSize',fs);

            %% plot p = 0.05 line
            plot( repmat(1.96,100,1), linspace(0,10), 'k--', 'LineWidth', lw);
            plot( repmat(-1.96,100,1), linspace(0,10), 'k--', 'LineWidth', lw);


            %% add marker for the group z at y = 5
            h                 = plot( Z_group, 5 );
            h.Marker          = 'p';
            h.MarkerSize      = 20;
            h.MarkerFaceColor = [.8 .3 .4];
            h.Color           = 'k';
            h.LineWidth       = lw;

            mkdir(['figures/' analysis_name ]);
            print('-dpng',['figures/' analysis_name '/' catt_opts.wrap2]);
            print('-depsc',['figures/' analysis_name '/' catt_opts.wrap2]);

            %% run consistency
            output = catt_consistency(group,8); % you could save the output structure to keep the stats
            input('Press any key to continue');

        end
    end
    %% ========================================================================
    %  Compare within-subject 'preferred phases' for blinks v saccades v
    %  fixations
    %  ========================================================================

    disp(sprintf('\n'));

    disp('Finally, we are going to compare preferred phases for the');
    disp('3 types of oculomotor event.');disp(sprintf('\n'));
    disp('We will do this by running, for each participant, independent circular');
    disp('t-tests between the wrapped saccades vs fixations, saccades vs blinks,');
    disp('and fixations vs blinks.');disp(sprintf('\n'));
    disp('To do this for each participant isubj, we will first get the events wrapped to the R peak:');
    disp('<strong>saccades = wrap2heart(catt_saccades{isubj});</strong>')
    disp('<strong>fixations = wrap2heart(catt_fixations{isubj});</strong>')
    disp('<strong>blinks = wrap2heart(catt_blinks{isubj});</strong>')
    disp('Then, we will run the t-tests with 2000 permutations, i.e.:')
    disp('<strong>[pval, stats] = catt_bootstrap_diff(saccades.onsets_rad,fixations.onsets_rad,''between'',2000);</strong>');
    disp('Finally, when we have the z-scores from all participants (stored in stats.Z) we can');
    disp('use <strong>catt_z2p</strong> to get group-level p-values');
    input('Press any key to continue');disp(sprintf('\n'));

    %% wrap to rpeak vs rpeak
    for iwrap = 1:2
        switch iwrap
            case 1; catt_opts.wrap2 = 'rpeak';
            case 2; catt_opts.wrap2 = 'twav';
        end

        % initialise the z-score output
        phase_differences.sacc_fix   = [];
        phase_differences.sacc_blink = [];
        phase_differences.fix_blink  = [];

        % loop over participants
        for i = 1:32

            clc; disp(sprintf(['<strong> wrap to ' catt_opts.wrap2 '</strong>: running participant %d/32'],i)); % update researcher

            % get saccade, blink and fixation phases
            saccades  = catt_wrap2heart(catt_saccades{i});
            fixations = catt_wrap2heart(catt_fixations{i});
            blinks    = catt_wrap2heart(catt_blinks{i});

            % compare phases for saccades & fixations, then load in the
            % difference (%) and the zscore into the output structure
            [~, stats] = catt_bootstrap_diff(saccades.onsets_rad,fixations.onsets_rad,'between',2000);
            phase_differences.sacc_fix(i,:) = [stats.difference,stats.Z];

            % repeat for saccades vs blinks
            [~, stats] = catt_bootstrap_diff(saccades.onsets_rad,blinks.onsets_rad,'between',2000);
            phase_differences.sacc_blink(i,:) = [stats.difference,stats.Z];

            % repeat for fixations vs blinks
            [~, stats] = catt_bootstrap_diff(fixations.onsets_rad,blinks.onsets_rad,'between',2000);
            phase_differences.fix_blink(i,:) = [stats.difference,stats.Z];

        end

        disp('Now we will use <strong>catt_z2p</strong> to do get the group-level zscores and pvalues for those ttests:');
        input('Press any key to continue');disp(sprintf('\n'));

        disp(['<strong>Wrapped to ' catt_opts.wrap2 ':</strong>']);

        [P_group,Z_group] = catt_z2p( phase_differences.sacc_fix(:,2) );
        disp(sprintf('Saccades vs fixations: zval = %.3f, group pval = %.3f',[Z_group,P_group]));

        [P_group,Z_group] = catt_z2p( phase_differences.sacc_blink(:,2) );
        disp(sprintf('Saccades vs blinks: zval = %.3f, group pval = %.3f',[Z_group,P_group]));

        [P_group,Z_group] = catt_z2p( phase_differences.fix_blink(:,2) );
        disp(sprintf('Fixations vs blinks: zval = %.3f, group pval = %.3f',[Z_group,P_group]));

        input('Press any key to continue');disp(sprintf('\n'));
    end

    %% ========================================================================
    %  Finally, locking to the rpeak, are the participant preferred phases
    %  for blinks, saccades and fixations correlated?
    %  ========================================================================

    disp('In the final analysis we will ask whether, locking to the rpeak,');
    disp('participants'' preferred phases for fixations, saccades and blinks');
    disp('are correlated.'); disp(sprintf('\n'));

    disp('First, for each event we calculate each participant''s mean cardiac phase, using');
    disp('<strong>y = catt_wrap2heart( catt_saccades{isubj} );</strong>');
    disp('<strong>pref_saccade(isubj) = circ_mean( y.onsets_rad );</strong>');
    disp('We repeat this for each type of event, then to correlate, we use:');
    disp('<strong>[pval, stats] = catt_bootstrap_corr(pref_saccade, ''circular'', pref_blink, ''circular'', 2000);</strong>');
    input('Press any key to continue');disp(sprintf('\n'));

    for i = 1:32

        % wrap events to r/t
        saccades  = catt_wrap2heart(catt_saccades{i});
        fixations = catt_wrap2heart(catt_fixations{i});
        blinks    = catt_wrap2heart(catt_blinks{i});

        % get preffered phase
        pref.saccades(i)  = circ_mean(saccades.onsets_rad);
        pref.fixations(i) = circ_mean(fixations.onsets_rad);
        pref.blinks(i)    = circ_mean(blinks.onsets_rad);

    end

    % Run the correlations
    [pval,stats] = catt_bootstrap_corr( pref.saccades,'circular', ...
        pref.fixations,'circular',...
        1000);
    disp(sprintf('saccades ~ fixations: rho(30) = %.2f, p = %.3f',[stats.rho, pval]));

    [pval,stats] = catt_bootstrap_corr( pref.saccades,'circular', ...
        pref.blinks,'circular',...
        1000);
    disp(sprintf('saccades ~ blinks: rho(30) = %.2f, p = %.3f',[stats.rho, pval]));


    [pval,stats] = catt_bootstrap_corr( pref.blinks,'circular', ...
        pref.fixations,'circular',...
        1000);
    disp(sprintf('blinks ~ fixations: rho(30) = %.2f, p = %.3f',[stats.rho, pval]));


    disp(sprintf('\n'));
    disp('<strong>% -----------------------------------------------------------------------%</strong>');
    disp('<strong>This demo is now over.</strong>');
    disp('<strong>By adapting this code you will hopefully be able to</strong>');
    disp('<strong>analyse all your participant- and group-level data.</strong>');
    disp('<strong>% -----------------------------------------------------------------------%</strong>');

    %% ----------------------------------------------------------------------
    %  End of demo
    %  ----------------------------------------------------------------------

    %% finish up code
catch err
    save err_demo_galvezpol
    rethrow(err)
end

end
