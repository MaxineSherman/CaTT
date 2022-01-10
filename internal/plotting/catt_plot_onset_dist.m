%CATT_PLOT_ONSET_DIST plot the distribution of onset times relative to the
%last R-peak
%
%   usage: catt_plot_onset_dist(catt)
%
%   You should call this function *after* preprocessing the data.
%   Plotting parameters can be changed in catt_init.
%
%   Each line (row) in the figure is one trial.
%   The line length is the IBI.
%   Each dot on the line is the onset. Trials are sorted by onset time, so
%   you can see the distribution of onsets.
%   If you have multiple responses, then dot colour indicates response.
%
% ========================================================================
%  CaTT TOOLBOX v2.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  08/08/2021
% =========================================================================

function catt_plot_onset_dist(catt)

%% load opts
global catt_opts

%% get parameters
xpad   = -50; % leave 50msec of white space on left side of xaxis
ypad   = 5;   % leave 5 uv on either side of yaxis
hold on;

%% sort trials according to the IBI
try
[~,idx] = sort(catt.wrapped.onsets_msec);
catch
    error('Have you called catt_wrap2heart yet? This is needed for this function');
end
    
%% create colours for plotting

% if there aren't responses (all nan), set all to 1 
if sum(isnan(catt.wrapped.responses)) == numel(catt.wrapped.responses)
    catt.wrapped.responses = ones( size(catt.wrapped.responses) );
end

uresp = unique(catt.wrapped.responses(~isnan(catt.wrapped.responses) ));

if numel(uresp) < 4 % for discrete scales (up to 4)
    cols             = catt_opts.cols.cmap;
    inc              = floor(size(cols,1)/numel(uresp));
    
    for i      = 1:numel(idx)
        r      = find(ismember(uresp,catt.wrapped.responses(i)));
        C(i,:) = cols(inc*r,:);
    end
    C = C(idx,:);

else; C = catt.wrapped.responses(idx); % for continuous scales
end


%% plot full IBI, sorted by time since last R peak
for i = 1:numel(idx)
    plot( linspace( 0, catt.wrapped.IBIs(idx(i)) ), i*ones(100,1) ,'k'); 
end
scatter( catt.wrapped.onsets_msec(idx), 1:numel(idx), catt_opts.plot.ms, C, 'filled'); % place a dot where the onset was
    
%% format
set(gca, ...
    'YTick', [], ...
    'FontSize', catt_opts.plot.axfs, ...
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
xlabel({'Time since last';'R peak (msec)'},'FontSize',catt_opts.plot.lfs);
ylabel('Trials','FontSize',catt_opts.plot.lfs);
title({'Onset time (dots) relative to the last R peak'; 'Line length = IBI'},'FontSize',catt_opts.plot.lfs);

%% set legend
colormap(catt_opts.cols.cmap);
h = colorbar;
h.Label.String = 'Response';
h.Label.FontSize = catt_opts.plot.lfs;

end