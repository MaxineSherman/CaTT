%BIN_DATA bin data into some specified bins
%
%    usage: binned = bin_data( data, bins );
%
%    INPUTS:
%       data   - an n x 1 vector containing the data you want to bin
%       bins   - an m x 1 vector containing the upper limits of each of
%                your m bins
%
%    OUTPUTS:
%      binned  - an n x 1 vector containing the bin that each value in data
%                belongs to.
%
%
% ========================================================================
%  m.sherman@sussex.ac.uk
%  Sackler Centre for Consciousness Science, Uni Sussex
%  May 2017
% =========================================================================



function binned = catt_bin_data(data,bins)

nbins    = numel(bins);
binned   = ones(numel(data),1); % initialise binned at the max value

for t = 1:numel(data) % go through data
    
    ibin = 1; % start ticker
    while ibin <= nbins
        
        % is it larger?
        if data(t) > bins(ibin)
            binned(t) = ibin+1;
        end
        ibin = ibin + 1;
    end
end

