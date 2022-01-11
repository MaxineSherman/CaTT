%CATT_DEMO_PLOTTING demo for plotting using CaTT
%
%   usage: catt_demo_plotting
%
%  This demo will show how to plot using CaTT.
%
%  It calls upon simulated data, found in the demos folder.
%
% The data is from one simulated participant, and it has already been preprocessed,
% all the way up to wrapping to the heartbeat.
% For 30 minutes, this participant viewed a series of faces.
% Their task was to press a button whenever the face appeared (approx every 2 seconds).
% Onsets correspond to button press time.
% The first 450 faces were 'happy', coded as response = 1, and the next 450
% were 'angry', coded as response = 2.
%
% ========================================================================
%  CaTT TOOLBOX v2.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  08/08/2021
% =========================================================================

function catt_demo_plotting

global catt_opts;
catt_init;

%% ==================================================
% Download the data
% ==================================================

dload = exist('demo data/demo_data_for_plotting.mat')==0;

if dload
    disp('We need to get the sample data. The data can be found here: https://osf.io/6azyn/');
    disp('The code will download the data for you.');
    input('Press any key to continue');disp(sprintf('\n'));

    % make demo data folder if it doesn't already exist
    if ~exist('demo data','dir'); mkdir('demo data'); end
    
    % download the demo data
    disp('downloading & unzipping blinks data...');
    websave('demo data/demo_data_for_plotting.mat','https://osf.io/6azyn/download');
    disp('done.');
end

%% ==================================================
% Download the data + prepare
% ==================================================
load('demo data/demo_data_for_plotting.mat');


% wrap data to rpeaks (otherwise the histograms look strange because,
% trivially, there are more onsets after the t-wave than before)
catt_opts.wrap2='rpeak';
catt.wrapped = catt_wrap2heart(catt);

%% ==================================================
% Prepare plot
% ==================================================

figure;
set(gcf,'position',[10,10,1000,600]);

%% ==================================================
% Plot the distributions of IBIs and onsets
% ==================================================

% These are plotting the same data (IBIs on the xaxis and onsets as dots,
% colour coded by response). The presentation is just different. The shape
% of the black histogram on the top panel is the distribution of IBIs.
% The onsets seem randomly distributed in each RR interval. The red dots
% are above the green ones because the 'experiment' was divided into 2
% halves: angry trials first; happy trials second.

subplot(2,2,1); catt_plot_ibi_dist(catt);
subplot(2,2,2); catt_plot_onset_dist(catt);

% The bottom panel is the same, except that trials are sorted according to
% when the onset appeared relative to the last R peak. You can see that
% there doesn't seem to be a clear difference between response types.

%% ==================================================
% Plot circular histograms
% ==================================================

% Let's plot a circular histogram of the data. First, take the stuff we
% need:
angles    = catt.wrapped.onsets_rad;
condition = catt.wrapped.responses;

% Let's plot a histogram of all the cardiac phases, separately for the 2
% response types
subplot(2,2,3);
catt_plot_circ({angles(condition==1), angles(condition==2)},{'angry','happy'},'quantity','count','mean','off');

% Those distributions look a little different, but it's hard to tell.
% Let's plot a only the resultant vectors for each condition.
% The direction of the resultant vector (the plotted line) represents the mean
% angle. The length represents how 'good a representation' of the data that mean is.
% It's a bit like the standard deviation, kind of.
subplot(2,2,4);
catt_plot_circ({angles(condition==1), angles(condition==2)},{'angry','happy'},'quantity','probability','histogram','off','mean','on');

% We can see that there's maybe a small difference in the points in the
% cardiac cycle where people report seeing happy vs angry faces: happy
% faces are reported both later in the cardiac cycle, and also the
% distribution is more clustered around that angle (because the resultant
% vector is longer).

disp(sprintf('\n'));
disp('<strong>% -----------------------------------------------------------------------%</strong>');
disp('<strong>This demo is now over.</strong>');
disp('<strong>By adapting this code you will hopefully be able to</strong>');
disp('<strong>preprocess all your participant data.</strong>');
disp('<strong>You can find the catt structure in the file catt_demo_processed.mat.</strong>');
disp('<strong>% -----------------------------------------------------------------------%</strong>');

%% ----------------------------------------------------------------------
%  End of demo
%  ----------------------------------------------------------------------

end





