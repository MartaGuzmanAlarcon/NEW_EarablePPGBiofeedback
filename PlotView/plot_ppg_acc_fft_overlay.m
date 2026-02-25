function fig = plot_ppg_acc_fft_overlay(fVecPpg, ppgMag, fVecAcc, accMag, fileName)
% DESCRIPTION: Overlays PPG and ACC spectra using their specific frequency vectors.
%              This handles the 84Hz vs 50Hz sampling difference correctly. [cite: 2026-02-12]
% INPUTS: fVecPpg (Hz), ppgMag (PPG), fVecAcc (Hz), accMag (ACC), fileName.

    fig = figure('Name', ['PPG-ACC - FFT Overlay: ', fileName], 'Color', 'w', ...
                 'Units', 'normalized', 'Position', [0.5 0.1 0.4 0.8], 'Visible', 'on');
    
    deepPurple = [0.5, 0.1, 0.6]; % PPG Base Color [cite: 2026-02-12]
    accColors = {[0.8 0.2 0.2], [0.1 0.5 0.1], [0.2 0.2 0.8]}; % R, G, B
    axisNames = {'X', 'Y', 'Z'};

    % Normalización al pico máximo para comparar la forma de los espectros
    normPpgMag = ppgMag / max(ppgMag);

    for j = 1:3
        subplot(3, 1, j); hold on;
        
        % 1. DIBUJAMOS LA PPG AL FONDO (Usando fVecPpg de 84Hz)
        plot(fVecPpg, normPpgMag, 'Color', deepPurple, 'LineWidth', 1.5, 'DisplayName', 'PPG Spectrum');
        
        % 2. DIBUJAMOS EL ACC ENCIMA (Usando fVecAcc de 50Hz)
        normAccMag = accMag(:,j) / max(accMag(:,j));
        
        % 'area' crea la máscara transparente de ruido
        area(fVecAcc, normAccMag, 'FaceColor', accColors{j}, 'FaceAlpha', 0.2, ...
             'EdgeColor', accColors{j}, 'EdgeAlpha', 0.4, 'DisplayName', ['MA Mask (Acc ', axisNames{j}, ')']);
        
        xlim([0 10]); % Rango de interés para HR y movimiento humano
        title(['Spectral Mask: Acc ', axisNames{j}, ' over PPG']);
        ylabel('Normalized Magnitude'); grid on;
        
        legend('show', 'Location', 'northeast');  
    end
    xlabel('Frequency (Hz)');
end