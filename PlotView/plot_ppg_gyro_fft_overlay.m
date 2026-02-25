function fig = plot_ppg_gyro_fft_overlay(fVecPpg, ppgMag, fVecG, gyroMag, fileName)
% DESCRIPTION: Spectral mask overlay for Gyroscope vs PPG.
% INPUTS: fVecPpg (84Hz), ppgMag | fVecG (50Hz), gyroMag | fileName.

    fig = figure('Name', ['PPG-GYRO FFT Overlay: ', fileName], 'Color', 'w', ...
                 'Units', 'normalized', 'Position', [0.5 0.1 0.4 0.8], 'Visible', 'on');
    
    deepPurple = [0.5, 0.1, 0.6];
    gyroColors = {[0.8 0.4 0.2], [0.2 0.6 0.2], [0.2 0.4 0.8]};
    axisNames = {'X', 'Y', 'Z'};
    normPpgMag = ppgMag / max(ppgMag); % Normalización 0-1 [cite: 122]

    for j = 1:3
        subplot(3, 1, j); hold on;
        
        % PPG Spectrum
        plot(fVecPpg, normPpgMag, 'Color', deepPurple, 'LineWidth', 1.5, 'DisplayName', 'PPG Spectrum');
        
        % Gyro Spectral Mask [cite: 192]
        normGMag = gyroMag(:,j) / max(gyroMag(:,j));
        area(fVecG, normGMag, 'FaceColor', gyroColors{j}, 'FaceAlpha', 0.2, ...
             'EdgeColor', gyroColors{j}, 'EdgeAlpha', 0.4, 'DisplayName', ['MA Mask (Gyro ', axisNames{j}, ')']);
        
        xlim([0 10]); title(['Spectral Mask: Gyro ', axisNames{j}, ' over PPG']);
        ylabel('Normalized Magnitude'); grid on;
        legend('show', 'Location', 'northeast');
    end
    xlabel('Frequency (Hz)');
end