function fig = plot_ppg_acc_time_overlay(ppgTime, ppgFilt, accTime, accFilt, fileName)
% DESCRIPTION:
% Overlays ACC axes on top of PPG after proper temporal alignment.
% PPG is the temporal reference (84 Hz). IMU (50 Hz) is interpolated to PPG time.
%
% INPUTS:
%   ppgTime  - time vector for PPG (84 Hz)
%   ppgFilt  - filtered PPG signal
%   accTime  - time vector for IMU (50 Hz)
%   accFilt  - filtered IMU [Nx3] (X,Y,Z)
%   fileName - string for figure title

    
    fig = figure('Name', ['PPG-ACC - Time Overlay: ', fileName], ...
                 'Color', 'w', ...
                 'Units', 'normalized', ...
                 'Position', [0.1 0.1 0.4 0.8]);

    deepPurple = [0.5 0.1 0.6];
    accColors = {[0.8 0.2 0.2], [0.1 0.5 0.1], [0.2 0.2 0.8]};
    axisNames = {'X','Y','Z'};

    % NORMALIZE PPG (reference signal) 
    normPpg = (ppgFilt - mean(ppgFilt)) / std(ppgFilt);

    % INTERPOLATE IMU → PPG TIME (84 Hz reference) 
    accInterp = zeros(length(ppgTime), 3);

    for j = 1:3
        accInterp(:,j) = interp1(accTime, accFilt(:,j), ...
                                 ppgTime, 'linear', 'extrap');
    end

    % PLOTTING 
    ax = gobjects(3,1);

    for j = 1:3
        ax(j) = subplot(3,1,j); hold on;

        % Normalize interpolated IMU axis
        normAcc = (accInterp(:,j) - mean(accInterp(:,j))) / std(accInterp(:,j));

        % Plot PPG (reference)
        plot(ppgTime, normPpg, ...
             'Color', deepPurple, ...
             'LineWidth', 1.2, ...
             'DisplayName','PPG');

        % Plot IMU axis (transparent)
        hAcc = plot(ppgTime, normAcc, ...
                    'LineWidth', 1.5, ...
                    'DisplayName',['Acc ',axisNames{j}]);

        % Set color + transparency
        hAcc.Color = [accColors{j} 0.3];

        title(['Overlay: Acc ', axisNames{j}, ' vs PPG']);
        ylabel('Normalized Amplitude (z-score)');
        grid on;
        legend('show','Location','northeast');
    end

    xlabel('Time (s)');
    linkaxes(ax,'x');

end