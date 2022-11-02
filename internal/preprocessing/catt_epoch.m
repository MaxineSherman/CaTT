%CATT_epoch epoch data into RR intervals
%   usage: catt = catt_epoch(catt)
%
%   Epochs continuous ECG data into RR intervals.
%
% ========================================================================
%  CaTT TOOLBOX v2
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  08/08/2021
% =========================================================================


function catt = catt_epoch( catt )

global catt_opts

try

    % first, for each onset figure out which RR interval it falls in
    onsetR = [];
    for i = 1:numel(catt.onsets_ms)
        r_minus_onset = catt.tlock.rPeaks_msec - catt.onsets_ms(i);
        onsetloc      = find(diff(sign(r_minus_onset))~=0);
        
        if isempty(onsetloc); onsetloc=1; end
        
        onsetR(i) = onsetloc(1);% = [onsetR,onsetloc'];
    
    end


    % loop through R-peaks
    for iR = 1:numel(catt.tlock.rPeaks_idx)-1

        % get indices for the RR interval
        catt.RR(iR).idx_RR     = [catt.tlock.rPeaks_idx(iR):(catt.tlock.rPeaks_idx(iR+1)-1)]';
        catt.RR(iR).idx_twav   = [catt.tlock.tPeaks_idx(iR):catt.tlock.tEnds_idx(iR)]';

        % get ECG data for the RR interval
        catt.RR(iR).ECG        = catt.ECG.processed( catt.RR(iR).idx_RR );
        catt.RR(iR).times      = catt.ECG.times( catt.RR(iR).idx_RR );

        % get start time for the RR interval
        catt.RR(iR).RR_t0      = catt.tlock.rPeaks_msec(iR);

        % get RT interval (rpeak to t-end)
        catt.RR(iR).RT         = catt.tlock.RT_msec(iR);

        % get t-peak and t-end, in msec since beginning of the interval
        catt.RR(iR).tPeak      = catt.tlock.tPeaks_msec(iR) - catt.RR(iR).RR_t0;
        catt.RR(iR).tEnd       = catt.tlock.tEnds_msec(iR) - catt.RR(iR).RR_t0;

        % is there an onset here?
        if ismember(iR,onsetR)
            onsetTime         = catt.onsets_ms( iR==onsetR );
            catt.RR(iR).onset = onsetTime - catt.RR(iR).RR_t0;

            % if there is an onset, is there an accompanying response?
            if ~isempty(catt.responses)
                catt.RR(iR).response = catt.responses(iR==onsetR);
            else
                catt.RR(iR).response = nan;
            end

        else % if there's no behaviour here, log as nan
            catt.RR(iR).onset = nan;
            catt.RR(iR).response = nan;
        end
    end

catch err
    save err
    rethrow(err)
end
end