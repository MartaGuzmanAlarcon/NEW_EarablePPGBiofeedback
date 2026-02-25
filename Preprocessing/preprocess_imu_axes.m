function [filtAxes, rawAxes] = preprocess_imu_axes(imuTable, fs, range)
% DESCRIPTION: Detrends and applies a bandpass filter to each axis separately.
% INPUTS:  imuTable - Table with X,Y,Z columns; fs - Hz; range - [low high] Hz.
% OUTPUTS: filtAxes - Filtered Nx3 matrix; rawAxes - Detrended Nx3 matrix.

    % Extracting X, Y, Z columns from CSV
    rawMatrix = [imuTable.X, imuTable.Y, imuTable.Z];
    
    % Remove gravity offset (detrend) to fix scale issues
    rawAxes = detrend(rawMatrix); 
    
    % Design and apply filter to all columns
    [b, a] = butter(2, range / (fs/2), 'bandpass');
    filtAxes = filtfilt(b, a, rawAxes);
end