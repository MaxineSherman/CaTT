%CATT_IBI calculates IBIs, screens for bad trials, and calculates the IBI of the cycle in which onset appeared.
%   usage: catt = catt_IBI( catt, [plot_on] )
%
%    INPUTS:
%       - catt                catt structure, including the following fields:
%                               - catt.onsets_ms
%                               - catt.tlock.rPeaks_msec
%       - plot_on [optional]   If set to true, plot histogram for retained IBIs and for
%                              excluded IBIs. [default = false]
%
%    OUTPUTS:
%       - catt.IBI.raw        An nbeats x 1 vector containing all interbeat intervals, in msecs
%       - catt.IBI.screened   An nbeats x 1 vector containing all non-extreme IBIs, in msecs.
%                             Extreme IBIs are marked as nan
%
% ========================================================================
%  CaTT TOOLBOX v2
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  07/08/2021
% ========================================================================

function catt = catt_IBI( catt, plot_on )

global catt_opts
%% =================================================
%  Evaluate plot_on
%  =================================================

if nargin == 1
    plot_on = false;
end

%% =================================================
%  Get inter-beat intervals
%  =================================================

% get raw IBIs
for i = 1:numel(catt.RR)
    IBIs(i) = catt.RR(i).times(end)-catt.RR(i).times(1);
    catt.RR(i).IBI = IBIs(i);
end

% screen for IBIs that don't make sense
extreme  = find( abs(zscore(IBIs)) > catt_opts.BPM_extreme_z );
too_fast = find( IBIs < catt_bpm2ibi(catt_opts.BPM_max) );
too_slow = find( IBIs > catt_bpm2ibi(catt_opts.BPM_min) );

bad      = [extreme, too_fast, too_slow];
ok       = setdiff([1:numel(IBIs)]',bad);

% send bad ones to rej
catt.rej.removed_for_bad_IBI = bad;
catt.rej.orig_post_manual_rejection = catt.RR;

% log prop removed
catt.rej.prop_IBIs_removed = numel(bad)/(numel(bad)+numel(ok));

% only keep good ones
catt.RR = catt.RR(ok);

%% =================================================
%  Plot histogram of IBIs (removed & retained)
%  =================================================

if plot_on

    figure;
    subplot(1,2,1);
    h = histogram( IBIs(ok) );  h.FaceColor = [.3 .7 .4];
    xlabel('IBI (msec)','FontSize',15);
    ylabel('Count','FontSize',15);
    set(gca,'LineWidth',2,'TickLength',[0,0],'FontSize',15);
    title('IBIs (retained)','FontSize',17);

    subplot(1,2,2);
    h = histogram( IBIs(bad), 20);  h.FaceColor = [.62 .6 .6];
    xlabel('IBI (msec)','FontSize',15);
    ylabel('Count','FontSize',15);
    set(gca,'LineWidth',2,'TickLength',[0,0],'FontSize',15);
    title('IBIs (excluded)','FontSize',17);

end
