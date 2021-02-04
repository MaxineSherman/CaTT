%% ========================================================================
%INTERO_INIT initialise parameters for INTERO toolbox  
%   usage: intero_opts = intero_init
%
%   Initialises the default simulation & plotting parameters used by this
%   toolbox. Change these defaults below.
%
% ========================================================================
%  INTERO TOOLBOX v1.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================

function intero_opts = intero_init

global intero_opts

% add toolbox to path
s = what('intero_v1.0'); addpath(genpath(s.path));

%% ========================================================================
%  Create initial plotting parameters
% =========================================================================

%% the basics
intero_opts.plot.lw     = 2;  % line width
intero_opts.plot.axfs   = 14; % font size for axis, e.g. ticks
intero_opts.plot.lfs    = 16; % font size for labels, e.g. title
intero_opts.plot.ms     = 50; % marker size, e.g. for scatter plots

%% colours
intero_opts.cols.cmap   = crameri('romaO'); 
intero_opts.cols.grey   = [0.7 0.7 0.7]; % grey will be a light grey.
intero_opts.cols.alpha  = 0.5; 

%% legend settings
intero_opts.plot.legOri = 'Horizontal';   % legends will be horizontal
intero_opts.plot.legLoc = 'SouthOutside'; % legends will be located at the bottom of the plot

%% grid settings
intero_opts.plot.grid   = 'on';

%% settings specific to circular plots
intero_opts.plot.circ_nbins = 15;

%% ========================================================================
%  Create initial simulation parameters
% =========================================================================

intero_opts.sim.nsubj      = 10;
intero_opts.sim.ntrials    = 40;
intero_opts.sim.length     = 6000; % in msec
intero_opts.sim.fs         = 500; % 500Hz sampling rate
intero_opts.sim.HRs        = 50:100; % the heart rates to sample frendom
intero_opts.sim.ECG_noise  = 0.1:0.02:0.36; % the ECG noise to sample from
intero_opts.sim.onsetTimes = [3500,5500]; % the first and last timestamp the onset can be drawn from.
intero_opts.sim.responses  = [0,1]; % what are the possible responses? For continuous responses you can change this to e.g. 0:100.

intero_opts.sim.association = 'none'; % no behaviour-cardiac effect. Options are 'none','correlation','difference'
intero_opts.sim.effect_size = 0; % this is redundant when association is 'none'

%% ========================================================================
%  Create initial preprocessing parameters
% =========================================================================

intero_opts.wrap2     = 'twav'; % wrap to t-wave (systole). Alternative is r-peak
intero_opts.r2t       = 300; % assuming 300msec fixed length. You don't need this if wrapping to r-peak.
