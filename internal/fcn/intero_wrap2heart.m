%INTERO_WRAP2HEART express an onset as a function of its position in a
%cardiac cycle
%   usage: onsets_wrapped = intero_wrap2heart(onsets, IBIs, param)
%
% 
% 
% ========================================================================
%  INTERO TOOLBOX v1.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% ========================================================================

function onsets_wrapped = intero_wrap2heart(onsets, IBIs)

%% ========================================================================
%  Get settings, initialise outputs
%  ========================================================================

global intero_opts

% initialise output
onsets_wrapped    = nan(size(onsets));

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

if strcmpi(intero_opts.wrap2,'twav')
    
    % First, get the trials where the onset was before the t-wave.
    % Convert to a proportion of r2t
    idx                     = find( onsets <= intero_opts.r2t );
    onsets_wrapped( idx,1 ) = ( onsets(idx) - intero_opts.r2t )/intero_opts.r2t;
    
    % Second, get the trials where the onset was after the t-wave.
    % Convert to a proportion of t2r
    idx                     = find( onsets > intero_opts.r2t );
    onsets_wrapped( idx,1 ) = ( onsets(idx) - intero_opts.r2t )./(IBIs(idx) - intero_opts.r2t);
    
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

elseif strcmpi(intero_opts.wrap2,'rpeak') 
    
    % Express each onset as a proportion of the IBI
    onsets_wrapped        = onsets./IBIs;
    
    % Convert to radians
    onsets_wrapped        = onsets_wrapped*2*pi;

end

end
    
    