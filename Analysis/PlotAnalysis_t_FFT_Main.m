clear; clc; close all;

% USER CONFIGURATION 
rootFolder  = '/Users/martaguzman/Master/KTH/PhDopp/Recordings';
fsPpg       = 84;              % Sampling frequency (Hz)
fsImu       = 50;              % Accel frequency (Hz)
fsGyro      = 50;              % Gyro frequency (Hz)
ppgfilterRange = [0.5 7.0];
filterRange = [0.5 3.5];       % Cardiac bandpass range (Hz) 

% --- SESSION PROCESSING ---
dirContent = dir(rootFolder);
folders = dirContent([dirContent.isdir] & ~startsWith({dirContent.name}, '.'));

for i = 1:length(folders)
    sessionPath =  fullfile(rootFolder, folders(i).name);
    fprintf('Processing Session: %s\n', folders(i).name);
    
    ppgTime = []; filtPpg = []; fVecPpg = []; magFiltPpg = [];
    
    % SECTION A: PHOTOPLETHYSMOGRAPHY (PPG) 
    ppgFiles = dir(fullfile(sessionPath, '*_PHOTOPLETHYSMOGRAPHY.csv'));
    for k = 1:length(ppgFiles)
        try
            [ppgTable, ppgTime] = load_and_clean_ppg(ppgFiles(k), sessionPath);

            % Get folder name and file name without extension
            [~, currentFolder] = fileparts(ppgFiles(k).folder);
            [~, fileNameOnly]  = fileparts(ppgFiles(k).name);
            baseFileName = [currentFolder, ' - ', fileNameOnly];

            % Preprocess (Filter and Invert) 
            [filtPpg, invertedRaw] = preprocess_ppg(ppgTable.GREEN, fsPpg, ppgfilterRange);
            
            % Visual Comparison Time Domain
            hTime = plot_ppg_time_domain(ppgTime, invertedRaw, filtPpg, baseFileName, ppgfilterRange);
            save_plot_as_fig(hTime, sessionPath, baseFileName, '_ppg_t_Raw_Filtered');
            
            % Frequency Domain (FFT)
            [fVecPpg, magRaw] = compute_fft_spectrum(invertedRaw, fsPpg);
            [~, magFiltPpg]   = compute_fft_spectrum(filtPpg, fsPpg);
            
            hFreq = plot_ppg_spectrum(fVecPpg, magRaw, magFiltPpg, baseFileName, ppgfilterRange);
            save_plot_as_fig(hFreq, sessionPath, baseFileName, '_ppg_fft_Raw_Filtered');
        catch ME
            fprintf('  Error PPG %s: %s\n', ppgFiles(k).name, ME.message);
        end
    end

    % SECTION B: ACCELEROMETER (IMU) 
    accFiles = dir(fullfile(sessionPath, '*_ACCELEROMETER.csv'));
    for k = 1:length(accFiles)
        try
            [accTable, accTime] = load_and_clean_imu(accFiles(k), sessionPath);
            
            % Get folder name and file name for baseName
            [~, currentFolder] = fileparts(accFiles(k).folder);
            [~, fileNameOnly]  = fileparts(accFiles(k).name);
            baseName = [currentFolder, ' - ', fileNameOnly];
            
            % 1. Preprocess
            [filtAxes, rawAxes] = preprocess_imu_axes(accTable, fsImu, filterRange);
            
            % 2. Calculate Spectra
            magRawAcc = []; magFiltAcc = [];
            for j = 1:3
                [fVecAcc, magRawAcc(:,j)] = compute_fft_spectrum(rawAxes(:,j), fsImu);
                [~, magFiltAcc(:,j)]      = compute_fft_spectrum(filtAxes(:,j), fsImu);
            end
            
            % 3. Standard Visualizations (3x2 )
            hTimeAcc = plot_imu_time_comparison(accTime, rawAxes, filtAxes, baseName, filterRange);
            save_plot_as_fig(hTimeAcc, sessionPath, baseName, '_acc_t_3axes_Raw_Filt');
            
            hFreqAcc = plot_imu_fft_comparison(fVecAcc, magRawAcc, magFiltAcc, baseName, filterRange);
            save_plot_as_fig(hFreqAcc, sessionPath, baseName, '_acc_fft_3axes_Raw_Filt');
            
            % 4. OVERLAYS (Syncing 84Hz PPG with 50Hz ACC)
            if ~isempty(filtPpg)
                % Time Domain Overlay 
                hOverlayTime = plot_ppg_acc_time_overlay(ppgTime, filtPpg, accTime, filtAxes, baseName);
                save_plot_as_fig(hOverlayTime, sessionPath, baseName, '_acc_ppg_overlay_t');
                
                % Frequency Domain Overlay 
                hOverlayFreq = plot_ppg_acc_fft_overlay(fVecPpg, magFiltPpg, fVecAcc, magFiltAcc, baseName);
                save_plot_as_fig(hOverlayFreq, sessionPath, baseName, '_acc_ppg_overlay_fft');
            end
            
        catch ME
            fprintf('  Error ACC %s: %s\n', accFiles(k).name, ME.message);
        end
    end

    % SECTION C: GYROSCOPE (GYRO) 
    gyroFiles = dir(fullfile(sessionPath, '*_GYROSCOPE.csv'));
    for k = 1:length(gyroFiles)
        try
            [gyroTable, gyroTime] = load_and_clean_imu(gyroFiles(k), sessionPath);

            % Get folder name and file name for baseName
            [~, currentFolder] = fileparts(gyroFiles(k).folder);
            [~, fileNameOnly]  = fileparts(gyroFiles(k).name);
            baseName = [currentFolder, ' - ', fileNameOnly];
           
            
            [filtGyro, rawGyro] = preprocess_imu_axes(gyroTable, fsGyro, filterRange);
            
            magRawG = []; magFiltG = [];
            for j = 1:3
                [fVecG, magRawG(:,j)] = compute_fft_spectrum(rawGyro(:,j), fsGyro);
                [~, magFiltG(:,j)]    = compute_fft_spectrum(filtGyro(:,j), fsGyro);
            end
            
            hTimeG = plot_gyro_time_comparison(gyroTime, rawGyro, filtGyro, baseName, filterRange);
            save_plot_as_fig(hTimeG, sessionPath, baseName, '_gyro_t_3axes_Raw_Filt');
            
            hFreqG = plot_gyro_fft_comparison(fVecG, magRawG, magFiltG, baseName, filterRange);
            save_plot_as_fig(hFreqG, sessionPath, baseName, '_gyro_fft_3axes_Raw_Filt');
      
            % OVERLAYS:
        if ~isempty(filtPpg)
                % Time Domain Overlay 
                hOverlayTimeG = plot_ppg_gyro_time_overlay(ppgTime, filtPpg, gyroTime, filtGyro, baseName);
                save_plot_as_fig(hOverlayTimeG, sessionPath, baseName, '_gyro_ppg_overlay_t');
                
                % Frequency Domain Overlay 
                hOverlayFreqG = plot_ppg_gyro_fft_overlay(fVecPpg, magFiltPpg, fVecG, magFiltG, baseName);
                save_plot_as_fig(hOverlayFreqG, sessionPath, baseName, '_gyro_ppg_overlay_fft');
            end
        catch ME
            fprintf('  Error GYRO %s: %s\n', gyroFiles(k).name, ME.message);
        end
    end
end