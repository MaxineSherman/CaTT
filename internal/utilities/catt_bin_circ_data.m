%CATT_BIN_CIRC_DATA bin data into some specified bins
%
%    usage: [binned_data,bin_centres,LL,UL] = catt_bin_circ_data( thetas,nbins );
%
%    INPUTS:
%       thetas   - an n x 1 vector containing the angular data you want to bin
%       nbins    - the number of (equally spaced) bins you want
%
%    OUTPUTS:
%      binned_data  - an n x 1 vector containing the bin that each value in data
%                belongs to (from 1-nbins).
%
%
% ========================================================================
%  CaTT TOOLBOX v2
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  06/07/2021
% ========================================================================


function [binned_data,bin_centres,LL,UL] = catt_bin_circ_data(thetas,nbins)

% get equally-spaced bins
bins = 0:(2*pi/nbins):(2*pi);

% get lower and upper limits of the bins fyi
LL = bins(1:nbins);
UL = [bins(2:nbins), 2*pi];

% get bin centres fyi
bin_centres = wrapTo2Pi( circ_mean( [LL;UL]) );

%% bin the data

% wrap thetas to 2pi
thetas = wrapTo2Pi(thetas);

% initialise binned output
binned_data = nan(size(thetas));

current_bin   = 2;

while current_bin <= numel(bins)

    % find the thetas less than current_bin and put them in
    % current_bin-1
    idx                = find( thetas < bins(current_bin) );

    % log those thetas as bin-1
    binned_data(idx)   = current_bin-1;

    % remove remaining thetas from the search list
    thetas(idx)        = nan; 

    % update current bin
    current_bin = current_bin + 1;
end

% the remaining ones are 2pi=0 (matlab rounding problem), so put them in the first bin
idx              = find( ~isnan(thetas) );
binned_data(idx) = 1;

end