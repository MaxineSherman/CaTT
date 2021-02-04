function peak_locs_final=real_r_peak_detection(signal,fs, peak_locs_temp, thresh)
    % find the true r peaks
    % find the highest peak on the original signal within +- thresh samples
    % using the peak location temp as reference
    peak_locs_final = [];
    for i=1:length(peak_locs_temp)
        % the left and right bound
        l_bound = round(peak_locs_temp(i) - thresh);
        r_bound = round(peak_locs_temp(i) + thresh);
        if l_bound < 1
            l_bound = 1;
        end
        if r_bound > length(signal)
            r_bound = length(signal);
        end
        peak_value = max(signal(l_bound:r_bound));
        max_peak_locs = find(signal(l_bound:r_bound)==peak_value) +l_bound-1;
        if length(max_peak_locs) > 1
            if ismember(max_peak_locs(1),peak_locs_final) == 0
                peak_locs_final = [peak_locs_final, max_peak_locs(1)];
            end
        else
            if ismember(max_peak_locs,peak_locs_final) == 0
                peak_locs_final = [peak_locs_final, max_peak_locs];
            end
        end
    end
