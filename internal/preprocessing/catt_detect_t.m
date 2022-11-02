%CATT_DETECT_T detect end of t-wave. Also gives you peak of t-wave
%   usage: catt = catt_detect_t(catt)
%
%  This function does the following:
%    1. detects t-wave peak
%    2. detects t-wave end
%    3. calculates RT interval (the distance between the rpeak and the end
%    of the t-wave)
%
%  To find t-peak, the code performs a brute search looking for the
%  local maximum voltage. This is assumed to be t-peak.
%
%  The search starts approx. 200ms after the R peak. This can be changed in
%  catt_init edit by changing the parameter catt_opts.RT_min.
%  The search ends after some physiologically plausible
%  time. The default is 500ms, but this can be
%  changed in catt_init by editing the parameter catt_opts.RT_max
%
%  T-wave detection is performed using the method described in
%  Vázquez-Seisdedos et al (2011). New approach for T-wave end detection on electrocardiogram:
%  Performance in noisy conditions. Biomedical engineering online, 10(1), 1-11.
%
%  For each trial t and R-peak iR, this script adds the following values to
%  the catt structure:
%
%  catt.tlock.tPeaks_idx{t}(iR)  - index in the ECG trial data of the
%                                  t-wave peak
%  catt.tlock.tPeaks_v{t}(iR)    - t-wave peak amplitude
%  catt.tlock.tPeaks_msec{t}(iR) - time of t-wave peak since the beginning
%                                  of the trial
%
% catt.tlock.tEnds_idx{t}(iR)    - index in the ECG trial data of the
%                                  t-wave end
% catt.tlock.tEnds_v{t}(iR)      - t-wave end amplitude
% catt.tlock.tEnds_msec{t}(iR)   - time of t-wave end since the beginning
%                                  of the trial
%
% catt.tlock.RT_idx{t}(iR)       = Rpeak-Tend interval, in samples;
% catt.tlock.RT_msec{t}(iR)      = Rpeak-Tend interval, in msec;
%
%
% update: May 2022
%         Fixed potential for error when the end of the t-wave search region falls
%         outside of the ECG data
% ========================================================================
%  CaTT TOOLBOX v2
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  21/06/2021
% ========================================================================

function catt = catt_detect_t( catt )

% get opts
global catt_opts

% get tPeaks search region, expressed as indices
tmin = catt_opts.RT_min;
tmin = tmin/(1000/catt_opts.fs);

tmax = catt_opts.RT_max;
tmax = tmax/(1000/catt_opts.fs);

% loop trials
for iR = 1:numel( catt.tlock.rPeaks_idx ) % T always follows R, so we're going to loop through the Rs

    % Step 0: Extract data following the most recent r-peak
    R_prev            = catt.tlock.rPeaks_idx(iR); % this is the idx of the last R
    search_region_idx = (R_prev+tmin):(R_prev+tmax);


    % Step 1: Find tpeak

    % ...If we're outside of the ECG sample, abort + set everything to nan
    if search_region_idx(end) > numel(catt.ECG.times)
        catt.tlock.tPeaks_idx(iR)  = nan;
        catt.tlock.tPeaks_v(iR)    = nan;
        catt.tlock.tPeaks_msec(iR) = nan;

        catt.tlock.tEnds_idx(iR)   = nan;
        catt.tlock.tEnds_v(iR)     = nan;
        catt.tlock.tEnds_msec(iR)  = nan;

        catt.tlock.RT_idx(iR)      = nan;
        catt.tlock.RT_msec(iR)     = nan;

    else % otherwise, continue as normal

        search_region_ECG = catt.ECG.processed( search_region_idx );
        search_region_t   = catt.ECG.times( search_region_idx );

        % find max voltage in search region
        tPeaks_idx         = find( (search_region_ECG) == max((search_region_ECG)) );
        tPeaks_idx         = round(mean(tPeaks_idx)); % in case there's more than 1

        % Now that we've found the location of the t-peak, load it into
        % catt
        catt.tlock.tPeaks_idx(iR)  = search_region_idx(tPeaks_idx);
        catt.tlock.tPeaks_v(iR)    = search_region_ECG(tPeaks_idx);
        catt.tlock.tPeaks_msec(iR) = search_region_t(tPeaks_idx);


        % Step 2: Found the end of the t-wave

        % We want to search from tPeak to tPeak + 200msec
        msec200           = (200/(1000/catt_opts.fs));
        search_region_idx = catt.tlock.tPeaks_idx(iR):(catt.tlock.tPeaks_idx(iR) + msec200);

        try % this will fail if we fall outside of the search region
            search_region_ECG = catt.ECG.processed( search_region_idx );
            search_region_t   = catt.ECG.times( search_region_idx );

            % Calculate derivative for tPeaks:tPeaks+200 (search_region_idx)
            % & find point of maximum derivative. This gives (xm,ym)
            dy                 = diff( search_region_ECG )./diff( search_region_t );
            xm                 = find( abs(dy)==max(abs(dy)) ); xm = xm(1);
            ym                 = dy(xm);
            xm                 = search_region_idx( xm );

            % Set (xr,yr), which is a reference point far away from T but
            % before R. We set it as tmax.
            xr            = search_region_idx(end)+10;
            yr            = catt.ECG.processed(xr);

            % cycle through all xm < x < xr
            % calculate area
            Xi = (xm+1):(xr-1);
            A  = 0.5.*( ym - catt.ECG.processed(Xi)').*(2.*xr - Xi - xm );
            xi = find( A == max(A) );

            % express the position & amplitude & timing of tEnd in terms of the
            % whole ECG dataset
            catt.tlock.tEnds_idx(iR)  = Xi(xi);
            catt.tlock.tEnds_v(iR)    = catt.ECG.processed( Xi(xi) );
            catt.tlock.tEnds_msec(iR) = catt.ECG.times( Xi(xi) );

            % Finally, calculate the RT intervals
            catt.tlock.RT_idx(iR)      = catt.tlock.tEnds_idx(iR)  - catt.tlock.rPeaks_idx(iR);
            catt.tlock.RT_msec(iR)     = catt.tlock.tEnds_msec(iR) - catt.tlock.rPeaks_msec(iR);

        catch
            catt.tlock.tPeaks_idx(iR)  = nan;
            catt.tlock.tPeaks_v(iR)    = nan;
            catt.tlock.tPeaks_msec(iR) = nan;

            catt.tlock.tEnds_idx(iR)   = nan;
            catt.tlock.tEnds_v(iR)     = nan;
            catt.tlock.tEnds_msec(iR)  = nan;

            catt.tlock.RT_idx(iR)      = nan;
            catt.tlock.RT_msec(iR)     = nan;
        end
    end
end
end


