function fig = plot_imu_time_comparison(time, rawAxes, filtAxes, fileName, range)
% DESCRIPTION: Plots a 3x2 grid comparing Raw and Filtered IMU axes in Time Domain.
% INPUTS:  time - Seconds; rawAxes/filtAxes - Nx3 matrices; fileName - ID; range - Hz.
% OUTPUTS: fig - Figure handle.

    fig = figure('Name', ['IMU Time: ', fileName], 'Color', 'w', 'Units', 'normalized', 'Position', [0.1 0.1 0.5 0.8], 'Visible', 'on');
    axisTitles = {'X-Axis', 'Y-Axis', 'Z-Axis'};
    colors = {[0.8 0.2 0.2], [0.1 0.5 0.1], [0.2 0.2 0.8]}; % Red, Green, Blue 

    for i = 1:3
        % Column 1: RAW IMU (Detrended)
        subplot(3, 2, 2*i-1);
        plot(time, rawAxes(:,i), 'Color', [0.6 0.6 0.6]); 
        title(['Raw ', axisTitles{i}]); ylabel('m/s^2'); grid on;
        
        % Column 2: FILTERED IMU
        subplot(3, 2, 2*i);
        plot(time, filtAxes(:,i), 'Color', colors{i}, 'LineWidth', 1.1);
        title(['Filtered ', axisTitles{i}, ' (', num2str(range(1)), '-', num2str(range(2)), ' Hz)']); 
        ylabel('m/s^2'); grid on;
    end
    xlabel(subplot(3,2,5), 'Time (s)'); xlabel(subplot(3,2,6), 'Time (s)');
