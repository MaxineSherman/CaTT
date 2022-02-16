%% ========================================================================
%CATT_INIT initialise parameters for CaTT toolbox  
%   usage: catt_opts = catt_init
%
%   Initialises the default simulation & plotting parameters used by this
%   toolbox. Change these defaults below.
%
% Version 2 - change log
%
% i)  implemented t-wave detection (see catt_detect_t)
% ii) added threshold for rpeak detection algorithm as a parameter
% iii) added removal of RR intervals based on IBI
%
% update 26/01/2021: if CaTT has not been added to path then the toolbox throws an informative error & gives instructions on how to do it
% ========================================================================
%  CaTT TOOLBOX v2.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  08/08/2021
% ========================================================================

function catt_opts = catt_init

% ========================================================================
% Check CaTT has been added to path
% ========================================================================

if exist('chebyshevI_bandpass.m')~=2
    clc;
    disp('<strong>CaTT: Please add CaTT (with all it''s subfolders) to your path before initialising the toolbox.</strong>');
    disp('<strong>If you are in the main CaTT folder, write addpath(genpath(cd)) at the command line</strong>');
    error('Error: CaTT not fully added to path');
end

%% ========================================================================
%  Initialise 
% =========================================================================

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
%  Set parameters for r-peak detection
% =========================================================================

% the threshold will depend on the rough ECG amplitude of your r-peaks.
% it is expressed in arbitrary units.
% you should set it so that the code thresholds higher than your t-wave amplitude, and lower than
% your rpeak amplitude.
%
% hopefully 100 is ok, but if you're finding that the algorithm is picking
% up, say, t-peaks, then play with this and see if it fixes things.
catt_opts.rdetection_thresh = 100;

%% ========================================================================
%  Set parameters for t-wave detection
% =========================================================================

% Set the minimum & maximum physiologically plausible rpeak-tpeak
% interval (in msec).
% The algorithm will search for the t-peak within these bounds.
catt_opts.RT_min = 200; 
catt_opts.RT_max = 500; 

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
%   - 'data': use the RT interval obtained from t-wave detection
catt_opts.qt_method  = 'data'; 

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
%  Quality checks: set maximum and minimum BPM.
%  RR intervals where estimated BPM is outside of these bounds will be
%  flagged by catt_IBI
% =========================================================================

catt_opts.BPM_max = 160; % IBIs with a BPM higher than this will be excluded. To switch this off, set to inf 
catt_opts.BPM_min = 40; % IBIs with a BPM lower than this will be excluded. To switch this off, set to 0 
catt_opts.BPM_extreme_z = 3; % what z-score is considered extreme. Set to inf to keep all IBIs, irrespective of zscore.

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

%% print welcome to command line
clc;
disp(['% -------------------------------------------- %'])
disp(['%   The Cardiac Timing Toolbox (CaTT) v2.0     %'])
disp(['%                                              %'])
disp(['%   Example scripts can be found in the demos  %'])
disp(['%   folder.                                    %'])
disp(['%   Toolbox parameters can be found in the     %'])
disp(['%   catt_opts structure in your workspace.     %'])
disp(['% -------------------------------------------- %'])
end

