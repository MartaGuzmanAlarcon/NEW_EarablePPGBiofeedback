clear all 
close all
clc 

% Specify your folder path and date-time string
folder_path = '/Users/martaguzman/Library/CloudStorage/OneDrive-SharedLibraries-KTH/Seraina Dual - 2026_INT_Marta_Guzman_WearableBiofeedback/Recordings/26_02_Cosinuss';
date_time = '2026-02-26_11-10-02';


% Load and plot the data
ear_data = load_and_plot_physiological_data(folder_path, date_time);

% acc = 100Hz 
% ppg = 200Hz 

%% Plot data 
plot(ear_data.acc_x_acc_y_acc_z.data(:,1),-ear_data.acc_x_acc_y_acc_z.data(:,3)*10000+500000);
hold on
plot(ear_data.ppg_ir_ppg_ambient_ppg_red_ppg_green.data(:,1),-ear_data.ppg_ir_ppg_ambient_ppg_red_ppg_green.data(:,2));

% ear_data.acc_x_acc_y_acc_z.data(end,1)
% ear_data.acc_x_acc_y_acc_z.data(end,3)
% t_c=ear_data.ppg_ir_ppg_ambient_ppg_red_ppg_green.data(:,1)
% ear_data.ppg_ir_ppg_ambient_ppg_red_ppg_green.data(end,2)

%% Analyze Cometa

%q=51;

%expr1= '/Usereraina Dual/03_Research/25_Cardiac_Synchronization/05_Data/Clinical study_/P0'; 
%eval('dataSignalPath=[expr1, num2str(q)];')
%addpath(dataSignalPath);
%expr1= 'Protocol P0'
%expr2= '.txt';
%eval('data=[expr1, num2str(q), expr2];')


dataSignalPath = '/Users/martaguzman/Library/CloudStorage/OneDrive-SharedLibraries-KTH/Seraina Dual - 2026_INT_Marta_Guzman_WearableBiofeedback/Recordings/26_02_Cometa';
addpath(dataSignalPath);

archivo_datos = 'Aurora_Walking_ROpenW.txt';
archivo_eventos = 'Aurora_Walking_ROpenW_Insoles_event.txt';
m = readtable(fullfile(dataSignalPath, archivo_datos));

%m=readtable(data);

m=table2array(m);
m=rmmissing(m ...
    );
fs=2000;

m=conversion(m); 

% 
% x=find(m(:,1)>180);
% k(:,:)=m(x(1):end-100000,:);
% m=k;
% t=m(:,1);

        %% Load Insole data with new naming convention
       % insole_filename = sprintf('insoles events P0%d.txt', q); COMENTADO
       insole_filename = archivo_eventos;
        
        % Check if file exists
        % if ~isfile(insole_filename)
        %     warning('Insole file not found: %s. Skipping participant P0%d', insole_filename, q);
        %     continue;
        % end
        
        % Load the insole data
        T_insole = readtable(insole_filename, 'Delimiter', '\t');
        
        % Rename columns
        T_insole.Properties.VariableNames = {'Side', 'Type', 'Time'};
        
        %% Filter only 'On' events
        on_insole = T_insole(strcmp(T_insole.Type, 'On'), :);
        
        % Sort by time
        on_insole = sortrows(on_insole, 'Time');
        
        % Extract time arrays per side
        left_on = on_insole.Time(strcmp(on_insole.Side, 'Left'));
        right_on = on_insole.Time(strcmp(on_insole.Side, 'Right'));
        all_on = on_insole.Time;
        
%% check sampling frequencies

% chest acc --> m(:,18)
% head acc ---> m(:,17)
acc_c=ear_data.acc_x_acc_y_acc_z.data(:,3);
t_c=ear_data.acc_x_acc_y_acc_z.data(:,1);
plot(t_c,acc_c)

acc=m(:,18); 
t=m(:,1);

fs_acc = 2000; % Given as 2000 Hz
dt_acc = mean(diff(t));
fprintf('acc sampling frequency: %.2f Hz (dt = %.6f s)\n', 1/dt_acc, dt_acc);

% For acc_c (variable, calculate from time vector)
dt_c = mean(diff(t_c));
fs_c = 1/dt_c;
fprintf('acc_c original sampling frequency: %.2f Hz (dt = %.6f s)\n', fs_c, dt_c);
%% Step 2: Resample acc_c to match acc's sampling frequency (2000 Hz)
% Use resample function for proper anti-aliasing
% resample(x, p, q) resamples at p/q times the original rate
% We need to go from fs_c to fs_acc

