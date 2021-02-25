%% ========================================================================
%CATT_INIT initialise parameters for CaTT toolbox  
%   usage: catt_opts = catt_init
%
%   Initialises the default simulation & plotting parameters used by this
%   toolbox. Change these defaults below.
%
% ========================================================================
%  CaTT TOOLBOX v1.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================

function catt_opts = catt_init

global catt_opts

%% ========================================================================
%  Set initial preprocessing parameters
% =========================================================================

catt_opts.fs        = 512; % sample rate
catt_opts.BP_filter = chebyshevI_bandpass(catt_opts.fs); % create the filter for r-peak detection

%% ========================================================================
%  Set HRV parameters
% Options are: 'RMSSD' 
%              'SDNN'  
%              'SDSD' 
%              'pNN50' 
%              'pNN20' 
%
% See catt_HRV for details.
% =========================================================================

catt_opts.HRV_method = 'RMSSD'; 

%% ========================================================================
%  Set cardiac timing parameters
% =========================================================================

% if you want to timelock to the twave then you need to set the QT
% interval. This parameter is ignored if you lock to R.
% The options are:
%   - 'fixed': fixed value, set as catt_opts.qt_default
%   - 'sagie': estimate from Sagie's formula
%   - 'bazett': estimate from Bazett's formula
%   - 'fridericia': estimate from Fridericia's formula
catt_opts.qt_method  = 'bazett'; 

% set the default/assumed average q to end of t interval (msec)
catt_opts.qt_default = 400;

% get the default/assumed average q to peak-r interval (msec)
catt_opts.qr = 50;

% what do you want to timelock to?
% options are: 
%     - 'twav' (systole)
%     - 'rpeak' (diastole)
catt_opts.wrap2     = 'twav';

%% ========================================================================
%  Set initial plotting parameters
% =========================================================================

%% the basics
catt_opts.plot.lw     = 2;  % line width
catt_opts.plot.axfs   = 14; % font size for axis, e.g. ticks
catt_opts.plot.lfs    = 16; % font size for labels, e.g. title
catt_opts.plot.ms     = 50; % marker size, e.g. for scatter plots

%% set colour map
% colormap shows strange behaviour on matlab 2020b 
% if it doesn't work just load the crameri colormap from the backup
% mat file located in /dependencies.
try 
catt_opts.cols.cmap   = crameri('romaO'); 
catch
    load romaO_color_map; 
    catt_opts.cols.cmap = romaO_color_map;
end

catt_opts.cols.grey   = [0.7 0.7 0.7]; % grey will be a light grey.
catt_opts.cols.alpha  = 0.5; % transparency

%% legend settings
catt_opts.plot.legOri = 'Horizontal';   % legends will be horizontal
catt_opts.plot.legLoc = 'SouthOutside'; % legends will be located at the bottom of the plot

%% grid settings
catt_opts.plot.grid   = 'on';

%% settings specific to circular plots
catt_opts.plot.circ_nbins = 15;

end

