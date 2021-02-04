ntrials = numel(intero.proc.keepTrials);
padding = 0; % in samples

close all
figure; hold on;
keepTrials=find(intero.proc.keepTrials);


for j = 1:numel(keepTrials)
    
    i = keepTrials(j);
    
    % take the r to r, with a little bit on each side
    try
    start = intero.proc.timeSinceR(i,4);
    start = find(start == intero.raw.times{i});
    stop  = intero.proc.timeSinceR(i,5);
    stop  = find(stop == intero.raw.times{i});
    
    % get the ecg from this trial + smooth it to make it nice
    ecg = intero.raw.ECG{i}(start:stop);
    ecg = detrend(smooth(wdenoise(ecg,2,'Wavelet','db1')));
    X   = 2:2:2*numel(ecg);
    plot(X,ecg,'color',[.7 .7 .7]);
    end
end

t   = intero.proc.timeSinceR(keepTrials,2);
yes = find(intero.proc.response(keepTrials)==1);
no  = find(intero.proc.response(keepTrials)==0);

ym  = nanmean(t(yes)); yse = nanstd(t(yes))./sqrt(numel((yes)));
nm  = nanmean(t(no)); nse = nanstd(t(no))./sqrt(numel((no)));

h = errorbar(  ym, 0.5, yse,  'horizontal');
h.LineWidth = 3; h.Color = [.3 .7 .2]; h.MarkerSize = 8;

h = errorbar( nm, 0.3, nse,  'horizontal');
h.LineWidth = 3; h.Color = [.7 .1 .2]; h.MarkerSize = 8;