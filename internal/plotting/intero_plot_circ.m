%INTERO_PLOT_CIRCHIST circular histogram for two responses 
%
%   usage: intero_plot_circhist( data, labels, [varargin])
%
%   INPUTS:
%
%   data       -  An ngroups x 1 cell array containing the data (in radians)
%                 for each group you want to plot in separate cells.
%                 For example, if you only have one group you want to plot
%                 and the data are 0, pi/2 and pi then you would enter
%                 {[0, pi/2, pi]}.
%
%  labels      - An ngroups x 1 cell array containing the names of each
%                group. This is used in the legend. For example, if you are plotting data
%                separately for "fear" and "neutral" trials you would enter
%                {'Fear','Neutral'}.
%
%   OPTIONAL:
%
%   'participants':  'on' or 'off' [default is 'off']
%                    Toggle this to plot individual data points
%
%    'histogram':    'on' or 'off' [default is 'on']
%                    Toggle this to plot the circular histogram of data for
%                    each group
%
%    'mean':        'on' or 'off' [default is 'off']
%                    Toggle this to plot the mean resultant vector
%                    separately for each group.
%
%    'quantity':    'probability' or 'count' [default is 'probability']
%                    Select whether histograms display the number of items
%                    in each bin (count) or the probability of an angle
%                    being in that bin (probability).
%
%    'zero':         'T' or 'R' [default is R]. Specifies whether 0/2pi is
%                     systole (when you lock to the r-peak) or diastole
%                     (for when you lock to the t-wave)
%                     
%                 
%   Example:
%
%     1. Call a default circular plot.
%        This will display the circular histogram only
%        Suppose we have data from 2 conditions.
%        The data are radians from the t-wave, separatly for trials where
%        the participant rated an ambiuous emotion as "fear" or "neutral".
%        
%        intero_plot_circ( {neutral, fear}, {'neutral','fear'} )
%
%     2.  As before, but add the individual data points too
%
%        intero_plot_circ( {neutral, fear}, {'neutral','fear'}, 'participants', 'on' )
%
%     3.  Plot radians only for the fear group.
%         Plot the individual data points and the mean resultant vector
%         only
%
%        intero_plot_circ( {fear}, {'fear'}, 'participants', 'on' , 'mean', 'on', 'histogram', 'off' )
%                                
% ========================================================================
%  INTERO TOOLBOX v1.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================

function intero_plot_circ(data, labels, varargin)

% get opts
global intero_opts

% open plot
ax = get(gca);%ax = polaraxes;

% ========================================================================
%  Interpret inputs
% =========================================================================
ngroups = numel(data);

% check labels and data have the same number of entries
assert(numel(labels) == numel(data),'Error in <strong>intero_plot_circ</strong>: data and labels should have the same number of entries');

% set defaults
plot_subjs = false;
plot_hist  = true;
plot_mean  = false;
plot_norm  = 'count';
zero_point = 'systole';

% interpret varargin
if nargin > 2
    for i = 1:2:numel(varargin)
        
        if strcmpi(varargin{i},'participants')
            plot_subjs = strcmpi(varargin{i+1},'on');
            
        elseif strcmpi(varargin{i},'histogram')
            plot_hist = strcmpi(varargin{i+1},'on');
            
        elseif strcmpi(varargin{i},'mean')
            plot_mean = strcmpi(varargin{i+1},'on');
            
        elseif strcmpi(varargin{i},'quantity')
            assert(ismember(varargin{i+1},{'probability','count'}),'Error in <strong>intero_plot_circ</strong>: quantity should be probability or counts.');
            plot_norm = varargin{i+1};
            
        elseif strcmpi(varargin{i},'zero')
            zero_point = varargin{i+1};
            
        else warning(['Warning in <strong>intero_plot_circ</strong>: Unknown input ' varargin{i} '. Skipping...']);

        end
    end
end
% ========================================================================
%  Set parameters for plotting
% =========================================================================

% create colors
cmap    = intero_opts.cols.cmap(15:end-15,:);
for i = 1:ngroups
    cols{i} = cmap(i*floor(size(cmap,1)/ngroups),:);
end

% create axis labels
switch zero_point
    case 'diastole'
        ticks  = {'Diastole (T)','','',...
            'T-R midpoint','','',...
            'Systole (R)','','',...
            'R-T midpoint','',''};
        
    case 'systole'
        ticks  = {'Systole (R)','','',...
            'R-T midpoint','','',...
            'Diastole (T)','','',...
            'T-R midpoint','',''};
        
end
% ========================================================================
%  Plot histogram
% =========================================================================

if plot_hist
    for i = 1:ngroups
    
        h1 = polarhistogram(data{i},intero_opts.plot.circ_nbins,'Normalization',plot_norm);
        h1.LineWidth    = intero_opts.plot.lw;
        h1.FaceColor    = cols{i};
        h1.FaceAlpha    = intero_opts.cols.alpha;
        h1.EdgeColor    = cols{i};
        hold on
    end
end

% ========================================================================
%  Plot mean resultant vector
% =========================================================================

if plot_mean
    for i = 1:ngroups
        
        theta           = circ_mean(reshape(data{i},numel(data{i}),1));
        r               = circ_r(reshape(data{i},numel(data{i}),1));
        
         polarplot([theta,theta],[0,r],'Color',cols{i},'LineWidth',intero_opts.plot.lw*1.5)       
%         switch theta > 0
%             case 1
%                 polarplot(theta*ones(100,1),linspace(0,r),'Color',cols{i},'LineWidth',intero_opts.plot.lw*1.5)       
%             case 0
%                 polarplot(theta*ones(100,1),linspace(r,0),'Color',cols{i},'LineWidth',intero_opts.plot.lw*1.5)  
%         end
        hold on
    end
end

% ========================================================================
%  Plot individual data points
% =========================================================================

if plot_subjs
    
    r = get(gca); r = r.RLim(2);
    
    for i = 1:ngroups
       
        polarscatter(  data{i}, ...
                       (1+i*0.1)*r*ones(size(data{i})), ...
                       intero_opts.plot.ms,...
                      'MarkerFaceColor', cols{i}, ...
                      'MarkerEdgeColor', cols{i});  
       hold on           
    end
end

% ========================================================================
%  Format
% =========================================================================

set(gca, 'ThetaTickLabelMode','manual',...
         'ThetaTickLabel',ticks,...
         'FontSize',intero_opts.plot.axfs, ...
         'ThetaZeroLocation','right',...
         'Rgrid',intero_opts.plot.grid,...
         'ThetaGrid',intero_opts.plot.grid,...
         'LineWidth',intero_opts.plot.lw/2,...
         'GridColor',intero_opts.cols.grey);

% add legend
l = legend(labels,'Location',intero_opts.plot.legLoc,'Orientation',intero_opts.plot.legOri);
l.FontSize = intero_opts.plot.lfs;
l.Box = 'off';

end
