function [cleanData, timeVec] = load_and_clean_ppg(fileStruct, path)
% DESCRIPTION: Reads PPG CSV, sorts timestamps, and removes duplicates.

% INPUTS:  fileStruct - Directory structure from dir(); path - Session path.
% OUTPUTS: cleanData  - Table of unique PPG samples; timeVec - Relative time (s).

    rawTable = readtable(fullfile(path, fileStruct.name));
    rawTable = sortrows(rawTable, 'timestamp'); 
    [~, uniqueIdx] = unique(rawTable.timestamp, 'stable');
    cleanData = rawTable(uniqueIdx, :);
    
    % Convert microseconds to relative seconds from the first sample 
    timeVec = (cleanData.timestamp - cleanData.timestamp(1)) / 1e6;
end