%catt_HRV compute heart rate variability
%   usage: hrv = catt_HRV(times, [which_val])
%
%   INPUTS:
%      times        - a numeric vector containing either time stamps for
%                     each r-peak *or* IBIs. By default, enter r-peaks.
%      which_val    - 'r' if times is r-peaks, or 'IBI' if times is IBIs.
%                     Default is 'r'.
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
%  CaTT TOOLBOX v1.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% ========================================================================


function hrv = catt_HRV( input, which_val )

global catt_opts

%% set defaults if neccessary
if nargin < 2 | isempty(which_val); which_val = 'r'; end


%% get IBI directly from input, or calculate from r-peaks
if strcmpi(which_val,'r'); IBI = diff(input);
else;                      IBI = input;
end
    
%% compute HRV according to method
switch catt_opts.HRV_method
    
    case 'RMSSD' % sqrt of the mean of the squares of the successive differences between adjacent IBIs
        hrv = sqrt( mean( diff(IBI).^2 ) );
        
    case 'SDNN' %  the standard deviation of IBIs
        hrv = std( IBI );
        
    case 'SDSD' % the standard deviation of the successive differences between adjacent IBIs
        hrv = std( diff( IBI ) );
        
    case 'pNN50' % NN50 is the number of pairs of successive IBIs that differ by more than 50 ms.
                 % pNN50 is the proportion of NN50 divided by total number of IBIs.
        NN50 = sum( abs(diff( IBI )) > 50 );
        hrv  = NN50/(numel(IBI));
        
    case 'pNN20' % as for pNN50, but for 20ms
        NN20 = sum( abs(diff( IBI )) > 20 );
        hrv  = NN20/(numel(IBI));
        
    otherwise
        error('<strong>catt_HRV: </strong> unknown method set in catt_opts.HRV_method. Enter RMSSD, SDNN, SDSD, pNN50 or pNN20');
end

end
        

