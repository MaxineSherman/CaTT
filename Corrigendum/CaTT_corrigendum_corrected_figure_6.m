function CaTT_corrigendum_corrected_figure_4

% ----------------------------------------------------------------------
% Preparation
% ----------------------------------------------------------------------
close all
subj = 28;
global catt_opts
catt_init;
catt_opts.wrap2 = 'rpeak';

% ----------------------------------------------------------------------
% Plotting parameters
% ----------------------------------------------------------------------
lw    = 4;
fs    = 20;
red   = [.7 .55 .55];
grey  = [.7 .7 .7];
green = [.6 .8 .7];
blue  = [.6 .65 .8];

% ----------------------------------------------------------------------
% Load data
% ----------------------------------------------------------------------

fpath = '/Users/ms547/Dropbox/projects/Comp Psych Postdoc 2019-2021/CaTT/CaTT_current/demo data/Saccades and Fixations';
load([fpath '/Sub' num2str(subj) '_SaccFix_nBlinks']);

% get info
onsets   = Saccades_Mx3(:,9);
IBI      = Saccades_Mx3(:,4);

% sometimes fixations actually occurred in the next RR interval.
% scroll through the data and sort these points out.
idx = find( onsets > IBI );

% if the last element is included kick it out the dataset (not sure
% why this happened - maybe early termination of ECG?)
if idx(end) == numel(onsets)
    onsets    = onsets(1:end-1);
    IBI       = IBI(1:end-1);
    idx       = idx(1:end-1);
end

for i = 1:numel(idx)
    onsets( idx(i) ) = onsets( idx(i) ) - IBI( idx(i) );
    IBI( idx(i) )    = IBI( idx(i) + 1 );
end

% ----------------------------------------------------------------------
% Get true cardiac angles & null distribution
% ----------------------------------------------------------------------

% get true distribution
wrapped   = catt_wrap2heart(onsets,IBI,catt_opts.qt_default);
thetas    = wrapped.onsets_rad;
[~,u]     = circ_raotest(thetas);

% get bootstrapped distribution
nloops = 2000;
bdist  = [];
for i = 1:nloops
    if ismember(i,[100:100:10000]);clc;disp(i);end
    [sIBI,sO] = catt_shuffle(IBI,onsets);
    V = catt_wrap2heart(sO, sIBI, catt_opts.qt_default);
    bdist = [bdist;V.onsets_rad];
    K(i)  = circ_skewness(V.onsets_rad);
    [~,U(i)]  = circ_raotest(V.onsets_rad);
end
mean(K)
% ----------------------------------------------------------------------
% Panel 1: distribution of cardiac angles
% ----------------------------------------------------------------------

subplot(1,4,1);
h = polarhistogram(thetas,20,'Normalization','probability');
h.EdgeColor = red;
h.LineWidth = lw;
h.FaceColor = 'w';
grid off; box on;
thetaticks([]); rticks([]);
%xlabel('Cardiac angles','FontSize',fs)
disp(sprintf('A: skewness = %.4f',circ_skewness(thetas)));

% ----------------------------------------------------------------------
% Panel 2: null distribution of cardiac angles
% ----------------------------------------------------------------------

subplot(1,4,2);
h = polarhistogram(bdist,20,'Normalization','probability');
h.EdgeColor = grey;
h.LineWidth = lw;
h.FaceColor = 'w';
grid off; box on;
thetaticks([]); rticks([]);
%xlabel('Null distribution','FontSize',fs)
disp(sprintf('B: skewness = %.4f',circ_skewness(bdist)));

% ----------------------------------------------------------------------
% Panel 3: distribution of IBIs
% ----------------------------------------------------------------------

subplot(1,4,3); hold on;
h = histogram(IBI,10);
h.LineWidth = lw;
h.FaceColor = green;
h.EdgeColor = 'k';
set(gca,'XLim',[600,1100],'XTick',[700 1000],...
    'LineWidth',lw,'FontSize',fs,'TickLength',[0 0],'YTick',[]);
%xlabel('Fixation onset (ms)','FontSize',fs);
%ylabel('# Trials','FontSize',fs);
box on; 
disp(sprintf('C: skewness = %.4f',skewness(IBI)));

% ----------------------------------------------------------------------
% Panel 4: distribution of onsets
% ----------------------------------------------------------------------

subplot(1,4,4); hold on;
h = histogram(onsets,10);
h.LineWidth = lw;
h.FaceColor = blue;
h.EdgeColor = 'k';
set(gca,'XLim',[0,1100],'XTick',[0 500 1000],...
    'LineWidth',lw,'FontSize',fs,'TickLength',[0 0],'YTIck',[]);
%xlabel('IBI (ms)','FontSize',fs);
%ylabel('# Trials','FontSize',fs);
box on;
disp(sprintf('D: skewness = %.4f',skewness(onsets)));
disp('done');
end
