
% KEY PROCESSING STEPS:
%   1. IMU SYNC: Calculates time lag using acceleration signals.
%   2. DYNAMIC CROP: Automatically crops the start (Lag + 10s Margin) to 
%      ensure the analysis starts only when both devices have valid data 
%      and to remove physical synchronization noise .
%   3. HR ANALYSIS: Computes instantaneous Heart Rate from R-R intervals.

clear; clc; close all;

%  PATH CONFIGURATION 
base_path = '/Users/martaguzman/Library/CloudStorage/OneDrive-SharedLibraries-KTH/Seraina Dual - 2026_INT_Marta_Guzman_WearableBiofeedback/Recordings';
cometa_root = fullfile(base_path, '26_02_Cometa');
ow_root     = fullfile(base_path, 'NewRecordingsOpenEarable');

% Define the list of trials (Cometa TXT name, OpenWearable Folder name of the trial)
trials = {
 % 'Aurora_LongWalking_R' , 'Aurora_LongWalking_R_OpenWearable_Recording_2026-02-26T12-36-58.710393';
% 'Aurora_LongWalking_L' , 'Aurora_LongWalking_L_OpenWearable_Recording_2026-02-26T11-38-11.058655';
 % 'Aurora_ShortWalking_L', 'Aurora_ShortWalking_L_OpenWearable_Recording_2026-02-26T11-58-18.847751';
 % 'Aurora_RestStandingUp_L','Aurora_RestStandingUp_L_OpenWearable_Recording_2026-02-26T11-29-55.618246';

 %'Marta_walk_5min_ROpen', 'Marta_ShortWalking_R_OpenWearable_Recording_2026-02-27T11-51-54.977861';
 %'Marta_walking_ROpen', 'Marta_LongWalking_R_OpenWearable_Recording_2026-02-27T11-32-58.252117';
 };

for i = 1:size(trials,1)
    trial_name = trials{i,1};
    ow_folder  = trials{i,2};
    
    fprintf('Processing trial %d/%d: %s\n', i, size(trials,1), trial_name);
    
    cometa_file = fullfile(cometa_root, [trial_name '.txt']);
    ow_path     = fullfile(ow_root, ow_folder);
    
    try
        %% 1. LOAD DATA
        % Load Gold Standard (Cometa) and Test Device (OpenEarable)
        [t_ref, acc_ref, ecg_ref] = load_cometa_data(cometa_file);

        [t_test, acc_test] = load_ow_acc(ow_path);
        
        fs_sync = 2000; % Cometa sampling rate
        
        %% 2. IMU SYNCHRONIZATION 
        % Calculate lag using acceleration signals (keep full signal for this)
        [lag_sec, ~, ~, ~] = sync_acc(t_ref, acc_ref, t_test, acc_test, fs_sync);
        
        % Visualize IMU synchronization to verify the lag
        evaluate_acc_sync(t_ref, acc_ref, t_test, acc_test, 'Cometa', 'OpenEarable');

       %% 3. LOAD AND ALIGN PPG
        % Find the optical sensor file
        ppg_files = dir(fullfile(ow_path, '*_PHOTOPLETHYSMOGRAPHY.csv'));
        if isempty(ppg_files)
            error('No PPG file found in the folder.');
        end
        
        % Load PPG and extract channel 
        [ppg_table, t_ppg_raw] = load_and_clean_ppg(ppg_files(1), ow_path);
        ppg_raw = ppg_table.GREEN; 
        
        % Apply the calculated lag to shift PPG time
        t_ppg_shifted = t_ppg_raw + lag_sec;
        
        % Resample PPG to match Cometa's exact time vector
        ppg_aligned = interp1(t_ppg_shifted, ppg_raw, t_ref, 'linear', NaN);

        %% 4. DYNAMIC SIGNAL CROPPING
        % Instead of a fixed value, we use the detected lag + a safety margin.
        % This ensures we remove all NaNs from the beginning of the signal.
        
        sync_safety_margin = 10; % Extra seconds to clear physical sync noise (the "beep")
        remove_seconds = abs(lag_sec) + sync_safety_margin; 
        
        fprintf('  Cropping first %.2f seconds (Lag: %.2f + Margin: %d)\n', ...
            remove_seconds, abs(lag_sec), sync_safety_margin);

        % Apply the dynamic crop to both ECG and PPG
        [t_ecg_sync_clean, ecg_sync_clean] = remove_sync_noise(t_ref, ecg_ref, fs_sync, remove_seconds);
        [~, ppg_cropped] = remove_sync_noise(t_ref, ppg_aligned, fs_sync, remove_seconds);
   
        %% 5. SIGNAL PROCESSING
        % 5a. Clean residual NaNs to prevent the filter from crashing
        ppg_to_filter = ppg_cropped;
        ppg_to_filter(isnan(ppg_to_filter)) = mean(ppg_to_filter, 'omitnan');

        % 5b. ECG: Bandpass (0.1-40Hz) and R-peak detection
        [t_peaks, hr_bpm_ecg, t_hr_ecg, is_missed, is_extra, ecg_filtered] = compute_hr_ecg(t_ecg_sync_clean, ecg_sync_clean, fs_sync);

        % 5c. PPG: Causal bandpass filtering
        ppgfilterRange = [0.5 7.0];
        [ppg_filtered, ~] = preprocess_ppg(ppg_to_filter, fs_sync, ppgfilterRange);
      
        %% 6. VISUALIZATION (PEAKS & HR)
        % Plot the final cleaned heart rate and R-peak alignment.
        plot_ecg_validation(t_ecg_sync_clean, ecg_filtered, t_peaks, t_hr_ecg, hr_bpm_ecg, is_missed, is_extra, trial_name);
        
        % Plot ECG vs PPG overlay to manually verify Pulse Transit Time (PTT)
        plot_ecg_ppg_overlay(t_ecg_sync_clean, ecg_filtered, t_peaks, ppg_filtered, ppgfilterRange, trial_name);
        
    
    catch ME
        fprintf('  Error in trial %s: %s\n', trial_name, ME.message);
    end
end