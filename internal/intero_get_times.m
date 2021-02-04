%INTERO_GET_TIMES
%   usage: intero = intero_get_times(intero, [param], [plot_on])
%
%   INPUTS:
%     - intero           This is your intero structure, created after you've
%                        called intero_preprocess
%
%     - param [optional] This is a parameter structure that states how you
%                        want to map onsets to cardiac time.
%                        It has 2 fields:
%                        param.wrap2 - 'twav' or 'rpeak' 
%                        param.r2t   - assumed (fixed) time between t-peak
%                                      and t-wave
%                        Default is param.wrap2 = 'twav', param.r2t = 300
%
%      - plot_on [optional] If you want to plot the distributions of onsets as
%                           a function of IBI, set plot to true or 1.
%                           Default is 0
%
% ========================================================================
%  INTERO TOOLBOX v1.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================

function intero = intero_get_times(intero, param, plot_on)

%% plot?
if nargin < 3 | isempty(plot_on); plot_on = false; end
if nargin < 2 | isempty(param);   param   = [];    end

ntrials = numel(intero.responses);

% ========================================================================
%  First, get the time (in msec) since the last R peak.
%  Plot the results if you want.
% =========================================================================

for itrial = 1:ntrials
    
    % was each peak (in msec) before or after the onset time (in msec)
    tdiff = sign( intero.tlock.rPeaks_msec{itrial}-intero.onsets(itrial) );
    
    % find where we switch from before to after - this gives us the two
    % straddling r-peaks
    tdiff = diff(tdiff) ~= 0;
    tdiff = find(tdiff);
    
    % save this so we can always map rPeaks and rPeaks_msec to onsets
    intero.tlock.onset_loc{itrial,1}          = zeros( size( intero.tlock.rPeaks_msec{itrial} ) );
    intero.tlock.onset_loc{itrial,1}(tdiff)   = -1; % before
    intero.tlock.onset_loc{itrial,1}(tdiff+1) =  1; % after

    if ~isempty(tdiff) % the onset didn't come after the last r-peak
        
        % get the r-peaks before and after
        rbefore = intero.tlock.rPeaks_msec{itrial}(tdiff);
        rafter  = intero.tlock.rPeaks_msec{itrial}(tdiff+1);
        
        % load in the information, getting the onset relative
        % to the 2 r peaks it was between
        intero.tlock.onsets_r_msec(itrial,1)  = intero.onsets(itrial) - rbefore; % the time of the onset, relative to the last r-peak (msec)
        intero.tlock.onsets_IBI(itrial,1)     = rafter - rbefore; % the IBI for the onset
        
%         % for later, we'll also need these times without centering them
%         intero.tlock.timeSinceR(itrial,4) = rbefore;
%         intero.proc.timeSinceR(itrial,5) = rafter;
        
    else
        intero.proc.onsets_r(itrial,1)    = nan;
        intero.tlock.onsets_IBI(itrial,1) = nan;
        warning('The response came after the last r-peak. Skipping...');
    end
    
end

%% plot it?
if plot_on; figure; intero_plot_onset_dist(intero); end

% ========================================================================
%  Wrap onsets to cardiac time
% =========================================================================

% get onsets in radians, relative to rpeak or twave
intero.tlock.onsets_r_rad = intero_wrap2heart( intero.tlock.onsets_r_msec,...
                                                intero.tlock.onsets_IBI,...
                                                param ); 

%% plot it?
if plot_on; figure; intero_plot_over_ECG(intero); end

end


