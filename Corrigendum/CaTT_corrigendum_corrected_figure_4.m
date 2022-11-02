%function CaTT_corrigendum_corrected_figure_4
%
% requires circstat toolbox & CaTT
%
% maxine 13th may 2022

function CaTT_corrigendum_corrected_figure_4

%% Step 0: preparation
close all; clc; 
figure; % initialise fig
rng(11) % for reproducability
red    = [.6 .4 .4];
blue   = [.4 .4 .6];
purple = [.6 .4 .6];
fs     = 20;
global catt_opts; catt_init;

dat2theta = @(ibi,onset) 2*pi.*onset./ibi; % function to calculate cardiac angle from ibi & onset

N         = 500; % number of behavioural reports (eg button presses)
nloops    = 5000; % number of permutation loops

% loop 2 sets of parameters
for i_sim = [1 2]
    switch i_sim

        case 1 % Parameters which generate problems:
               % A) 2 means are very similar
               % B) 1 mean is a multiple of another
               % AND the variances aren't too large (because that'd break
               % the rhythmicity)
            meanRT    = 2000; sdRT   = 75;
            meanIBI   = 1000; sdIBI  = 50;

        case 2 % Parameters from original manuscript
            meanRT    = 400;  sdRT   = 75;
            meanIBI   = 1000; sdIBI  = 50; 
    end

    

    %% Step 1: prepare simulation

    % suppose we have N behavioural reports, performed roughly rhythmically
    RT    = makedist('normal',meanRT,sdRT);
    RT    = truncate(RT,10,inf); % no silly values
    RT    = RT.random(N,1);
    
    % suppose that the participant has a broadly stable HR of ~60bpm.
    % Create some IBIs
    IBIs = normrnd( meanIBI , sdIBI , 4*N , 1);

    % plot these data
    subplot(2,4,1+4-4*(i_sim-1)); histogram(IBIs,20,'FaceColor',red,'LineWidth',2); box on; set(gca,'FontSize',fs,'LineWidth',2,'TickLength',[0 0]); xlabel('IBIs (msec)','FontSize',fs); ylabel('count','FontSize',fs);set(gca,'YTick',[]);
    subplot(2,4,2+4-4*(i_sim-1)); histogram(RT,20,'FaceColor',blue,'LineWidth',2); box on; set(gca,'FontSize',fs,'LineWidth',2,'TickLength',[0 0]); xlabel('RT (msec)','FontSize',fs); ylabel('count','FontSize',fs);set(gca,'YTick',[]);

    % create the time series
    tIBIs   = [0; cumsum(IBIs)]; % add a zero because the first R is at 0
    tRT     = cumsum(RT);

    % express onsets as time-since-last-R (ie time-since-beginning-of-IBI)
    j = 0;
    for i = 1:numel(tRT)

        % compare time of this behaviour to all IBIs
        distance_from_IBI = tRT(i)-tIBIs;

        % the IBI the behaviour fell in is that for which distance_from_IBI is
        % postive and minimal
        wIBI              = find(distance_from_IBI > 0);
        wIBI              = wIBI(end);

        % get onset expressed as time-since-R
        if ~isempty(wIBI)
            j = j+1;
            onsetR(j,1)       = tRT(i) - tIBIs( wIBI );
            IBIR(j,1)         = IBIs(wIBI);
        end
    end

    % express onsets as cardiac angles
     thetas = dat2theta(IBIR,onsetR);

    % get test statistic for non-uniformity
    [~,U] = circ_otest(thetas);

    % plot "empirical" cardiac angles
    subplot(2,4,3+4-4*(i_sim-1)); catt_plot_circ({thetas},{'RT'},'quantity','probability','zero','diastole'); rticks([])
   

    %% Step 2: do permutation test
    permuted_thetas    = nan(1,N*nloops);
    Ustar              = nan(1,nloops);
    for iloop = 1:nloops

        % update
        if ismember(iloop,0:50:10000); clc; disp(sprintf('running loop %d of %d',[iloop,nloops])); end

        % shuffle
        [shuffled_IBIs, shuffled_onsets] = catt_shuffle(IBIR, onsetR);

        % express as theta
        shuffled_thetas = dat2theta(shuffled_IBIs,shuffled_onsets);

        % calculate test statistic
        [~,Ustar(iloop)] = circ_otest(shuffled_thetas);

        % load in thetas
        permuted_thetas = [permuted_thetas, shuffled_thetas];

    end

    %% plot polar histogram of cardiac angles under H0 (ie from shuffling)
    subplot(2,4,4+4-4*(i_sim-1));
    catt_plot_circ({permuted_thetas},{'Null distribution'},'quantity','probability','zero','diastole'); rticks([])

    %% plot a histogram of U* (test statistic under H0) with U (empirical) on top in read
%     subplot(2,3,6); hold on
%     histogram(Ustar,20,'Normalization','probability','FaceColor',[.7 .7 .7]);
%     scatter(U,0.1,100,'filled','MarkerEdgeColor','k','MarkerFaceColor',[.8 .4 .4],'LineWidth',2);

    % format
%     set(gca,'YTick',[]);
%     xlabel('Test statistic under H0 (permuted)');
%     ylabel('count');
%     Z    = (U - mean(Ustar))./std(Ustar);
%     pval = 2*(1-normcdf(abs(Z)));
%     title(sprintf('Z = %.2f, permutation p = %.2f',[Z,pval]));
end
end

%% helpers
%CATT_SHUFFLE pseudo-shuffle IBIs
%
%   usage: [shuffled_IBIs, descending_onsets] = catt_shuffle(IBIs,onsets)
%
%    This script pseudo-shuffles IBIs by first assigning the longest onsets
%    to random IBIs at least as long. In this way, no onset will be assigned to an
%    RR interval in which it could not fit.
%
%    INPUTS:
%     IBIs            - an nx1 or 1xn vector of IBIs
%     onsets          - an nx1 or 1xn  vector of onsets in msecs since the last R peak
%
%    OUTPUTS:
%    shuffled_IBIs       - an nx1 vector of shuffled IBIs
%    descending_onsets   - an nx1 vector of onsets in descending order
%                          (from high to low)
%
% ========================================================================
%  CaTT TOOLBOX v2.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  08/08/2021
% ========================================================================

function [shuffled_IBIs, onsets] = catt_shuffle(IBIs,onsets)

% arrange + sort
IBIs   = reshape(IBIs,1,numel(IBIs));
onsets = reshape(onsets,1,numel(onsets));

% sort
IBIs   = sort(IBIs,'descend');
onsets = sort(onsets,'descend');

% prep
shuffled_IBIs   = nan(size(onsets));

% pair the complicated ones first
i = 1;

while ~isnan(IBIs(end)) && onsets(i) > IBIs(end) && sum(~isnan( IBIs )~=0) % stop when you've run out of IBIs OR when all are ok

    % from all the IBIs greater this onset, pick one (replaced randsample -
    % this is faster)
    try
        idx = find(IBIs >= onsets(i));
        t   = idx(randi(numel(idx)));
    catch;
        clc;
        warning('<strong>Error in catt_shuffle, Line 46-47. Do you have some cases where onset > IBI?</strong>');
    end

    % add it into the shuffled dataset
    shuffled_IBIs(i)   = IBIs(t);

    % remove the selected datapoint from the IBIs
    IBIs(t) = nan;

    % update ticker
    i = i + 1;

end

% shuffle the remaining
shuffled_IBIs(i:end) = shuffle(IBIs(~isnan(IBIs)));
end



