%catt_HRV compute heart rate variability
%   usage: catt = catt_HRV(catt)
%
%   INPUTS:
%      catt         - your catt structure
%
%      These are the possible methods for calculating HRV.
%      The method is set in catt_opts.HRV_method.
%
%         - 'RMSSD' [default] sqrt of the mean of the squares of the successive differences between adjacent IBIs
%         - 'SDNN'  the standard deviation of IBIs
%         - 'SDSD'  standard deviation of the successive differences between adjacent IBIs
%         - 'pNN50' proportion of pairs of successive IBIs that differ by more than 50 ms
%         - 'pNN20' proportion of pairs of successive IBIs that differ by more than 20 ms.
%
% ========================================================================
%  CaTT TOOLBOX v2
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  08/08/2021
% ========================================================================


function catt = catt_HRV( catt )

global catt_opts

%% get IBIs
IBI = [catt.RR.IBI];

%% compute HRV according to method
switch catt_opts.HRV_method

    case 'RMSSD' % sqrt of the mean of the squares of the successive differences between adjacent IBIs
        catt.HRV = sqrt( mean( diff(IBI).^2 ) );

    case 'SDNN' %  the standard deviation of IBIs
        catt.HRV = std( IBI );

    case 'SDSD' % the standard deviation of the successive differences between adjacent IBIs
        catt.HRV = std( diff( IBI ) );

    case 'pNN50' % NN50 is the number of pairs of successive IBIs that differ by more than 50 ms.
        % pNN50 is the proportion of NN50 divided by total number of IBIs.
        NN50      = sum( abs(diff( IBI )) > 50 );
        catt.HRV  = NN50/(numel(IBI));

    case 'pNN20' % as for pNN50, but for 20ms
        NN20      = sum( abs(diff( IBI )) > 20 );
        catt.HRV  = NN20/(numel(IBI));

    otherwise
        error('<strong>catt_HRV: </strong> unknown method set in catt_opts.HRV_method. Enter RMSSD, SDNN, SDSD, pNN50 or pNN20');
end

end


