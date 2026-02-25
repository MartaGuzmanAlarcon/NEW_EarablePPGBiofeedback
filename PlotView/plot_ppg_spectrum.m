function fig = plot_ppg_spectrum(fVec, magRaw, magFilt, fileName, range)
% DESCRIPTION: Plots Raw vs Filtered FFT spectra for comparison.
% INPUTS:  fVec - Common frequency vector (Hz); magRaw/magFilt - Normalized magnitudes;
%          fileName - Session ID; range - Filter [low high] Hz.
% OUTPUTS: fig - Figure handle.


    fig = figure('Name', ['FFT: ', fileName], 'Color', 'w', 'Visible', 'on');
    deepPurple = [0.5, 0.1, 0.6]; 

    % Panel 1: RAW DATA SPECTRUM 
    subplot(2,1,1);
    plot(fVec, magRaw, 'Color', [0.4 0.4 0.4], 'DisplayName', 'Raw Spectrum');
    
    xlim([0 10]); % Focus on physiological heart rate and motion
    title('Frequency Domain Analysis');
    ylabel('Magnitude'); grid on;
    legend('show', 'Location', 'northeast');
    
    %  Panel 2: FILTERED DATA SPECTRUM 
    subplot(2,1,2);
    % We use a thicker blue line to highlight the cleaned cardiac signal
    plot(fVec, magFilt, 'Color', deepPurple, 'LineWidth', 1.2, 'DisplayName', 'Filtered Spectrum');    
    xlim([0 10]); 
    
    % The title automatically reflects your 0.5 - 7.0 Hz filter
    dynamicTitle = sprintf('Filtered Spectrum (Cardiac Focus: %g - %g Hz)', range(1), range(2));
    title(dynamicTitle);
    
    xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;
    legend('show', 'Location', 'northeast');
end