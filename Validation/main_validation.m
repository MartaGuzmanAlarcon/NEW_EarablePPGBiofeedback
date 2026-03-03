clear; clc; close all;

% --- PATH CONFIGURATION ---
% CHANGE PATH AND TRIALS IF NEEDED 
base_path = '/Users/martaguzman/Library/CloudStorage/OneDrive-SharedLibraries-KTH/Seraina Dual - 2026_INT_Marta_Guzman_WearableBiofeedback/Recordings';
cometa_root = fullfile(base_path, '26_02_Cometa');
ow_root     = fullfile(base_path, 'NewRecordingsOpenEarable');

% Define the list of trials to process (Cometa TXT name, OpenWearable Folder name)
trials = {
    % Recording 1
    'Aurora_LongWalking_R', 'Aurora_LongWalking_R_OpenWearable_Recording_2026-02-26T12-36-58.710393';
    
    % Recording 2
   % 'Aurora_ShortWalking_R', 'Aurora_ShortWalking_R_OpenWearable_Recording_2026-02-26T12-06-52.543142';
    
};

for i = 1:size(trials,1)
    
    trial_name = trials{i,1};
    ow_folder  = trials{i,2};
    
    fprintf('Processing trial %d/%d: %s\n', i, size(trials,1), trial_name);
    
    cometa_file = fullfile(cometa_root, [trial_name '.txt']);
    ow_path     = fullfile(ow_root, ow_folder);
    
    try
        %  1. IMU SYNCHRONIZATION 
        [t_ref, acc_ref, ecg_ref] = load_cometa_data(cometa_file);
        [t_test, acc_test] = load_ow_acc(ow_path);
        
        fs_sync = 2000;
        [lag_sec, ~, ~, ~] = sync_acc(t_ref, acc_ref, t_test, acc_test, fs_sync);
        
        % Eval. the visualization script to see the acceleration sync graphs
        evaluate_acc_sync(t_ref, acc_ref, t_test, acc_test, 'Cometa IMU', 'OpenWearable IMU');
      
        
    catch ME
        fprintf('Error in trial %s:\n%s\n', trial_name, ME.message);
    end
end