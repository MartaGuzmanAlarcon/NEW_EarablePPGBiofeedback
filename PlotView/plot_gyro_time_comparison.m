function fig = plot_gyro_time_comparison(time, rawAxes, filtAxes, fileName, range)
    fig = figure('Name', ['Gyro Time: ', fileName], 'Color', 'w', 'Units', 'normalized', 'Position', [0.1 0.1 0.5 0.8], 'Visible', 'on');
    axisTitles = {'X-Axis', 'Y-Axis', 'Z-Axis'};
    colors = {[0.8 0.5 0.2], [0.5 0.8 0.2], [0.2 0.5 0.8]}; % Tonos ocres/azules para diferenciar del ACC [cite: 2026-02-12]

    for j = 1:3
        subplot(3, 2, 2*j-1); plot(time, rawAxes(:,j), 'Color', [0.6 0.6 0.6]); 
        title(['Raw ', axisTitles{j}]); ylabel('deg/s'); grid on;
        
        subplot(3, 2, 2*j); plot(time, filtAxes(:,j), 'Color', colors{j}); 
        title(['Filtered ', axisTitles{j}]); ylabel('deg/s'); grid on;
    end
    xlabel(subplot(3,2,5), 'Time (s)'); xlabel(subplot(3,2,6), 'Time (s)');
end