function [cleanData, timeVec] = load_and_clean_imu(fileStruct, path)
% DESCRIPTION: Reads IMU CSV, sorts by timestamp, and removes duplicates.
% INPUTS:  fileStruct - Directory structure from dir(); path - Session path.
% OUTPUTS: cleanData  - Table containing X, Y, Z acceleration; timeVec - Relative time (s).

    rawTable = readtable(fullfile(path, fileStruct.name));
    rawTable = sortrows(rawTable, 'timestamp'); 
    [~, uniqueIdx] = unique(rawTable.timestamp, 'stable');
    cleanData = rawTable(uniqueIdx, :);
    
    % Convert microseconds to relative seconds
    timeVec = (cleanData.timestamp - cleanData.timestamp(1)) / 1e6;
end