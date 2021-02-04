function intero_manuscript_examples

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

data_files = dir(['data_Galvez-Pol/Blinks Data/Sub*.mat']);
data_files = arrayfun(@(x) ['data_Galvez-Pol/Blinks Data/' x.name],data_files,'UniformOutput',false);


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
    intero_group(i).intero.onsets = Saccades_Mx2(:,2);
    intero_group(i).intero.IBI    = Saccades_Mx2(:,3);

    %% first, run the standard rayleigh test, timelocking to either R or T
    intero_opts.wrap2 = 'rpeak';
    [pval, z] = circ_rtest( intero_wrap2heart( intero_group(i).intero.onsets, intero_group(i).intero.IBI ) );
    disp(sprintf('Rayleigh test, wrapped to rpeak: z = %.3f, p = %.3f',[z,pval]));
    
    intero_opts.wrap2 = 'twav';
    [pval, z] = circ_rtest( intero_wrap2heart( intero_group(i).intero.onsets, intero_group(i).intero.IBI ) );
    disp(sprintf('Rayleigh test, wrapped to t-wave: z = %.3f, p = %.3f',[z,pval]));
    
    %% The crucial test is to do permutation testing.
    %  This will be done separately for rpeak and t-wave.
    %  We need to save the stats output so we can combine over participants
    %  later on.
    
    intero_opts.wrap2 = 'rpeak';
    [pval_rpeak(i,1), stats_rpeak{i,1}] = intero_bootstrap_clust( intero_group(i) );
    
    intero_opts.wrap2 = 'twav';
    [pval, z] = circ_rtest( intero_wrap2heart( intero.onsets, intero.IBI ) );
   [pval_twave(i,1), stats_twave{i,1}] = intero_bootstrap_clust( intero_group(i) );
   
end

%% ========================================================================
%  Combine z-scores using schouffer's method
%  ========================================================================
    
[Z,P] = 
