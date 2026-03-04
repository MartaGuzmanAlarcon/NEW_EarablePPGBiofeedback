function [filtSignal, invertedRaw] = preprocess_ppg(rawSignal, fs, range)
% DESCRIPTION: Performs baseline correction and 2nd order bandpass filtering.
% INPUTS:  rawSignal - Vector of raw PPG data; fs - Sample rate; range - [low high] Hz.
% OUTPUTS: filtSignal - Filtered/inverted signal.
    % Remove linear drift to center signal around zero 
    centeredRaw = detrend(rawSignal); 
    
    % Design Zero-phase Butterworth filter 
    [b, a] = butter(2, range / (fs/2), 'bandpass');
    filtSignal = filter(b, a, centeredRaw); % cambié a filter en vez filtfilter
    
    % Invert signal for systolic peak detection 
    filtSignal = -filtSignal; 
    invertedRaw = -centeredRaw;
end