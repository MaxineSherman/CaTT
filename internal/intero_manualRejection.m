%INTERO_MANUALREJECTION manual rejection of R peak detection
%   usage: intero = intero_manualRejection(intero)
%
%   Call this function *after* running intero_importData.
%
%   This function opens a docked figure and displays, trial by trial, the:
%   - Raw ECG signal (thin black line)
%   - Filtered ECG signal (thick red line)
%   - Detected R peaks (black dots)
%
%   You should reject trials on which the detected R peaks don't correspond
%   to the peaks indicated by the black/red lines.
%
%   The function puts one field into intero called
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
%  INTERO TOOLBOX v1.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================


function intero = intero_manualRejection( intero )

%% set keys
keep_key   = 'F';  reject_key = 'D';

%% where to place dots?
dotloc = 2.5;

%% open docked window
close all;
h1 = figure; 
set(h1,'WindowStyle','docked')

%% initialise retained_idx
intero.retained_idx = [];

%% loop trials, display & get decisions
for itrial = 1:numel(intero.responses)
    clf('reset');hold on;
    
    plot(intero.ECG.raw{ itrial },'k');
    plot(intero.ECG.processed{itrial},'r','LineWidth',3);
    scatter(intero.tlock.rPeaks{itrial,1},dotloc * ones(size(intero.tlock.rPeaks{itrial,1}) ),100,'r','filled');
    
    % set xlim so we're not on tight axis
    xlim = get(gca,'XLim');
    set(gca,'XLim',[ xlim(1)-100, xlim(2)+100 ]);
    
    % keep or reject?
    str = input(['<strong>intero: </strong> Trial ' num2str(itrial) '/' num2str(numel(intero.responses)) ' - press ' reject_key ' for reject or ' keep_key ' for keep: '],'s');
    
    % load in
    intero.keepTrial(itrial,1) = strcmpi(str,keep_key);
    if strcmpi(str,keep_key)
        intero.retained_idx = [intero.retained_idx;itrial];
    end
    
end

close(h1);
end