%CATT_SHUFFLE pseudo-shuffle IBIs
%
%   usage: [shuffled_IBIs, descending_onsets] = catt_shuffle(IBIs,onsets)
%
%    This script pseudo-shuffles IBIs by first assigning the longest onsets
%    to random IBIs at least as long. In this way, no onset will be assigned to an
%    RR interval in which it could not fit.
%
%    INPUTS:
%     IBIs            - an nx1 or 1xn vector of IBIs
%     onsets          - an nx1 or 1xn  vector of onsets in msecs since the last R peak
%
%    OUTPUTS:
%    shuffled_IBIs       - an nx1 vector of shuffled IBIs
%    descending_onsets   - an nx1 vector of onsets in descending order
%                          (from high to low)
%
% ========================================================================
%  CaTT TOOLBOX v2.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  08/08/2021
% ========================================================================

function [shuffled_IBIs, onsets] = catt_shuffle(IBIs,onsets)

% arrange + sort
IBIs   = reshape(IBIs,1,numel(IBIs));
onsets = reshape(onsets,1,numel(onsets));

% sort
IBIs   = sort(IBIs,'descend');
onsets = sort(onsets,'descend');

% prep
shuffled_IBIs   = nan(size(onsets));

% pair the complicated ones first
i = 1;

while ~isnan(IBIs(end)) && onsets(i) > IBIs(end) && sum(~isnan( IBIs )~=0) % stop when you've run out of IBIs OR when all are ok

    % from all the IBIs greater this onset, pick one (replaced randsample -
    % this is faster)
    try
    idx = find(IBIs >= onsets(i));
    t   = idx(randi(numel(idx)));
    catch;
        clc;
        warning('<strong>Error in catt_shuffle, Line 46-47. Do you have some cases where onset > IBI?</strong>');
        warning('<strong>Retrying excluding these trials...</strong>');
    end

    % add it into the shuffled dataset
    shuffled_IBIs(i)   = IBIs(t);

    % remove the selected datapoint from the IBIs
    IBIs(t) = nan;

     % update ticker
    i = i + 1;

end

% shuffle the remaining
shuffled_IBIs(i:end) = shuffle(IBIs(~isnan(IBIs)));
end

