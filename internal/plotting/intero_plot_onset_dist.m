%INTERO_PLOT_ONSET_DIST plot the distribution of onset time relative to the
%last R-peak
%
%   usage: intero_plot_onset_dist(intero)
%
% ========================================================================
%  INTERO TOOLBOX v1.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================

function intero_plot_onset_dist(intero)

%% load opts
global intero_opts

%% get parameters
xpad   = -50; % leave 50msec of white space on left side of xaxis
ypad   = 5;   % leave 5 uv on either side of yaxis
hold on;

%% sort trials according to where in the IBI the response came
[~,idx] = sort(intero.tlock.onsets_r_msec);
    
%% create colours for plotting
uresp = unique(intero.responses);

if numel(uresp) < 4 % for discrete scales (up to 4)
    cols             = intero_opts.cols.cmap;
    inc              = floor(size(cols,1)/numel(uresp));
    
    for i      = 1:numel(idx)
        r      = find(ismember(uresp,intero.responses(i)));
        C(i,:) = cols(inc*r,:);
    end

else; C = intero.responses(idx); % for continuous scales
end


%% plot full IBI, sorted by time since last R peak
for i = 1:numel(idx)
    plot( linspace( 0, intero.tlock.onsets_IBI(idx(i)) ), i*ones(100,1) ,'k'); 
end
scatter( intero.tlock.onsets_r_msec(idx), 1:numel(idx), intero_opts.plot.ms, C, 'filled'); % place a dot where the onset was
    
%% format
set(gca, ...
    'YTick', [], ...
    'FontSize', intero_opts.plot.axfs, ...
    'TickLength',[0 0]);

%% set x limits
xlim    = get(gca,'XLim');
xlim(1) = xpad;
set(gca,'XLim',xlim);

%% set y limits
ylim = get(gca,'YLim');
ylim(2) = ylim(2)+ypad;
ylim(1) = ylim(1)-ypad;
set(gca,'YLim',ylim);

%% set labels
xlabel({'Time since last';'R peak (msec)'},'FontSize',intero_opts.plot.lfs);
ylabel('Trial','FontSize',intero_opts.plot.lfs);
title({'Onset time (dots) relative';'to the last R peak'},'FontSize',intero_opts.plot.lfs);

%% set legend
colormap(intero_opts.cols.cmap);
h = colorbar;
h.Label.String = 'Response';
h.Label.FontSize = intero_opts.plot.lfs;

end