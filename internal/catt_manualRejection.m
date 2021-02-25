%CATT_MANUALREJECTION manual rejection of R peak detection
%   usage: catt = catt_manualRejection(catt)
%
%   Call this function *after* running catt_importData.
%
%   This function opens a docked figure and displays, trial by trial, the:
%   - Raw ECG signal (thin black line)
%   - Filtered ECG signal (thick red line)
%   - Detected R peaks (black dots)
%
%   You should reject trials on which the detected R peaks don't correspond
%   to the peaks indicated by the black/red lines.
%
%   The function puts one field into catt called
%   retained. These are the indices of the trials flagged as
%   having r peak detection that was successful.
%
%   It also enters a field called keepTrial wih 0s and 1s that determine
%   whether each trial should be kept or not.
%
%   You can edit the keep & reject keys on line 24. Default is D & J
%
%   At some point I'll try to make this into a GUI.
%
% ========================================================================
%  CaTT TOOLBOX v1.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================


function catt = catt_manualRejection( catt )

%% set keys
keep_key   = 'F';  reject_key = 'D';

%% where to place dots?
dotloc = 2.5;

%% open docked window
close all;
h1 = figure; 
set(h1,'WindowStyle','docked')

%% initialise retained_idx
catt.retained_idx = [];

%% loop trials, display & get decisions
for itrial = 1:numel(catt.responses)
    clf('reset');hold on;
    
    plot(catt.ECG.raw{ itrial },'k');
    plot(catt.ECG.processed{itrial},'r','LineWidth',3);
    scatter(catt.tlock.rPeaks{itrial,1},dotloc * ones(size(catt.tlock.rPeaks{itrial,1}) ),100,'r','filled');
    
    % set xlim so we're not on tight axis
    xlim = get(gca,'XLim');
    set(gca,'XLim',[ xlim(1)-100, xlim(2)+100 ]);
    
    % keep or reject?
    str = input(['<strong>CaTT: </strong> Trial ' num2str(itrial) '/' num2str(numel(catt.responses)) ' - press ' reject_key ' for reject or ' keep_key ' for keep: '],'s');
    
    % load in
    catt.keepTrial(itrial,1) = strcmpi(str,keep_key);
    if strcmpi(str,keep_key)
        catt.retained_idx = [catt.retained_idx;itrial];
    end
    
end

close(h1);
end