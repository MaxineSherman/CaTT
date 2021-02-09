%INTERO_DEMO demo for interoception toolbox  
%   usage: intero_demo_intero_demo_GalvezPol
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

function intero_demo_GalvezPol

%% ========================================================================
%  First, we will initialise the toolbox
%  ========================================================================

global intero_opts
intero_init;

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
    
    disp(['===============================================']);
    disp(['% Participant ' num2str(i)]);
    disp(['===============================================']);
    
    load( data_files{i} );
    group(i).intero.IBI    = Saccades_Mx3(:,4);
%   group(i).intero.onsets = Saccades_Mx3(:,2); % saccades
    group(i).intero.onsets = Saccades_Mx3(:,9); % fixations
    

    %% first, run the standard rayleigh test, timelocking to either R or T
    
    intero_opts.wrap2 = 'rpeak';
    [pval, rtest_z_r(i)] = circ_rtest( intero_wrap2heart( group(i).intero.onsets, group(i).intero.IBI ) );
    disp(sprintf('Rayleigh test, wrapped to rpeak: z = %.3f, p = %.3f',[rtest_z_r(i),pval]));
    
    intero_opts.wrap2 = 'twav';
    [pval, rtest_z_t(i)] = circ_rtest( intero_wrap2heart( group(i).intero.onsets, group(i).intero.IBI ) );
    disp(sprintf('Rayleigh test, wrapped to t-wave: z = %.3f, p = %.3f',[rtest_z_t(i),pval]));
    
    %% The crucial test is to do permutation testing.
    %  This will be done separately for rpeak and t-wave.
    %  We need to save the stats output so we can combine over participants
    %  later on.
    
    intero_opts.wrap2 = 'rpeak';
    [~, stats, group_rpeak(i).intero] = intero_bootstrap_clust( group(i).intero, 'omnibus', 1000 );
    z_r(i) = stats.zscore;
    
    intero_opts.wrap2 = 'twav';
    [~, stats, group_twav(i).intero] = intero_bootstrap_clust( group(i).intero, 'omnibus', 1000 );
    z_t(i) = stats.zscore;
end

%% ========================================================================
%  Combine z-scores using schouffer's method
%  ========================================================================
    
disp(['===============================================']);
disp(['% Group stats']);
disp(['===============================================']);

[rZ_r,P_r] = intero_z2p( rtest_z_r );
disp(sprintf('wrapping to r-peak (vanilla Rayleigh): Group zval = %.3f, group pval = %.3f',[rZ_r,P_r]));

[rZ_t,P_t] = intero_z2p( rtest_z_t );
disp(sprintf('wrapping to t-wave (vanilla Rayleigh): Group zval = %.3f, group pval = %.3f',[rZ_t,P_t]));

[Z_r,P_r] = intero_z2p( group_rpeak );
disp(sprintf('wrapping to r-peak (permutation): Group zval = %.3f, group pval = %.3f',[Z_r,P_r]));

[Z_t,P_t] = intero_z2p( group_twav );
disp(sprintf('wrapping to t-wave (permutation): Group zval = %.3f, group pval = %.3f',[Z_t,P_t]));

%% ========================================================================
%  To what extent are the measures correlated?
%  ========================================================================
figure;

subplot(2,2,1);
x = rtest_z_r; y = rtest_z_t;
scatter( x, y, 100, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [.8,.8,.8], 'LineWidth', 3);
set(gca,'LineWidth',3,'FontSize',16,'TickLength',[0,0]);
xlabel({'Rayleigh test';'(lock to R)'},'FontSize',16);
ylabel({'Rayleigh test';'(lock to T)'},'FontSize',16);
display_corr(x,y,'spearman');
box on
title({'Locking to R vs. T';'(Rayleigh)'},'FontSize',16)

subplot(2,2,2);
x = rtest_z_r; y = z_r;
scatter( x, y, 100, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [.8,.8,.8], 'LineWidth', 3);
set(gca,'LineWidth',3,'FontSize',16,'TickLength',[0,0]);
xlabel({'Rayleigh test';'(lock to R)'},'FontSize',16);
ylabel({'Permutation test';'(lock to R)'},'FontSize',16);
display_corr(x,y,'spearman');
box on
title({'Rayleigh vs. Permutation';'(lock to R)'},'FontSize',16)

subplot(2,2,3);
x = z_r; y = z_t;
scatter( x, y, 100, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [.8,.8,.8], 'LineWidth', 3);
set(gca,'LineWidth',3,'FontSize',16,'TickLength',[0,0]);
xlabel({'Permutation test';'(lock to R)'},'FontSize',16);
ylabel({'Permutation test';'(lock to T)'},'FontSize',16);
display_corr(x,y,'spearman');
box on
title({'Locking to R vs. T';'(Permutation)'},'FontSize',16)

subplot(2,2,4);
x = rtest_z_t; y = z_t;
scatter( x, y, 100, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [.8,.8,.8], 'LineWidth', 3);
set(gca,'LineWidth',3,'FontSize',16,'TickLength',[0,0]);
xlabel({'Rayleigh test';'(lock to T)'},'FontSize',16);
ylabel({'Permutation test';'(lock to T)'},'FontSize',16);
display_corr(x,y,'spearman');
box on
title({'Rayleigh vs. Permutation';'(lock to T)'},'FontSize',16)

print -dpng figures/correlations_RT_permutationRayleigh
print -depsc figures/correlations_RT_permutationRayleigh

%% ========================================================================
%  Make plots with results
%
%  This is going to be structured as...
%    Rayleigh    (lock to R)     Rayleigh    (lock to T)
%    Permutation (lock to R)     Permutation (lock to T)
%  ========================================================================

% prepare figure
figure;
lw    = 3;
fs    = 16;
labs  = {'Z (r-peak)','Z (t-wave)'};

% gather things to plot
indv_z     = { rtest_z_r,  rtest_z_t;   z_r,        z_t }; % individual participant z scores
group_z    = [ rZ_r,       rZ_t;        Z_r,        Z_t]; % group-level z-scores
cols       = { [.8 .6 .7], [.7 .75 .8]; [.8 .3 .4], [.2 .25 .7]}; % colours


for itest = 1:2 
    for ilock = 1:2
        
        %% plot & format histogram
        subplot(2,2,2*(itest-1) + ilock); hold on;
        h = histogram( indv_z{ itest, ilock } , 20 );
        h.LineWidth = 2; h.FaceColor = cols{ itest, ilock };
        set(gca,'LineWidth',lw,'FontSize',fs,'TickLength',[0,0],'YLim',[0,10]);
        xlabel(labs{ilock},'FontSize',fs);
        ylabel('# Participants','FontSize',fs);
        
        %% plot p = 0.05 line
        plot( repmat(1.96,100,1), linspace(0,10), 'k--', 'LineWidth', lw);
        if itest == 2
           plot( repmat(-1.96,100,1), linspace(0,10), 'k--', 'LineWidth', lw);
        end
            
        box on
        
        %% add marker for the group z at y = 5 
        %  ( row 2 only )
        if itest == 2
            h = plot( group_z( itest, ilock ), 5 );
            h.Marker          = 'p';
            h.MarkerSize      = 20;
            h.MarkerFaceColor = cols{ itest, ilock };
            h.Color           = 'k';
            h.LineWidth       = lw;
        end
    end
end

print -dpng figures/histo_TR_permuteRayleigh
print -depsc figures/histo_TR_permuteRayleigh

save data_Galvez-Pol/fixations;

disp('')
