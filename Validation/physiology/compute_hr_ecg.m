function [t_peaks, hr_bpm, t_hr, is_missed, is_extra, ecg_filtered] = compute_hr_ecg(t_ecg, ecg_raw, fs)
% COMPUTE_HR_ECG Filters ECG, detects R-peaks, and calculates Heart Rate.
%
% Inputs:
%   t_ecg    - Time vector (seconds)
%   ecg_raw  - Raw ECG signal (Volts)
%   fs       - Sampling frequency (Hz)
%
% Outputs:
%   t_peaks      - Time of detected R-peaks (seconds)
%   hr_bpm       - Heart Rate (Beats Per Minute)
%   t_hr         - Time vector for HR (seconds)
%   is_missed    - (Disabled) Array of logical zeros for compatibility
%   is_extra     - (Disabled) Array of logical zeros for compatibility
%   ecg_filtered - Filtered signal for visualization

    %% 1. Bandpass Filtering (0.1 - 40 Hz)
    % Removes wandering baseline and high-frequency noise
    fny = fs/2;
    [b_hp, a_hp] = cheby1(4, 1, 0.1/fny, 'high'); 
    [b_lp, a_lp] = cheby1(4, 1, 40/fny, 'low');
    
    ecg_filtered = filtfilt(b_hp, a_hp, double(ecg_raw));
    ecg_filtered = filtfilt(b_lp, a_lp, ecg_filtered);

    %% 2. R-Peak Detection
    qrs_indices = pantompkins_qrs(ecg_filtered, fs);
    t_peaks = t_ecg(qrs_indices);

    %% 3. Heart Rate Calculation
    rr_intervals = diff(t_peaks);
    t_hr = t_peaks(2:end);
    hr_bpm = 60 ./ rr_intervals;
    
    %% 4. Outlier Detection (Disabled)
    is_missed = false(size(hr_bpm));
    is_extra  = false(size(hr_bpm));
end