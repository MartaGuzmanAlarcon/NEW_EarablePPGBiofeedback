function [lag_seconds, t_common, acc_ref_sync, acc_test_sync] = ...
    sync_acc(t_ref, acc_ref, t_test, acc_test, fs_sync)
%SYNC_ACC Synchronize two acceleration signals using cross-correlation.
%
% Inputs:
%   t_ref     - Time vector reference device (seconds)
%   acc_ref   - Acc magnitude reference device
%   t_test    - Time vector test device (seconds)
%   acc_test  - Acc magnitude test device
%   fs_sync   - Resampling frequency for synchronization (Hz)
%
% Outputs:
%   lag_seconds   - Estimated temporal offset (test relative to ref)
%   t_common      - Common time vector after alignment
%   acc_ref_sync  - Reference acceleration aligned
%   acc_test_sync - Test acceleration aligned

%% Resample both signals to common frequency

t_ref_resampled  = (t_ref(1):1/fs_sync:t_ref(end))';
t_test_resampled = (t_test(1):1/fs_sync:t_test(end))';

acc_ref_resampled  = interp1(t_ref,  acc_ref,  t_ref_resampled,  'linear');
acc_test_resampled = interp1(t_test, acc_test, t_test_resampled, 'linear');

%% Bandpass filtering (gait band)

[b,a] = butter(2, [0.3 5]/(fs_sync/2), 'bandpass');

acc_ref_filtered  = filtfilt(b,a, detrend(acc_ref_resampled));
acc_test_filtered = filtfilt(b,a, detrend(acc_test_resampled));

%% Extract overlapping window

t_start = max(t_ref_resampled(1),  t_test_resampled(1));
t_end   = min(t_ref_resampled(end), t_test_resampled(end));

idx_ref  = t_ref_resampled  >= t_start & t_ref_resampled  <= t_end;
idx_test = t_test_resampled >= t_start & t_test_resampled <= t_end;

acc_ref_norm = zscore(acc_ref_filtered(idx_ref));
acc_test_norm = zscore(acc_test_filtered(idx_test));

%% Cross-correlation

min_len = min(length(acc_ref_norm), length(acc_test_norm));

acc_ref_trim = acc_ref_norm(1:min_len);
acc_test_trim = acc_test_norm(1:min_len);

[correlation, lags] = xcorr(acc_ref_trim, acc_test_trim, 'coeff');

[~, max_index] = max(correlation);

lag_samples = lags(max_index);
lag_seconds = lag_samples / fs_sync;

%% Apply lag correction

t_test_shifted = t_test_resampled + lag_seconds; % si estaba adelant 2,3s , retraso 

t_common = t_ref_resampled(idx_ref);

acc_ref_sync = acc_ref_filtered(idx_ref);
acc_test_sync = interp1(t_test_shifted, acc_test_filtered, ...
                        t_common, 'linear', NaN); % desplazo  valores en fun.ref

end