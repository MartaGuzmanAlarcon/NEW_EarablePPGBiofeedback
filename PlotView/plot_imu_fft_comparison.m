function fig = plot_imu_fft_comparison(fVec, magRaw, magFilt, fileName, range)
% DESCRIPTION: Plots a 3x2 grid comparing Raw and Filtered IMU spectra.
% INPUTS:  fVec - Frequency vector; magRaw/magFilt - Nx3 matrices; fileName - ID; range - Hz.
% OUTPUTS: fig - Figure handle.

    fig = figure('Name', ['IMU FFT: ', fileName], 'Color', 'w', 'Units', 'normalized', 'Position', [0.1 0.1 0.5 0.8], 'Visible', 'on');
    axisTitles = {'X-Axis', 'Y-Axis', 'Z-Axis'};
    colors = {[0.8 0.2 0.2], [0.1 0.5 0.1], [0.2 0.2 0.8]};

    for i = 1:3
        % Column 1: RAW FFT (Fixes the 10^4 scale issue)
        subplot(3, 2, 2*i-1);
        plot(fVec, magRaw(:,i), 'Color', [0.6 0.6 0.6]);
        xlim([0 10]); title(['Raw FFT ', axisTitles{i}]); ylabel('Mag'); grid on;
        
        % Column 2: FILTERED FFT
        subplot(3, 2, 2*i);
        plot(fVec, magFilt(:,i), 'Color', colors{i}, 'LineWidth', 1.1);
        xlim([0 10]); title(['Filtered FFT ', axisTitles{i}]); ylabel('Mag'); grid on;
    end
    xlabel(subplot(3,2,5), 'Freq (Hz)'); xlabel(subplot(3,2,6), 'Freq (Hz)');
end