% An R-peak detection method based on peaks of Shannon energy envelope
%
%
% EDIT BY MAXINE, Oct 2020: this code doesn't run on Matlab 2020.
% I've edited chebyshevI_bandpass and call it separately,
% Then pass the filter to this function.


function [out_sig, peak_locs_final] = SEHT(signal,fs,BP_filter)
    % the output: detected peak locations
    % filter the noise and baseline wander with bandpass filter
    
    % BP_filter = chebyshevI_bandpass(4,fs,6,18); MAXINE: make this an
    % input instead
    
    % forward filtering
    f_signal = filter(BP_filter,signal);
    % backward filtering
    f_signal = fliplr(f_signal);
    f_signal = filter(BP_filter,f_signal);
    f_signal = fliplr(f_signal);
    % first order differentiation
    d_n = f_signal(2:end)-f_signal(1:end-1);
    % normalize the signal
    norm_dn = d_n/max(abs(d_n));
    % implementation from shannon energy envelope
    se_n = (-1)*(norm_dn.^2).*log(norm_dn.^2);
    % apply triangle filter: implementation from An R-peak detection method
    % based on peaks of Shannon energy envelope
    N = 55;
    rect_filter = rectwin(N);

    see = conv(se_n,rect_filter,'same');
    see = fliplr(see);
    see = conv(see,rect_filter,'same');
    see = fliplr(see);

   
    % Hilbert transform-based
    ht = imag(hilbert(see));
    % apply moving average filter to remove low frequency drift
    N = 900;
    ma_filter = (1/N)*ones(1,N);
    ma_out = filter(ma_filter,1,ht);
    zn = ht - ma_out;
    % odd-symmetry function, find the zero cross points
    peak_locs_temp = [];
    for t = 2:length(zn)-1
        if zn(t-1) <= 0 && zn(t+1) >= 0
            if ismember(t-1,peak_locs_temp) == 0
                peak_locs_temp = [peak_locs_temp, t];
            end
        end
    end
    thresh = 25;
    peak_locs_final = real_r_peak_detection(signal,fs, peak_locs_temp, thresh);
    out_sig = zn;