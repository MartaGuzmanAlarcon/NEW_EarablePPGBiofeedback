function run_acc_sync(t_ref, acc_ref, t_test, acc_test, label_ref, label_test)
%RUN_ACC_SYNC Synchronize and visualize two acceleration signals.

fs_sync = 2000;

% Print timing info
print_time_info(t_ref, t_test);

% Plot before
figure('Color','w');
subplot(2,1,1)
plot(t_ref, zscore(acc_ref),'b'); hold on
plot(t_test, zscore(acc_test),'r');
title('Before synchronization')
legend(label_ref,label_test)
grid on

%% --- Correlation BEFORE synchronization ---
% Create a common time axis to ensure temporal alignment before sync
t_common_before = max(t_ref(1), t_test(1)) : 1/fs_sync : min(t_ref(end), t_test(end));

% Interpolate raw signals to the common time axis (no lag applied yet)
ref_interp_before  = interp1(t_ref, acc_ref, t_common_before, 'linear', NaN);
test_interp_before = interp1(t_test, acc_test, t_common_before, 'linear', NaN);

% Filter out NaN values at the boundaries for a clean correlation calculation
valid_indices = ~isnan(ref_interp_before) & ~isnan(test_interp_before);

% Calculate the actual baseline correlation using only overlapping valid data
corr_before = corrcoef(zscore(ref_interp_before(valid_indices)), zscore(test_interp_before(valid_indices)));
corr_before_val = corr_before(1,2);

fprintf('Correlation BEFORE sync: %.4f\n', corr_before_val);

%% Sync
[lag_sec, t_sync, acc_ref_sync, acc_test_sync] = ...
    sync_acc(t_ref, acc_ref, t_test, acc_test, fs_sync);

fprintf('Estimated lag: %.3f s\n', lag_sec);

%% --- Correlation AFTER synchronization ---
min_len_after = min(length(acc_ref_sync), length(acc_test_sync));

ref_after_raw  = acc_ref_sync(1:min_len_after);
test_after_raw = acc_test_sync(1:min_len_after);

% Filter out NaN values at the boundaries for a clean calculation
valid_idx_after = ~isnan(ref_after_raw) & ~isnan(test_after_raw);

% Apply zscore and correlation only to valid overlapping data
ref_after_clean  = zscore(ref_after_raw(valid_idx_after));
test_after_clean = zscore(test_after_raw(valid_idx_after));

corr_after = corrcoef(ref_after_clean, test_after_clean);
corr_after_val = corr_after(1,2);

fprintf('Correlation AFTER sync: %.4f\n', corr_after_val);

% Plot after
subplot(2,1,2)

% Necesitamos el vector de tiempo correspondiente a los datos limpios
t_sync_clean = t_sync(1:min_len_after);
t_sync_clean = t_sync_clean(valid_idx_after);

% Dibujamos directamente las variables que ya limpiamos arriba
plot(t_sync_clean, ref_after_clean, 'b'); hold on
plot(t_sync_clean, test_after_clean, 'r');

title(['After synchronization | Lag = ' num2str(lag_sec,'%.3f') ' s'])
legend([label_ref ' (aligned)'],[label_test ' (aligned)'])
grid on

end
