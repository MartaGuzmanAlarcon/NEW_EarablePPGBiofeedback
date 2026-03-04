clear; clc; close all;

%  PATH CONFIGURATION 
base_path = '/Users/martaguzman/Library/CloudStorage/OneDrive-SharedLibraries-KTH/Seraina Dual - 2026_INT_Marta_Guzman_WearableBiofeedback/Recordings';
cometa_root = fullfile(base_path, '26_02_Cometa');
ow_root     = fullfile(base_path, 'NewRecordingsOpenEarable');

% Define the list of trials (Cometa TXT name, OpenWearable Folder name of the trial)
trials = {
   'Aurora_LongWalking_R' , 'Aurora_LongWalking_R_OpenWearable_Recording_2026-02-26T12-36-58.710393';
  % 'Aurora_ShortWalking_L', 'Aurora_ShortWalking_L_OpenWearable_Recording_2026-02-26T11-58-18.847751';
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

        %% TODO: PPG SYNCHRONIZATION
        % TODO: Implement PPG loading and alignment here once ready.
        % Steps:
        % - Load PPG data from OpenEarable folder
        % - Apply the calculated lag_sec to PPG time
        % - Resample PPG to match 2000 Hz
        % - Use remove_sync_noise to crop synchronization jumps

        %% 4. Remove Sync Jumps
        % Crop 30s from both ends to remove physical synchronization noise.
        % This ensures the adaptive threshold in Pan-Tompkins works correctly.
        remove_seconds = 30;
        [t_ecg_clean, ecg_clean] = remove_sync_noise(t_ref, ecg_ref, fs_sync, remove_seconds);

        %% 5. ECG GOLD STANDARD PROCESSING
        % Detect R-peaks and calculate Heart Rate on the cleaned signal.
        [t_peaks, hr_bpm, t_hr, is_missed, is_extra, ecg_f] = compute_hr_ecg(t_ecg_clean, ecg_clean, fs_sync);

        %% 6. VISUALIZATION (PEAKS & HR)
        % Plot the final cleaned heart rate and R-peak alignment.
        plot_ecg_validation(t_ecg_clean, ecg_f, t_peaks, t_hr, hr_bpm, is_missed, is_extra, trial_name);
        
        fprintf('  Success: Found %d heartbeats. Lag: %.3f s\n', length(t_peaks), lag_sec);
        
    catch ME
        fprintf('  Error in trial %s: %s\n', trial_name, ME.message);
    end
end