% Calculate resampling ratio
[p, q] = rat(fs_acc/fs_c, 0.0001);  % Find rational approximation

% Resample the signal
acc_c_resampled = resample(acc_c, p, q);

% Create corresponding time vector
t_c_new = (0:length(acc_c_resampled)-1)' / fs_acc + t_c(1);

fprintf('Original acc_c length: %d samples\n', length(acc_c));
fprintf('Resampled acc_c length: %d samples\n', length(acc_c_resampled));
fprintf('acc length: %d samples\n', length(acc));
fprintf('Resampling ratio: p/q = %d/%d = %.6f\n', p, q, p/q);

plot(t_c, acc_c, 'b', 'LineWidth', 1.5, 'DisplayName', 'Original PPG (200 Hz)');
hold on;
plot(t_c_new, acc_c_resampled, 'r--', 'LineWidth', 1, 'DisplayName', 'Resampled PPG (2000 Hz)');
xlabel('Time (s)');


%% Step 3: Normalize signals for cross-correlation
% Remove DC component (mean) and normalize
acc_c_resampled = acc_c_resampled(:);  % Ensure column vector
acc = acc(:);  % Ensure column vector
acc_c_norm = (acc_c_resampled - mean(acc_c_resampled, 'omitnan')) / std(acc_c_resampled, 'omitnan');
acc_norm = (acc - mean(acc, 'omitnan')) / std(acc, 'omitnan');

%% Step 4: Perform cross-correlation
% Use the shorter signal length to avoid edge effects
min_len = min(length(acc_c_norm), length(acc_norm));
acc_c_norm_trimmed = acc_c_norm(1:min_len);
acc_norm_trimmed = acc_norm(1:min_len);
[correlation, lags] = xcorr(acc_c_norm_trimmed, acc_norm_trimmed);

% Find the lag with maximum correlation
[max_corr, max_idx] = max(correlation);
lag_samples = lags(max_idx);
lag_time = lag_samples / fs_acc;

fprintf('\n--- Cross-correlation Results ---\n');
fprintf('Maximum correlation: %.4f\n', max_corr);
fprintf('Lag: %d samples (%.4f seconds)\n', lag_samples, lag_time);


%% Step 5: Align the signals based on the lag
t_c_new = t_c_new(:);
if lag_samples > 0
    % acc_c is ahead (starts earlier), so remove the first lag_samples from acc_c
    if lag_samples < length(acc_c_resampled)
        acc_c_aligned = acc_c_resampled(lag_samples+1:end);
        t_c_aligned = t_c_new(lag_samples+1:end);
        fprintf('acc_c was ahead by %d samples (%.4f sec) - removed from beginning\n', lag_samples, lag_samples/fs_acc);
    else
        warning('Lag (%d) is larger than acc_c length (%d). Using unshifted signal.', lag_samples, length(acc_c_resampled));
        acc_c_aligned = acc_c_resampled(:);
        t_c_aligned = t_c_new;
    end
elseif lag_samples < 0
    % acc is ahead (starts earlier), so remove samples from beginning of acc
    % Or equivalently, pad acc_c at the beginning
    lag_abs = abs(lag_samples);
    acc_c_aligned = [zeros(lag_abs, 1); acc_c_resampled(:)];
    % Create time vector for the padded part
    t_pad = (t_c_new(1) - lag_abs/fs_acc : 1/fs_acc : t_c_new(1) - 1/fs_acc)';
    t_c_aligned = [t_pad; t_c_new];
    fprintf('acc was ahead by %d samples (%.4f sec) - padded acc_c at beginning\n', lag_abs, lag_abs/fs_acc);
else
    % No shift needed
    acc_c_aligned = acc_c_resampled(:);
    t_c_aligned = t_c_new;
    fprintf('Signals are already aligned\n');
end

%% Step 6: Trim to common length
common_len = min(length(acc), length(acc_c_aligned));
acc_final = acc(1:common_len);
acc_c_final = acc_c_aligned(1:common_len);
t_final = t(1:common_len);
t_c_final = t_c_aligned(1:common_len);

