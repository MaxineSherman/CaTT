%CATT_WRAP2HEART express an onset as a function of its position in a
%cardiac cycle
%   usage:   (i)  wrapped = catt_wrap2heart( catt )
%         OR (ii) wrapped = catt_wrap2heart(onsets, IBIs, qt)
%
%   Note that catt_wrap2heart calls the global parameter structure
%   <strong>catt_opts</strong> (initialised by catt_init).
%
%   The relevant settings in <strong>catt_opts</strong> are:
%     - catt_opts.wrap2 (for wrapping to Rpeak vs. T-end)
%     - catt_opts.qt_default
%     - catt_opts.qt_method
%
%   INPUTS:
%           catt          -  your catt structure
%                            expressed as msecs since the last R peak.
%
%     OR
%          onsets         - an nx1 vector of onsets, in msec since the last R peak
%          IBIs           - an nx1 vector of IBIs, in msec
%          qt             - an nx1 vector of qt intervals, in msec, OR a
%                           single number which is the estimated qt interval
%                           for all onsets.
%
%
%   OUTPUTS:
%           catt.wrapped.onsets_rad     - a vector of onsets expressed as cardiac angles (in radians)
%           catt.wrapped.onsets_msec    - a vector of onsets expressed as msec since R
%           catt.wrapped.responses      - a vector of responses for each onset
%           (if no responses present, will be empty)
%           catt.wrapped.IBIs           - IBI for each RR interval the onset was
%           present in
%           catt.wrapped.rt             - the rt interval used
%
% ========================================================================
%  CaTT TOOLBOX v2.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  08/08/2021
% ========================================================================

function wrapped = catt_wrap2heart( varargin )

%% ========================================================================
%  Get settings, initialise outputs
%  ========================================================================

global catt_opts

%% if we're working with a catt input
if numel(varargin) == 1 & isstruct(varargin{1})

    catt = varargin{1};

    % get the onsets, responses & qts
    onsets          = [catt.RR.onset];    onsets    = reshape(onsets,numel(onsets),1);
    responses       = [catt.RR.response]; responses = reshape(responses,numel(responses),1);
    qt              = [catt.qt];          qt        = reshape(qt,numel(qt),1);
    IBIs            = [catt.RR.IBI];      IBIs      = reshape(IBIs,numel(IBIs),1);

    if numel(qt) == 1; qt = qt*ones(size(IBIs)); end

    %% if we're working with 3 separate inputs (e.g. for bootstrapping)
elseif numel(varargin) == 3
    onsets = varargin{1};
    IBIs   = varargin{2};
    qt     = varargin{3};

    % if qt is same for all, replicate
    if numel(qt) == 1; qt = qt*ones(size(onsets)); end

    % ensure everything is in the right format
    onsets    = reshape(onsets,numel(onsets),1);
    IBIs      = reshape(IBIs, numel(IBIs), 1);
    qt        = reshape(qt,numel(qt),1);
    responses = nan(size(IBIs));

    %% otherwise, bug out
else
    error('Inputs should be either a catt structure, or onsets, IBIs and qts. Please see documentation for details.');
end

%% ========================================================================
%  Boot out data without an onset in
%  ========================================================================
responses = responses( ~isnan(onsets) );
IBIs      = IBIs( ~isnan(onsets) );
onsets    = onsets( ~isnan(onsets) );

%% ========================================================================
%  get the IBIs for all trials where there's an onset + load into
%  wrapped
%  ========================================================================

wrapped.onsets_msec = onsets;
wrapped.IBIs        = IBIs;
wrapped.responses   = responses;

wrapped.method      = catt_opts.wrap2;

%% ========================================================================
%  Prepare output
%  ========================================================================
wrapped.onsets_rad  = nan(size(onsets));

%% if using the fixed method, get rt from qt and qr.
if ~strcmpi(catt_opts.qr,'data')
    rt = qt - catt_opts.qr;
end

wrapped.rt = rt;

%% ========================================================================
%  Method 1 [default]: Wrap to t-wave
%
%  The time between the R peak and end of the t-wave is either fixed at some
%  value catt_opts.qt_default, say 400ms, or is taken from the data
%
%  Differences in IBIs over trials is driven by differences in the time
%  between the t-wave and subsequent R peak
%
%  When the onset is before the t-wave, it is expressed as a proportion of
%  r2t, which does not vary with IBI. Because the onset comes before the
%  t-wave, it takes a negative value.
%
%  When the onset comes after the t-wave, it is expressed as a proportion
%  of the time between the t-wave and next R peak, i.e. IBI-rt
%  Because the onset comes after the t-wave it takes a positive value.
%
%  The final step is to transform these proportions into radians.
%  ========================================================================

if strcmpi(catt_opts.wrap2,'twav')


    % First, get the trials where the onset was before the t-wave.
    % Convert to a proportion of r2t
    idx                             = find( onsets <= wrapped.rt );
    wrapped.onsets_rad( idx )  = ( onsets(idx) - wrapped.rt(idx) )./wrapped.rt(idx);

    % Second, get the trials where the onset was after the t-wave.
    % Convert to a proportion of t2r
    idx                              = find( onsets > wrapped.rt );
    wrapped.onsets_rad( idx,1 ) = ( onsets(idx) - wrapped.rt(idx) )./(wrapped.IBIs(idx) - wrapped.rt(idx));

    % Finally, convert to radians
    wrapped.onsets_rad          = wrapped.onsets_rad*pi;

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
    wrapped.onsets_rad        = onsets./wrapped.IBIs;

    % Convert to radians
    wrapped.onsets_rad        = wrapped.onsets_rad*2*pi;

end
end

