%CATT_ESTIMATE_QT compute qt estimate from ECG data
%   usage: catt = catt_estimate_qt(catt, method)
%
%   INPUTS:
%      catt         - your catt structure (for one participant)
%
% OUTPUTS:
%      catt         - estimated qt interval (in msec), loaded into catt.qt
% ========================================================================
%  CaTT TOOLBOX v1.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% ========================================================================

function catt = catt_estimate_qt( catt )

%% get default value of qt
global catt_opts

%% gather all the IBIs
if ~strcmpi( catt_opts.qt_method, 'fixed' )
    
    all_IBI = [];
    for i = 1:numel(catt.all_IBI)
        all_IBI = [all_IBI; catt.all_IBI{i}];
    end
    
    % get BPM from IBIs
    catt.est_bpm = catt_ibi2bpm(all_IBI);
    
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
    otherwise
        warning('unknown or empty method in catt_opts.qt_method. Please check your parameter structure');
end

end