%% Step 7: Visualize results
figure('Position', [100 100 1200 800]);
% Plot 1: Original signals
subplot(3,2,1);
plot(t_c, acc_c, 'b', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Acceleration');
title('Original acc\_c (ear data)');
grid on;

subplot(3,2,2);
plot(t, acc, 'r', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Acceleration');
title('Original acc (reference, 2000 Hz)');
grid on;

% Plot 2: Cross-correlation
subplot(3,2,3);
plot(lags/fs_acc, correlation, 'k', 'LineWidth', 1);
hold on;
plot(lag_time, correlation(max_idx), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
xlabel('Lag (seconds)');
ylabel('Cross-correlation');
title(sprintf('Cross-correlation (max at %.4f s)', lag_time));
grid on;
legend('Correlation', 'Maximum');

% Plot 3: Resampled signal
subplot(3,2,4);
plot(t_c_new, acc_c_resampled, 'b', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Acceleration');
title('Resampled acc\_c (2000 Hz)');
grid on;

% Plot 4: Aligned signals overlay
subplot(3,2,[5 6]);
plot( acc_final, 'r', 'LineWidth', 1.5, 'DisplayName', 'acc (reference)');
hold on;
plot( acc_c_final, 'b--', 'LineWidth', 1.5, 'DisplayName', 'acc\_c (aligned)');
xlabel('Time (s)');
ylabel('Acceleration');
title('Aligned Signals (after synchronization)');
legend('Location', 'best');
grid on;


%% Step 8: Calculate correlation coefficient after alignment
corr_coef = corrcoef(acc_final, acc_c_final);
fprintf('\n--- Alignment Quality ---\n');
fprintf('Correlation coefficient after alignment: %.4f\n', corr_coef(1,2));

%% Optional: Save aligned data
% save('aligned_signals.mat', 'acc_final', 'acc_c_final', 't_final', 't_c_final', 'lag_samples', 'lag_time');

fprintf('\n--- Output Variables ---\n');
fprintf('acc_c_final: aligned and resampled acc_c signal\n');
fprintf('acc_final: reference acc signal (trimmed to match)\n');
fprintf('t_final: common time vector\n');


%% Align PPG signal with acc_c

% Extract PPG signal and time
ppg_ir = ear_data.ppg_ir_ppg_ambient_ppg_red_ppg_green.data(:,2);
t_ppg = ear_data.ppg_ir_ppg_ambient_ppg_red_ppg_green.data(:,1);

% Check original PPG sampling frequency
dt_ppg = mean(diff(t_ppg));
fs_ppg = 1/dt_ppg;
fprintf('\n--- PPG Signal Processing ---\n');
fprintf('PPG original sampling frequency: %.2f Hz (dt = %.6f s)\n', fs_ppg, dt_ppg);


%% FILTER PPG BEFORE RESAMPLING (at original 200 Hz sampling rate)
pw = -ppg_ir;

% Define high-pass filter parameters
cutoff_freq = 0.5;  % Cutoff frequency (Hz)
[b, a] = butter(4, cutoff_freq / (fs_ppg / 2), 'high');  % Use fs_ppg here!
ppg_filtered = filtfilt(b, a, pw);  

% Low-pass filter
cutoff_freq = 7;  % Cutoff frequency (Hz)
[b, a] = butter(4, cutoff_freq / (fs_ppg / 2), 'low');  % Use fs_ppg here!
ppg_filtered = filtfilt(b, a, ppg_filtered);  

%% Step 1: Resample FILTERED PPG to 2000 Hz (same as acc)
% Calculate resampling ratio
[p_ppg, q_ppg] = rat(fs_acc/fs_ppg, 0.0001);  % Find rational approximation

% Resample the FILTERED PPG signal
ppg_ir_resampled = resample(ppg_filtered, p_ppg, q_ppg);

% Create corresponding time vector
t_ppg_new = (0:length(ppg_ir_resampled)-1)' / fs_acc + t_ppg(1);

fprintf('Original PPG length: %d samples\n', length(ppg_ir));
fprintf('Resampled PPG length: %d samples\n', length(ppg_ir_resampled));
fprintf('Resampling ratio: p/q = %d/%d = %.6f\n', p_ppg, q_ppg, p_ppg/q_ppg);

plot(t_ppg, ppg_filtered, 'b', 'LineWidth', 1.5, 'DisplayName', 'Original PPG (200 Hz)');
hold on;
plot(t_ppg_new, ppg_ir_resampled, 'r', 'LineWidth', 1, 'DisplayName', 'Resampled PPG (2000 Hz)');
xlabel('Time (s)');
%% Step 2: Apply the same lag correction as acc_c
% Use the lag_samples calculated from acc_c alignment
t_ppg_new = t_ppg_new(:);
ppg_ir_resampled = ppg_ir_resampled(:);

if lag_samples > 0
    % Remove the first lag_samples from PPG (same as was done for acc_c)
    if lag_samples < length(ppg_ir_resampled)
        ppg_ir_aligned = ppg_ir_resampled(lag_samples+1:end);
        t_ppg_aligned = t_ppg_new(lag_samples+1:end);
        fprintf('PPG shifted by %d samples (%.4f sec) - removed from beginning\n', lag_samples, lag_samples/fs_acc);
    else
        warning('Lag (%d) is larger than PPG length (%d). Using unshifted signal.', lag_samples, length(ppg_ir_resampled));
        ppg_ir_aligned = ppg_ir_resampled;
        t_ppg_aligned = t_ppg_new;
    end
elseif lag_samples < 0
    % Pad PPG at the beginning (same as was done for acc_c)
    lag_abs = abs(lag_samples);
    ppg_ir_aligned = [zeros(lag_abs, 1); ppg_ir_resampled];
    % Create time vector for the padded part
    t_pad_ppg = (t_ppg_new(1) - lag_abs/fs_acc : 1/fs_acc : t_ppg_new(1) - 1/fs_acc)';
    t_ppg_aligned = [t_pad_ppg; t_ppg_new];
    fprintf('PPG padded at beginning by %d samples (%.4f sec)\n', lag_abs, lag_abs/fs_acc);
else
    % No shift needed
    ppg_ir_aligned = ppg_ir_resampled;
    t_ppg_aligned = t_ppg_new;
    fprintf('PPG signals are already aligned\n');
end

%% Step 3: Trim PPG to common length (same as acc_c_final)
ppg_ir_final = ppg_ir_aligned(1:common_len);

%% Step 4: Plot PPG with acc_c using t_final
figure('Position', [100 100 1200 600]);

% Normalize signals for better visualization
acc_c_norm_plot = (acc_c_final - mean(acc_c_final)) / std(acc_c_final);
ppg_ir_norm_plot = (ppg_ir_final - mean(ppg_ir_final)) / std(ppg_ir_final);

% Plot both signals
subplot(2,1,1);
plot(t_final, acc_c_norm_plot, 'b', 'LineWidth', 1.5, 'DisplayName', 'acc\_c (normalized)');
hold on;
plot(t_final, ppg_ir_norm_plot, 'r', 'LineWidth', 1.5, 'DisplayName', 'PPG IR (normalized)');
xlabel('Time (s)');
ylabel('Normalized Amplitude');
title('Aligned acc\_c and PPG IR signals (normalized)');
legend('Location', 'best');
grid on;

% Plot with separate y-axes for actual values
subplot(2,1,2);
yyaxis left
plot(t_final, acc_c_final, 'b', 'LineWidth', 1.5);
ylabel('Acceleration (acc\_c)', 'Color', 'b');
ylim([min(acc_c_final) max(acc_c_final)]);

yyaxis right
plot(t_final, ppg_ir_final, 'r', 'LineWidth', 1.5);
ylabel('PPG IR Amplitude', 'Color', 'r');
ylim([min(ppg_ir_final) max(ppg_ir_final)]);

xlabel('Time (s)');
title('Aligned acc\_c and PPG IR signals (dual y-axis)');
grid on;

fprintf('\n--- PPG Alignment Complete ---\n');
fprintf('ppg_ir_final: aligned and resampled PPG signal\n');
fprintf('Length: %d samples\n', length(ppg_ir_final));
fprintf('Time range: %.2f to %.2f seconds\n', t_final(1), t_final(end));



%%
pw=ppg_ir_final;
[ footIndex1, systolicIndex1, notchIndex1, dicroticIndex1 ] = BP_annotate(pw, 2000, 1, 'V', 1);
footIndex = (footIndex1 - 1) * (2000 / 200) +1 ; % Any further correction ? 
systolicIndex = (systolicIndex1 - 1) * (2000 / 200) +1 ; % Any further correction ? 
notchIndex = (notchIndex1 - 1) * (2000 / 200) +1 ; % Any further correction ? 
dicroticIndex  = (dicroticIndex1 - 1) * (2000 / 200) +1 ; % Any further correction ? 

figure()
hold on;
plot(t(footIndex), pw(footIndex), 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
plot(t(systolicIndex), pw(systolicIndex), 'bo', 'MarkerSize', 5, 'MarkerFaceColor', 'b');
plot(t(notchIndex), pw(notchIndex), 'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'k');
plot(t(dicroticIndex), pw(dicroticIndex), 'go', 'MarkerSize', 5, 'MarkerFaceColor', 'g');
plot(t, pw,'LineWidth',1.5);
indices=footIndex;


%%
%indices=Intersecting_tangent_point(pw);
%%
plot(t, pw,'LineWidth',1.5);
hold on 
plot(t,m(:,10)*1500)
hold on 
plot(t,m(:,17)*1500)
hold on 
plot(t(footIndex), pw(footIndex), 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r');


%%
ecg=m(:,10);
fny=fs/2;
Wp=0.1/fny;
Ws=0.05/fny;
Rp=1;
Rs=20;
[n,Wp]=cheb1ord(Wp,Ws,Rp,Rs);
[b,a]=cheby1(n,Rp,Wp,'high');
ecg=filtfilt(b,a,m(:,10));
%LP 
Wp=40/fny;
Ws=45/fny;
Rp=1;
Rs=20;
[n,Wp]=cheb1ord(Wp,Ws,Rp,Rs);
[b,a]=cheby1(n,Rp,Wp,'low');
ecg=filtfilt(b,a,ecg);

plot(t,ecg)
hold on 
plot(t,m(:,10))
legend('Filtered', 'Not filtered')

%[qrs_ampl,qrs_index_1,delay]=pan_tompkin(m(:,10),fs,1)

[qrs_index]=pantompkins_qrs(ecg,fs); % check differences 

plot(t,ecg,'LineWidth',1.5);
hold on
plot(t(qrs_index),ecg(qrs_index),'bo', 'MarkerSize', 5, 'MarkerFaceColor', 'b')
%hold on
%plot(t(qrs_index_1), m(qrs_index_1,10), 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r');


%HR 
RR=diff(m(qrs_index,1));
HR_ECG=(60./(RR));

plot(HR_ECG,'bo', 'MarkerSize', 5, 'MarkerFaceColor', 'b');

%%

%1. Outliers detection --> 30 seconds before and after and then you calculate std nad if the value is 2-3 std in that range I keep otherwise I remove
s_t=2;
RR_intervals = RR;  % Replace this with your actual data

% Define the time window (30 seconds before and after, total 60 seconds)
window_size = 30 * fs;  % 30 seconds before and after

% Initialize the filtered RR_intervals vector
filtered_RR_intervals = RR_intervals;  

% Loop over each RR interval in the vector
for i = 1:length(RR_intervals)
    
    % Determine the window around the current peak (30 seconds before and after)
    start_index = max(1, i - window_size);  % Ensure index is within bounds
    end_index = min(length(RR_intervals), i + window_size);  % Ensure index is within bounds
    
    % Extract the window of RR intervals
    window = RR_intervals(start_index:end_index);
    
    % Calculate the mean and standard deviation of the window
    mean_window = mean(window);
    std_window = std(window);
    
    % Check if the RR interval is within 2 standard deviations of the mean
    if abs(RR_intervals(i) - mean_window) > s_t* std_window
        filtered_RR_intervals(i) = 0;  % Replace with 0 if outside 2 std deviations
    end
end


plot(60./RR);
hold on
plot(60./filtered_RR_intervals);

x=find(filtered_RR_intervals==0);
qrs_index(x+1)=[]; % I am considering that the wrong one is the last found index
filtered_RR_intervals(x)=[];
RR(x)=[];

%%
step=on_insole.Time;

pulse_experiment=generate_PW_structure_RR(m(:,1),pw,m(:,10),qrs_index,footIndex,step);

%%
[results, results1]=phase(t(qrs_index),step);
phase_percentage=(results'./RR).*100;
%% 

plot(m(:,5))
hold on 
plot(m(:,10)*100+50)
hold on 

plot(-m(:,16)*100)
hold on 
plot(m(:,6),'k')

%%
process_and_save_waveforms_PW(ecg,pw,qrs_index, t, phase_percentage,'P51',m(:,17))
