function [t, acc, ecg] = load_cometa_data(file_path)
%LOAD_COMETA_DATA Load Cometa accelerometer and ECG signals.
T = readtable(file_path);
T = rmmissing(T);
m = conversion(table2array(T));

t   = m(:,1);
acc = m(:,18);  % IMU_9_ImuAcc_Y_g__
ecg = m(:,10);  % ECG channel
end