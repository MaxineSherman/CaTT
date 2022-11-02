%function CaTT_corrigendum_test_new_shuffling
% 
% This function cycles through various cases where either H0 is true
% (uniform distribution of cardiac angles) or H1 is true (strongly locked
% to some point), simulates data, runs the permutation tests, and looks at
% whether the permutation test combined with the test for non-uniformity
% successfully reveal the ground truth.

function CaTT_corrigendum_test_new_shuffling

close all;clc

%% parameters
mIBI      = 1000;
sdIBI     = 100;
ntrials   = 3000; 


%% Scenario 1: No locking to next R peak (2pi). Should have Z=0
IBIs     = normrnd(mIBI,sdIBI,ntrials,1); 
onsets   = IBIs.*rand(ntrials,1); % onsets uniformly distributed in RR interval
testpermutations(IBIs,onsets,'H0 is true');

%% Scenario 2: strong locking to next R peak (2pi). Should have large Z
IBIs     = normrnd(mIBI,sdIBI,ntrials,1); 
onsets   = IBIs - 100*rand(ntrials,1); % onsets are always 0-100ms before next R peak
testpermutations(IBIs,onsets,'H1 is true (strong)');

%% Scenario 3: Early onsets. Should have large Z
IBIs     = normrnd(mIBI,sdIBI,ntrials,1); 
onsets   = IBIs*0.5.*rand(ntrials,1); % onsets always fall in first half of the RR interval
testpermutations(IBIs,onsets,'H1 is true (strong)');

%% Scenario 4: Like (3) but with more noise
IBIs     = normrnd(mIBI,sdIBI,ntrials,1); 
onsets   = IBIs.*betarnd(3,3,ntrials,1); % onsets usually fall in first half of the RR interval
testpermutations(IBIs,onsets,'H1 is true (weak)');

%% Scenario 6: True skew (weak)
IBIs    = normrnd(mIBI,sdIBI,ntrials,1);
onsets  = IBIs.*wrapTo2Pi(circ_vmrnd(0,0.5,ntrials))./(2*pi);
testpermutations(IBIs,onsets,'H0 is true (weak skew)');

%% Scenario 5: True skew (strong)
IBIs    = normrnd(mIBI,sdIBI,ntrials,1);
onsets  = IBIs.*wrapTo2Pi(circ_vmrnd(0,1,ntrials))./(2*pi);
testpermutations(IBIs,onsets,'H0 is true (strong skew)');

disp('done')
end

% ------------------------------------------
function testpermutations(IBIs,onsets,hypothesis)

figure;
nloops = 2000;

%% Step 1: get thetas & empirical test stat + plot
thetas = 2*pi*onsets./IBIs;
[~,T]  = circ_raotest( thetas );

subplot(1,3,1);
polarhistogram( thetas ,'Normalization','probability');
title('Cardiac angles (true)');

%% Step 2: permute + plot
V     = [];   Tstar = [];
for i = 1:nloops
    if ismember(i,[100:100:10000]); clc;disp(sprintf('permutation test: %d/%d',[i,nloops])); end
    [sibi, so]   = catt_shuffle(IBIs, onsets);
    V            = [V, 2*pi*so./sibi];
    [~,Tstar(i)] = circ_raotest( 2*pi*so./sibi);
end

subplot(1,3,2); 
polarhistogram(V,'Normalization','probability');
title('Permuted cardiac angles')

%% Step 3: plot distribution of T under the null
subplot(1,3,3); hold on;
histogram(Tstar,20);
z = (T-mean(Tstar))./std(Tstar);
scatter(T,100,200,'filled');
title([sprintf('Z = %.2f',z),' | ' hypothesis]);
set(gca,'YTick',[]); xlabel('Test stat under H0 (T*)')
legend({'T*','T for empirical data'},'FontSize',15,'Location','SouthOutside');

end

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
    idx = find(IBIs >= onsets(i));
    t   = idx(randi(numel(idx)));

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

