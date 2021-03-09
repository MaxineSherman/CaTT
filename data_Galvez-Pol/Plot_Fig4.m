% plot galvez pol figures
clear all;close all; load fixations;figure;

global intero_opts;
intero_init;
intero_opts.wrap2 = 'rpeak';

%% plotting params
subjnum = 5;
lw = 3;
fs = 18;

%% get bootstrap distribution (for panel B)
v = [];
for i = 1:1000
    v = [v;intero_wrap2heart( group(subjnum).intero.onsets, Shuffle(group(subjnum).intero.IBI ))];
end

%% plot distribution of IBIs (fig. C)
subplot(1,4,3); hold on; box on;
h = histogram(group(subjnum).intero.IBI,10);
h.LineWidth = lw;
h.FaceColor = [.5 .7 .6];
set(gca,'LineWidth', lw,...
    'FontSize',fs,...
    'TickLength',[0,0],...
    'YTick',[]);
xlabel('IBI (msec)','FontSize',fs);
ylabel('# Trials','FontSize',fs);

%% plot distribution of onsets (fig. D)
subplot(1,4,4); hold on; box on;
h = histogram(group(subjnum).intero.onsets,10);
h.LineWidth = lw;
h.FaceColor = [.5 .6 .7];
set(gca,'LineWidth', lw,...
    'FontSize',fs,...
    'TickLength',[0,0],...
    'YTick',[]);
xlabel('onset (msec)','FontSize',fs);
ylabel('# Trials','FontSize',fs);

%% plot distribution of cardiac angles (Fig. A)
subplot(1,4,1); hold on; box on;

% plot uniformity
thetas      = intero_wrap2heart( group(subjnum).intero.onsets, group(subjnum).intero.IBI );
h           = rose(thetas,20);
h.Color     = [.7 .5 .5];
h.LineWidth = lw;

set(gca,'LineWidth', lw,...
    'FontSize',fs,...
    'TickLength',[0,0],...
    'XLim',[-250 250],...
    'YLim',[-250 250],...
    'XTick',[],...
    'YTick',[]);
xlabel('Cardiac angles','FontSize',fs);

%% plot distribution of H0 (Fig. B)   
subplot(1,4,2); hold on; box on;

% plot uniformity
thetas      = intero_wrap2heart( group(subjnum).intero.onsets, group(subjnum).intero.IBI );
h           = rose(v,20);
h.Color     = [.7 .7 .7];
h.LineWidth = lw;

set(gca,'LineWidth', lw,...
    'FontSize',fs,...
    'TickLength',[0,0],...
    'XTick',[],...
    'YTick',[]);
xlabel('Null distribution','FontSize',fs);


print -dpng data_galvez-pol/Fig4
print -depsc data_galvez-pol/Fig4