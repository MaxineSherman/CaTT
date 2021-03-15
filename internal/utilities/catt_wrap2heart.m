%CATT_WRAP2HEART express an onset as a function of its position in a
%cardiac cycle
%   usage: onsets_wrapped = catt_wrap2heart(onsets, IBIs, [qt])
%
%   Note that catt_wrap2heart calls the global parameter structure
%   <strong>catt_opts</strong> (initialised by catt_init).
%   
%   The relevant settings in <strong>catt_opts</strong> are:
%     - catt_opts.wrap2 (for wrapping to R vs. T)
%     - catt_opts.qt_default
%     - catt_opts.qt_method
%
%   INPUTS:
%           onsets        -  a vector of onsets (RTs, stimulus onset times etc),
%                            expressed as msecs since the last R peak.
%           IBIs          -  a vector of interbeat intervals, expressed in msecs
%           qt [optional] -  qt interval (in msecs)
%                            only needed if locking to t-wave
%                            take this from catt.qt after calling
%                            catt_estimate_qt
% 
%   OUTPUTS:
%           wrapped_onsets - a vector of onsets expressed as cardiac angles
%                            (in radians)
% ========================================================================
%  CaTT TOOLBOX v1.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% ========================================================================

function onsets_wrapped = catt_wrap2heart(onsets, IBIs, qt)

%% ========================================================================
%  Get settings, initialise outputs
%  ========================================================================

global catt_opts

% initialise output
onsets_wrapped    = nan(size(onsets));

if nargin < 3 & strcmpi(catt_opts.wrap2,'twav')
    switch catt_opts.qt_method
        case 'fixed'
            qt = catt_opts.qt_default;
        otherwise
            error('Please enter a qt interval to wrap to the t-wave, or set catt_opts.qt_method to fixed');
    end
end
if nargin < 3 & strcmpi(catt_opts.wrap2,'rpeak')
    qt = nan;
end

%% get rt from qt and qr
rt = qt - catt_opts.qr;

%% ========================================================================
%  Method 1 [default]: Wrap to t-wave 
%
%  The time between the R peak and t-wave is fixed at some
%  value param.r2t, say 300ms
%
%  Differences in IBIs over trials is driven by differences in the time
%  between the t-wave and subsequent R peak, i.e. param.t2r
%
%  When the onset is before the t-wave, it is expressed as a proportion of
%  r2t, which does not vary with IBI. Because the onset comes before the
%  t-wave, it takes a negative value.
%
%  When the onset comes after the t-wave, it is expressed as a proportion
%  of the time between the t-wave and next R peak, i.e. IBI-param.r2t.
%  Because the onset comes after the t-wave it takes a positive value.
%
%  The final step is to transform these proportions into radians.
%  ========================================================================

if strcmpi(catt_opts.wrap2,'twav')
    
    onsets_wrapped = nan(size(onsets));
    
    % First, get the trials where the onset was before the t-wave.
    % Convert to a proportion of r2t
    idx                     = find( onsets <= rt );
    onsets_wrapped( idx,1 ) = ( onsets(idx) - rt )/rt;
    
    % Second, get the trials where the onset was after the t-wave.
    % Convert to a proportion of t2r
    idx                     = find( onsets > rt );
    onsets_wrapped( idx,1 ) = ( onsets(idx) - rt )./(IBIs(idx) - rt);
    
    % Finally, convert to radians
    onsets_wrapped        = onsets_wrapped*pi;

%% ========================================================================
%  Method 2: A simple circular approach.
%
%  Onsets are wrapped to the r-peak.
%
%  This method does not fix the distance between R and T.
%
%  ========================================================================

elseif strcmpi(catt_opts.wrap2,'rpeak') 
    
    % Express each onset as a proportion of the IBI
    onsets_wrapped        = onsets./IBIs;
    
    % Convert to radians
    onsets_wrapped        = onsets_wrapped*2*pi;

end

end
    
    