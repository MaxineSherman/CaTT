%CATT_ESTIMATE_QT compute qt estimate from ECG data
%   usage: catt = catt_estimate_qt(catt)
%
%   Set method for estimating qt interval in the catt_opts structure.
%   The options are:
%       'bazett'      - catt_opts.qt_default/sqrt(catt.est_bpm/60)
%       'fridericia'  - catt_opts.qt_default/((catt.est_bpm/60).^(1/3));
%       'sagie'       - 1000*( (catt_opts.qt_default/1000) + 0.154*(1-(catt.est_bpm/60)) );
%       'fixed'       - qt is set to catt_opts.qt_default for every RR
%                       interval
%       'data'        - qt changes on each trial, and is calculated as the RT
%                       interval (taken from catt_detect_heartbeats) + catt_opts.qr
%   INPUTS:
%      catt         - your catt structure (for one participant)
%
% OUTPUTS:
%      catt         - estimated qt interval (in msec), loaded into catt.qt
%
% ========================================================================
%  CaTT TOOLBOX v2
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  21/06/2021
% ========================================================================

function catt = catt_estimate_qt( catt )

%% get default value of qt
global catt_opts

%% gather all the IBIs
if ~strcmpi( catt_opts.qt_method, 'fixed' )

    % get BPM from IBIs
    catt.est_bpm = catt_ibi2bpm( [catt.RR.IBI] );

end

%% estimate QTc according to method
switch catt_opts.qt_method

    case 'bazett'
        catt.qt = catt_opts.qt_default/sqrt(catt.est_bpm/60);
    case 'fridericia'
        catt.qt = catt_opts.qt_default/((catt.est_bpm/60).^(1/3));
    case 'sagie'
        catt.qt = 1000*( (catt_opts.qt_default/1000) + 0.154*(1-(catt.est_bpm/60)) );
    case 'fixed'
        catt.qt = catt_opts.qt_default;
    case 'data' % note: RT is rpeak to tend)
        onset  = [catt.RR.onset];
        RT     = [catt.RR.RT];
        RT     = RT(~isnan(onset));

        catt.qt = RT + catt_opts.qr;

    otherwise
        warning('unknown or empty method in catt_opts.qt_method. Please check your parameter structure');
end

end



