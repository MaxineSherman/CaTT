%INTERO_PLOT_OVER_ECG plot the mean time of each response time over ECG
%
%   usage: intero_plot_over_ECG(intero)
%
% [BROKEN!!!]
% ========================================================================
%  INTERO TOOLBOX v1.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================

function intero_plot_over_ECG(intero)

% ========================================================================
%  Get parameters
% =========================================================================

global intero_opts

% get colours
% create colors
cmap    = intero_opts.cols.cmap;
ngroups = numel(unique(intero.responses));
if ngroups > 10
    cols{1} = intero_opts.cols.cmap( median(1:size(intero_opts.cols.cmap,1)), : );
else
    for i = 1:ngroups
        cols{i} = cmap(i*floor(size(cmap,1)/ngroups),:);
    end
end

hold on;
padding = 200; % in samples

% ========================================================================
%  Gather participant's ECG data
% =========================================================================

for i = 1:numel(intero.ECG.raw)
    
    %% take the R to R interval, in samples, with a little bit on each side
    try
        
        % find the timestamps for the straddling r-peaks, in *samples*
        rbefore = intero.tlock.rPeaks{i}( intero.tlock.onset_loc{i} == -1  );
        rafter  = intero.tlock.rPeaks{i}( intero.tlock.onset_loc{i} ==  1  );
       
    
        % get the raw ecg from this epoch + smooth it to make it nice.
        % load it into ECG
        ecg = intero.ECG.raw{i}(rbefore:rafter);
        ecg = detrend(smooth(wdenoise(ecg,2,'Wavelet','db1')));
        ECG(i,1:numel(ecg)) = ecg;

    end
end

% ========================================================================
%  Plot responses over ECG
% =========================================================================

% plot mean ECG with 95% CI
X  = 2:2:2*size(ECG,2);
M  = nanmean(ECG,1);
CI = 1.96*nanstd(ECG)./sqrt(i);
[hline,hpatch] = boundedline(X,M,CI);

% get yaxis lower limit, for later
ymin    = min( M - CI );
resploc = 1;

% format line & patch
hline.LineWidth  = intero_opts.plot.lw;
hline.Color      = intero_opts.cols.grey;
hpatch.FaceColor = intero_opts.cols.grey;
hpatch.FaceAlpha = intero_opts.cols.alpha;

% plot R0 responses, in msec, below the lower limit of ECG
idx = find( intero.responses == 0 );
scatter( intero.tlock.onsets_r_msec(idx), repmat(ymin*resploc,numel(idx),1) , ...
         100, ...
         'MarkerFaceColor', cols{1},...
         'MarkerEdgeColor','k',...
         'LineWidth',1)
     
% plot R2 responses, in msec, below the lower limit of ECG
idx = find( intero.responses == 1 );
scatter( intero.tlock.onsets_r_msec(idx), repmat(ymin*(0.2+resploc),numel(idx),1) , ...
         100, ...
         'MarkerFaceColor', cols{2},...
         'MarkerEdgeColor','k',...
         'LineWidth',1)

% complete formatting
set(gca,'TickLength',[0 0],...
        'LineWidth',intero_opts.plot.lw,...
        'YTick',[],...
        'FontSize',intero_opts.plot.axfs);
box on;
xlabel('Time since last R peak (msec)','FontSize',intero_opts.plot.lfs);
ylabel('Voltage','FontSize',intero_opts.plot.lfs);
title({'When in the cardiac cycle';'were the onsets?'},'FontSize',intero_opts.plot.lfs);
