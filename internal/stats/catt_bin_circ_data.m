%BIN_DATA bin data into some specified bins
%
%    usage: [binned_data,bin_centres,LL,UL] = catt_bin_circ_data( thetas,nbins );
%
%    INPUTS:
%       thetas   - an n x 1 vector containing the angular data you want to bin
%       bins     - an m x 1 vector containing the upper limits of each of
%                your m bins
%
%    OUTPUTS:
%      binned_data  - an n x 1 vector containing the bin that each value in data
%                belongs to.
%
%
% ========================================================================
%  m.sherman@sussex.ac.uk
%  Sackler Centre for Consciousness Science, Uni Sussex
%  May 2017
% =========================================================================


function [binned_data,bin_centres,LL,UL] = catt_bin_circ_data(thetas,nbins)

% define bin width
w = 2*pi/nbins;

% define bin centres
LL = -pi:w:pi;
bin_centres=LL;
% from bin centres, set bin limits
UL = wrapToPi(LL+w);

% get rid of the last bin, which is the same as the first
LL = LL(1:end-1)';
UL = UL(1:end-1)';

% wrap to pi
LL = wrapToPi(LL);
UL = wrapToPi(UL);

% for each bin, get the difference between thetas and LL & UL
for i = 1:numel(LL)
    LL_dist(:,i) = circ_dist(thetas,LL(i));
    UL_dist(:,i) = circ_dist(UL(i),thetas);
end

% the correct bin is that for which the distance from each limit is less
% than w
which_bin   = abs(LL_dist)<=w & abs(UL_dist)<=w;
binned_data = which_bin*[1:nbins]';
end