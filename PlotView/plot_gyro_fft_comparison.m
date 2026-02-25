function fig = plot_gyro_fft_comparison(fVec, magRaw, magFilt, fileName, range)
   
fig = figure('Name', ['Gyro FFT: ', fileName], 'Color', 'w', 'Units', 'normalized', 'Position', [0.1 0.1 0.5 0.8], 'Visible', 'on');
    axisTitles = {'X-Axis', 'Y-Axis', 'Z-Axis'};
    colors = {[0.8 0.5 0.2], [0.5 0.8 0.2], [0.2 0.5 0.8]};

    for j = 1:3
        subplot(3, 2, 2*j-1); plot(fVec, magRaw(:,j), 'Color', [0.6 0.6 0.6]); 
        xlim([0 10]); title(['Raw FFT ', axisTitles{j}]); ylabel('Mag'); grid on;
        
        subplot(3, 2, 2*j); plot(fVec, magFilt(:,j), 'Color', colors{j}); 
        xlim([0 10]); title(['Filtered FFT ', axisTitles{j}]); ylabel('Mag'); grid on;
    end
    xlabel(subplot(3,2,5), 'Freq (Hz)'); xlabel(subplot(3,2,6), 'Freq (Hz)');
end