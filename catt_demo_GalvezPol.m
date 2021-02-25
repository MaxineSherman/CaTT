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

function catt_demo_GalvezPol

%% ========================================================================
%  First, we will initialise the toolbox
%  ========================================================================

global catt_opts
catt_init;
catt_opts.qt_method  = 'bazett'; % we don't have the HR data so can't do BPM correction

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

data_files = dir(['data_Galvez-Pol/Saccades and Fixations/Sub*.mat']);
data_files = arrayfun(@(x) ['data_Galvez-Pol/Saccades and Fixations/' x.name],data_files,'UniformOutput',false);

disp('Loading data...');
for i = 1:numel(data_files)
    
    % load data
    load( data_files{i} );
    
    % get separate structures for saccades & fixations (only events where
    % onset < IBI)
    idx                       = 1:size(Saccades_Mx3,1);%find( Saccades_Mx3(:,2) <= Saccades_Mx3(:,4));
    saccades(i).catt.IBI      = Saccades_Mx3(idx,4);
    saccades(i).catt.all_IBI  = num2cell(Saccades_Mx3(idx,4));
    saccades(i).catt.onsets   = Saccades_Mx3(idx,2);
    
   % idx                       = find( Saccades_Mx3(:,9) <= Saccades_Mx3(:,4));
    fixations(i).catt.IBI     = Saccades_Mx3(idx,4);
    fixations(i).catt.all_IBI = num2cell(Saccades_Mx3(idx,4)); 
    fixations(i).catt.onsets  = Saccades_Mx3(idx,9);
    
end

%% ========================================================================
%  Loop wrapping (to r vs t) and data (fixations vs saccades
%  ========================================================================
for i_analysis = 2
    switch i_analysis
        case 1; group = saccades;  analysis_name = 'saccades';
        case 2; group = fixations; analysis_name = 'fixations';
    end
    
    for i_wrap = 2
        switch i_wrap
            case 1; catt_opts.wrap2 = 'rpeak';
            case 2; catt_opts.wrap2 = 'twav';
        end
        
        Z_subjs = [];

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
    
    % update researcher:
    clc;disp(['<strong>' analysis_name, ' wrapped to ' catt_opts.wrap2 ': </strong>' sprintf('running subj %d/%d',[i,numel(data_files)])]);
    
    % estimate qt interval
    group(i).catt = catt_estimate_qt( group(i).catt );
    
    %  Run permutation testing.
    %  This will be done separately for rpeak and t-wave.
    %  We need to save the stats output so we can combine over participants
    %  later on.
    
    [~, stats, group(i).catt] = catt_bootstrap_clust( group(i).catt, 'rao', 1000 );
    Z_subjs(i)   = stats.zscore;
    
end

%% ========================================================================
%  Combine z-scores using schouffer's method
%  ========================================================================
    
disp(['===============================================']);
disp(['% Group stats:' analysis_name ', wrap to ' catt_opts.wrap2]);
disp(['===============================================']);

[Z_group,P_group] = catt_z2p( group );
disp(sprintf('Group zval = %.3f, group pval = %.3f',[Z_group,P_group]));


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
output = catt_consistency(group,8);

%% save data
save(['data_Galvez-Pol/' analysis_name '_' catt_opts.wrap2]);

input('');

    end
end
end
