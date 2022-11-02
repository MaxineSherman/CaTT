%CATT_MANUALREJECTION manual rejection of R peak detection
%   usage: catt = catt_manualRejection(catt)
%
%   Call this function *after* running catt_import, catt_denoise,
%   catt_detect_rpeaks and catt_detect_t
%
%   This function opens a docked figure and displays the:
%   - Filtered ECG signal (grey line)
%   - Detected R peaks (red dots)
%   - Detected T peaks and ends (blue line)
%
%   Select your window size, in RR intervals, at the command line prompt. The
%   default is 10 RRs. You'll get through your dataset faster with
%   larger windows; you'll be able to see the data quality better with
%   smaller windows.
%
%   Click red dots to reject the R-R interval. They will turn grey when
%   they've been rejected. You can click them again to retain the.
% 
%   Once you're finished, press ENTER to continue to
%   the next window, or press the < to go back to the previous page
%
%   Rejected RRs will be kicked out of catt.RR
%
%   Your original data can be found in catt.rej.
%
%   At some point I'll try to make this into a proper GUI.
%
% UPDATE 4/3/22:
%    - if you click a rejected interval again it'll be retained
%    - click < to go back to the previous page
%
% ========================================================================
%  CaTT TOOLBOX v2
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  08/08/2021
% =========================================================================


function catt = catt_manualRejection( catt )

global catt_opts

try

    %% Set window size

    disp(sprintf('\n\n'));
    disp('%-----------------------------------------------------------------%');
    disp('%  CATT: manual rejection');
    disp('%  This function opens a docked figure and displays the:');
    disp('%   - Filtered ECG signal (grey line)');
    disp('%   - Detected R peaks (red dots)');
    disp('%   - Detected T peaks and ends (blue line)');
    disp('%');
    disp('%   Select your window size, in RR intervals, at the command line prompt.');
    disp('%');
    disp('%   The default is 10 RRs.');
    disp('%   You''ll get through your dataset faster with larger windows;');
    disp('%   you''ll be able to see the data quality better with smaller windows');
    disp('%');
    disp('%   Click red dots to reject the R-R interval. They will turn grey');
    disp('%   when they''ve been rejected. Once you''re finished, press enter');
    disp('%   to continue to the next window.');
    disp('%-----------------------------------------------------------------%');

    disp(sprintf('\n'));
    wsize_RRs = input('<strong>Number of RR intervals per window? Enter blank for default of 10: </strong>');
    disp('%-----------------------------------------------------------------%');

    if isempty(wsize_RRs); wsize_RRs = 10; end

    %% open docked window
    close all;
    h1 = figure;
    set(h1,'WindowStyle','docked')

    %% initialise things
    catt.rej.removed    = [];
    keep_going          = true;
    multiplier          = -1;

    %% save all the old data in catt.rej
    catt.rej.orig = catt.RR;

    %% loop trials, display & get decisions
    while keep_going

        % clear the window
        clf('reset');hold on;

        % get the current epoch
        multiplier          = multiplier + 1;
        current_window      = [1:wsize_RRs] + wsize_RRs*multiplier;

        % if current_window > numel(catt.RR), restrict
        current_window = current_window( ismember(current_window,1:numel(catt.RR)) );

        % gather the data to plot
        for j = 1:numel(current_window)

            % plot the data
            plot(catt.RR(current_window(j)).times, catt.RR(current_window(j)).ECG, 'Color', [.7 .7 .7] );

            % plot the R peak
            scatter(catt.RR(current_window(j)).RR_t0,catt.RR(current_window(j)).ECG(1),50,'r','filled');

            % plot the tpeak to tend
            idx   = catt.RR(current_window(j)).idx_twav;
            plot(catt.ECG.times(idx),catt.ECG.processed(idx),'b');

        end

        % add the title
        title({'Click rpeaks to reject.'; ...
            ['Press ENTER to continue or < to go back.'];...
            ['Displaying RR ' num2str(current_window(1)) '-' num2str(current_window(end)) ' of ' num2str(numel(catt.RR))]});

        % get xticks
        xticks     = catt.RR(current_window(1)).times(1):1000/catt_opts.fs:catt.RR(current_window(end)).times(end);
        xticks_idx = find(mod(xticks,1000)==0);
        clear xtickstr;
        for i = 1:numel(xticks_idx)
            xtickstr{i} = num2str( xticks(xticks_idx(i))/1000 );
        end

        % set the axis labels
        try; set(gca,'XTick', xticks(xticks_idx), 'XTickLabels', xtickstr ); catch; end % fix me
        set( gca,...
            'LineWidth', 2, ...
            'TickLength', [0 0] );
        xlabel('seconds','FontSize',20);
        ylabel('mV','FontSize',20);

        axis tight

        %% have people click to remove r-peaks
        while 1

            % get r-peak to delete
            [x,y,button] = ginput(1);

            % are they trying to go back?
            if ismember(44, button) & multiplier > -1
                multiplier = multiplier - 2;
                break;
            end

            % if not, keep going
            if ~isempty(button) % if they clicked something

                % find the closest r-peak to this point
                X             = [catt.RR(current_window).RR_t0];
                distance      = abs( X - x );
                r_clicked     = find( distance == min(distance) );

                % If it was retained, reject
                if ~ismember( unique(current_window(r_clicked)), catt.rej.removed )

                    % paint the rpeak grey
                    scatter(catt.RR(current_window(r_clicked)).RR_t0,catt.RR(current_window(r_clicked)).ECG(1),50,'filled','MarkerFaceColor',[.7 .7 .7]);

                    % paint the t-wave grey
                    idx   = catt.RR(current_window(r_clicked)).idx_twav;
                    plot(catt.ECG.times(idx),catt.ECG.processed(idx),'Color',[.7 .7 .7]);

                    % record it as deleted
                    catt.rej.removed = [catt.rej.removed, current_window(unique(r_clicked))];

                % if it was rejected, retain
                elseif ismember( unique(current_window(r_clicked)), catt.rej.removed )

                    % paint the rpeak red
                    scatter(catt.RR(current_window(r_clicked)).RR_t0,catt.RR(current_window(r_clicked)).ECG(1),50,'filled','MarkerFaceColor','r');

                    % paint the t-wave blue
                    idx   = catt.RR(current_window(r_clicked)).idx_twav;
                    plot(catt.ECG.times(idx),catt.ECG.processed(idx),'Color','b');

                    % remove it from deleted
                    catt.rej.removed = setdiff(catt.rej.removed, current_window(unique(r_clicked)));
                end


            else
                break
            end
        end

        % continue?
        next_window =  [1:wsize_RRs] + wsize_RRs*(1+multiplier);
        keep_going  = next_window(1) <= numel(catt.RR);

    end
    close(h1);

    %% find the good & bad data
    catt.rej.removed    = unique(catt.rej.removed);
    catt.rej.retained   = setdiff(1:numel(catt.RR),catt.rej.removed);

    %% mark the bad R-R intervals as nan
    catt.RR = catt.RR(catt.rej.retained);

    %% note proportion removed
    catt.rej.prop_RRs_removed     = numel(catt.rej.removed)/( numel(catt.rej.retained) + numel(catt.rej.removed) );
    catt.rej.prop_onsets_retained = sum(~isnan([catt.RR.onset]))/numel(catt.onsets_ms);


catch err
  %  save err_manualRejection
    rethrow(err)
end

end