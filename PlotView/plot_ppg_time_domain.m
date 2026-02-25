function fig = plot_ppg_time_domain (time, raw, filtered, fileName, range)
% DESCRIPTION: Generates Time Domain comparison plots for PPG data.
%              Uses a Deep Purple theme for the filtered signal.
% INPUTS:  time - Time vector (s); raw - Inverted/detrended raw signal; 
%          filtered - Processed signal; fileName - Session ID; range - Filter [low high] Hz.
% OUTPUTS: fig - Figure handle.

    fig = figure('Name', ['PPG Time: ', fileName], 'Color', 'w', 'Visible', 'on');
    
    deepPurple = [0.5, 0.1, 0.6]; 
    
    % --- Panel 1: Raw Data (Detrended and Inverted) ---
    subplot(2,1,1);
    plot(time, raw, 'Color', [0.6 0.6 0.6], 'DisplayName', 'Raw PPG');
    title('PPG Raw (Detrended and Inverted) '); 
    ylabel('Amplitude'); 
    grid on;
    legend('show', 'Location', 'northeast');
    
    % --- Panel 2: Processed Data (Filtered) ---
    subplot(2,1,2);
    plot(time, filtered, 'Color', deepPurple, 'LineWidth', 1.3, 'DisplayName', 'Filtered PPG');
    
    % Dynamic title showing the filter configuration
    dynamicTitle = sprintf('Filtered PPG (%g Hz - %g Hz)', range(1), range(2));
    title(dynamicTitle); 
    
    xlabel('Time (s)'); 
    ylabel('Amplitude'); 
    grid on;
    legend('show', 'Location', 'northeast');
end