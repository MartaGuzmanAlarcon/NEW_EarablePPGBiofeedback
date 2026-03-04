function [t, acc] = load_ow_acc(folder_path)
%LOAD_OW_ACC Load OpenWearable accelerometer signal.

imu_file = dir(fullfile(folder_path,'*ACCELEROMETER*.csv'));

if isempty(imu_file)
    error('No accelerometer file found in OW folder.');
end

[imu_table, t] = load_and_clean_imu(imu_file(1), folder_path);

acc_mps2 = imu_table.Y;
acc = acc_mps2 / 9.81;

end