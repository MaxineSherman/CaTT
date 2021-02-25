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

% 
% % define bin width
% w = 2*pi/nbins;
% 
% % define bin centres
% bin_centres = -pi:w:pi;
% 
% % from bin centres, set bin limits
% LL = wrapToPi(bin_centres-0.5*w);
% UL = wrapToPi(bin_centres+0.5*w);
% 
% % get rid of the last bin, which is the same as the first
% LL = LL(1:end-1)';
% UL = UL(1:end-1)';
% 
% % wrap to pi
% LL = wrapToPi(LL);
% UL = wrapToPi(UL);
% 
% % for each bin, get the difference between thetas and LL & UL
% for i = 1:numel(LL)
%     LL_dist(:,i) = circ_dist(thetas,LL(i));
%     UL_dist(:,i) = circ_dist(UL(i),thetas);
% end
% 
% % the correct bin is that for which the distance from each limit is less
% % than w
% which_bin   = abs(LL_dist)<=w & abs(UL_dist)<=w;
% binned_data = which_bin*[1:nbins]';
