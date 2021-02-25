%INTERO_PLOT_DESCRIPTIVES plot the mean time of each response time over ECG
%
%   usage: intero_plot_descriptives(intero)
%
% ========================================================================
%  INTERO TOOLBOX v1.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================

function intero_plot_descriptives(intero)

% ========================================================================
%  Set parameters for plotting
% =========================================================================

p.lfs  = 15; % title/label font size
p.axfs = 15; % axis font size
p.ms   = 50; % marker size
p.lw   = 2; % line width
p.col  = [.9 .3 .6];
p.hbins = 12;

p.ECG.alpha    = 0.2;
p.ECG.col_line = [.9 .3 .6];
p.ECG.col_R1   = [.2 .8 .5];
p.ECG.col_R2   = [.4 .6 .8];
p.ECG.resploc  = 1.1; % 10% below ECG
hold on;
padding = 200; % in samples

% ========================================================================
%  Panel 1: histogram of participant's HRV
% =========================================================================

subplot(2,2,1);
X = intero.proc.HRV;
h = histogram(X,p.hbins);

% format
h.LineWidth = p.lw;
h.FaceColor = p.col;
set(gca,'LineWidth', p.lw,...
        'TickLength',[0 0],...
        'FontSize', p.axfs);
xlabel(['HRV (' intero.proc.HRV_method ')'],'FontSize',p.lfs);
ylabel('Trial count','FontSize',p.lfs);

% ========================================================================
%  Panel 2: histogram of participant's IBIs
% =========================================================================

subplot(2,2,2);
X = intero.proc.IBI;
h = histogram(X,p.hbins);

% format
h.LineWidth = p.lw;
h.FaceColor = p.col;
set(gca,'LineWidth', p.lw,...
        'TickLength',[0 0],...
        'FontSize', p.axfs);
xlabel('IBI','FontSize',p.lfs);
ylabel('Trial count','FontSize',p.lfs);


% ========================================================================
%  Panel 3: rose of wrapped_onsets as a function of report
% =========================================================================

subplot(2,2,3);
X = intero.proc.wrapped_onsets;
h = histogram(X,p.hbins);

% format
h.LineWidth = p.lw;
h.FaceColor = p.col;
set(gca,'LineWidth', p.lw,...
        'TickLength',[0 0],...
        'FontSize', p.axfs);
xlabel('IBI','FontSize',p.lfs);
ylabel('Trial count','FontSize',p.lfs);
