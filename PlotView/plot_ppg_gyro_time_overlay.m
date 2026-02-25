function fig = plot_ppg_gyro_time_overlay(ppgTime, ppgFilt, gyroTime, gyroFilt, fileName)
% DESCRIPTION:
% Overlays Gyroscope axes on top of PPG.
% PPG (84 Hz) is used as temporal reference.
% Gyro (50 Hz) is interpolated to PPG time.
%
% INPUTS:
%   ppgTime  - time vector for PPG (84 Hz)
%   ppgFilt  - filtered PPG signal
%   gyroTime - time vector for Gyro (50 Hz)
%   gyroFilt - filtered Gyro [Nx3]
%   fileName - string for title

    fig = figure('Name', ['PPG-GYRO Time Overlay: ', fileName], ...
                 'Color', 'w', ...
                 'Units', 'normalized', ...
                 'Position', [0.1 0.1 0.4 0.8]);

    deepPurple = [0.5 0.1 0.6];
    gyroColors = {[0.8 0.4 0.2], [0.2 0.6 0.2], [0.2 0.4 0.8]};
    axisNames = {'X','Y','Z'};

    % Normalize PPG 
    normPpg = (ppgFilt - mean(ppgFilt)) / std(ppgFilt);

    % Interpolate Gyro → PPG time (84 Hz reference) 
    gyroInterp = zeros(length(ppgTime), 3);

    for j = 1:3
        gyroInterp(:,j) = interp1(gyroTime, gyroFilt(:,j), ...
                                  ppgTime, 'linear', 'extrap');
    end

    % Plotting 
    ax = gobjects(3,1);

    for j = 1:3
        ax(j) = subplot(3,1,j); hold on;

        % Normalize gyro axis
        normG = (gyroInterp(:,j) - mean(gyroInterp(:,j))) / std(gyroInterp(:,j));

        % Plot PPG
        plot(ppgTime, normPpg, ...
             'Color', deepPurple, ...
             'LineWidth', 1.2, ...
             'DisplayName','PPG');

        % Plot Gyro
        hG = plot(ppgTime, normG, ...
                  'LineWidth', 1.5, ...
                  'DisplayName',['Gyro ',axisNames{j}]);

        % Apply transparency
        hG.Color = [gyroColors{j} 0.3];

        title(['Overlay: Gyro ', axisNames{j}, ' vs PPG']);
        ylabel('Normalized Amplitude (z-score)');
        grid on;
        legend('show','Location','northeast');
    end

    xlabel('Time (s)');
    linkaxes(ax,'x');
end