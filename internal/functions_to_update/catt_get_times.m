%CATT_GET_TIMES
%   usage: catt = catt_get_times(intero, [param], [plot_on])
%
%   INPUTS:
%     - catt           This is your intero structure, created after you've
%                        called catt_preprocess
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
%  CaTT TOOLBOX v1.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================

function catt = catt_get_times(catt, param, plot_on)

%% plot?
if nargin < 3 | isempty(plot_on); plot_on = false; end
if nargin < 2 | isempty(param);   param   = [];    end

ntrials = numel(catt.responses);

% ========================================================================
%  First, get the time (in msec) since the last R peak.
%  Plot the results if you want.
% =========================================================================

for itrial = 1:ntrials
    
    % was each peak (in msec) before or after the onset time (in msec)
    tdiff = sign( catt.tlock.rPeaks_msec{itrial}-catt.onsets(itrial) );
    
    % find where we switch from before to after - this gives us the two
    % straddling r-peaks
    tdiff = diff(tdiff) ~= 0;
    tdiff = find(tdiff);
    
    % save this so we can always map rPeaks and rPeaks_msec to onsets
    catt.tlock.onset_loc{itrial,1}          = zeros( size( catt.tlock.rPeaks_msec{itrial} ) );
    catt.tlock.onset_loc{itrial,1}(tdiff)   = -1; % before
    catt.tlock.onset_loc{itrial,1}(tdiff+1) =  1; % after

    if ~isempty(tdiff) % the onset didn't come after the last r-peak
        
        % get the r-peaks before and after
        rbefore = catt.tlock.rPeaks_msec{itrial}(tdiff);
        rafter  = catt.tlock.rPeaks_msec{itrial}(tdiff+1);
        
        % load in the information, getting the onset relative
        % to the 2 r peaks it was between
        catt.tlock.onsets_r_msec(itrial,1)  = catt.onsets(itrial) - rbefore; % the time of the onset, relative to the last r-peak (msec)
        catt.tlock.onsets_IBI(itrial,1)     = rafter - rbefore; % the IBI for the onset
        
    else
        catt.proc.onsets_r(itrial,1)    = nan;
        catt.tlock.onsets_IBI(itrial,1) = nan;
        warning('The response came after the last r-peak. Skipping...');
    end
    
end

%% plot it?
if plot_on; figure; catt_plot_onset_dist(catt); end

% ========================================================================
%  Wrap onsets to cardiac time
% =========================================================================

% get onsets in radians, relative to rpeak or twave
catt.tlock.onsets_r_rad = catt_wrap2heart( catt.tlock.onsets_r_msec,...
                                                catt.tlock.onsets_IBI,...
                                                param ); 

%% plot it?
if plot_on; figure; catt_plot_over_ECG(catt); end

end


