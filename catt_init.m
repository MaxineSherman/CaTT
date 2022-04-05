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
% iv) added check for circstat & for subfolders being added to path in new subfunction catt_check_dependencies
%
%
% Edit: 5/4/22. Bootstrapping is broken - CaTT is temporarily disabled
% ========================================================================
%  CaTT TOOLBOX v2.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  08/08/2021
% ========================================================================

function catt_opts = catt_init

%% ========================================================================
%  Warning - CaTT is currently broken. Do not use.
% =========================================================================
error('There is a problem with the toolbox in its current form - the bootstrapping is broken. Apologies for the inconvinience, it will be fixed and updated very soon.');

%% ========================================================================
%  Check for dependencies (that all of CaTT is added to path & circstat is
%  installed
% =========================================================================

catt_check_dependencies;

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
% this value should be greater than your t-wave amplitude, and less than
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




%% ========================================================================
%CATT_CHECK_DEPENDENCIES check that you've got everything added to path & circstat installed  
%   usage: catt_opts = catt_check_dependencies
%
% ========================================================================
%  CaTT TOOLBOX v2.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  26/02/2022
% ========================================================================

function catt_check_dependencies

% ========================================================================
% Check CaTT has been added to path
% ========================================================================

if exist('chebyshevI_bandpass.m')~=2
    clc;
    disp('<strong>CaTT: Please add CaTT (with all it''s subfolders) to your path before initialising the toolbox.</strong>');
    disp('<strong>If you are in the main CaTT folder, write addpath(genpath(cd)) at the command line</strong>');
    error('Error: CaTT not fully added to path');
end

% ========================================================================
% Check we have the circstat toolbox. If not, download & unzip
% ========================================================================

if exist('dependencies/CircStat','dir')==0
    disp('CircStat toolbox not found.');
    disp('Downloading & unzipping...');

    websave('dependencies/CircStat','https://github.com/circstat/circstat-matlab/archive/refs/heads/master.zip'); % download
    unzip('dependencies/CircStat.zip','dependencies/CircStat'); % unzip
    disp(sprintf('done.\n'));
end

end
