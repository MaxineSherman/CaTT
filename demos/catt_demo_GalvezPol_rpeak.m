%CATT_DEMO_GalvezPol demo for interoception toolbox  
%   usage: catt_demo_GalvezPol
%
%   The demo will use previously published data to illustrate how to do
%   group-level analyses
%
% ========================================================================
%  INTERO TOOLBOX v1.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================

function catt_demo_GalvezPol_rpeak

%% ========================================================================
%  First, we will initialise the toolbox
%  ========================================================================

global catt_opts
catt_init;

% set the parameters we want
catt_opts.wrap2      = 'rpeak';
catt_opts.qt_method  = 'fixed'; % we don't have the HR data so can't do BPM correction


%% ========================================================================
%  We'll be running analyses on the blinks data presented in Galvez-Pol et al.
%  (2019), which can be found here: https://osf.io/ye3rg/
%
% Galvez-Pol, A., McConnell, R., & Kilner, J. M. (2020). 
% Active sampling in visual search is coupled to the cardiac cycle.
% Cognition, 196, 104149.
%
% Start by finding the data
%  ========================================================================

for i_analysis = 3
    switch i_analysis
        case 1
            dirName = 'Blinks Data';
            analysisName = 'blinks';
            idx_ibi      = 3;
            idx_onset    = 2;
        case 2
            dirName = 'Saccades and Fixations';
            analysisName = 'saccades';
            idx_ibi      = 4;
            idx_onset    = 2;
        case 3
            dirName = 'Saccades and Fixations';
            analysisName = 'fixations';
            idx_ibi      = 4;
            idx_onset    = 9;
    end
            
data_files = dir(['data_Galvez-Pol/' dirName '/Sub*.mat']);
data_files = arrayfun(@(x) ['data_Galvez-Pol/' dirName '/' x.name],data_files,'UniformOutput',false);

%% ========================================================================
%  The question here is as follows: are blinks more likely to occur at some
%  particular point in the cardiac cycle.
%
%  To test this, we first need to place the data into a form the toolbox
%  can understand (i.e. into an intero structure).
%
%  Next, we'll run a range of different analyses for comparison purposes.
%  ========================================================================

for i = 1:numel(data_files)
    
    % update researcher
    clc;disp(sprintf('running participant %d of %d',[i,numel(data_files)]));
    
    % load data
    load( data_files{i} );
    switch dirName
        case 'Saccades and Fixations'
            group(i).catt.IBI     = Saccades_Mx3(:,idx_ibi);
            group(i).catt.all_IBI = num2cell(group(i).catt.IBI);
            
            if i_analysis == 2 % saccade onset time
                group(i).catt.onsets  = Saccades_Mx3(:,idx_onset);
            elseif i_analysis == 3 % mean fixation time
                group(i).catt.onsets  = Saccades_Mx3(:,idx_onset) + Saccades_Mx3(:,10)./2;
            end
        case 'Blinks Data'
            group(i).catt.IBI     = Saccades_Mx2(:,idx_ibi);
            group(i).catt.all_IBI = num2cell(group(i).catt.IBI);
            group(i).catt.onsets  = Saccades_Mx2(:,idx_onset);
    end
    
    % estimate qt interval
    group(i).catt = catt_estimate_qt( group(i).catt );
    
    %  Run permutation testing.
    %  This will be done separately for rpeak and t-wave.
    %  We need to save the stats output so we can combine over participants
    %  later on.
    
    [~, stats, group_rpeak(i).catt] = catt_bootstrap_clust( group(i).catt, 'rao', 1000 );
    Z_subjs(i)   = stats.zscore;
    
end

%% ========================================================================
%  Combine z-scores using schouffer's method
%  ========================================================================
    
disp(['===============================================']);
disp(['% Group stats']);
disp(['===============================================']);

[Z_group,P_group] = catt_z2p( group_rpeak );
disp(sprintf('wrapping to r-peak (permutation): Group zval = %.3f, group pval = %.3f',[Z_group,P_group]));


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
        
print('-dpng',['figures/Fig4A_rpeak_' analysisName]);
print('-depsc',['figures/Fig4A_rpeak_' analysisName]);

%% run consistency
output = catt_consistency(group_rpeak);

save(['data_Galvez-Pol/rpeak_' analysisName]);

input('');
end
