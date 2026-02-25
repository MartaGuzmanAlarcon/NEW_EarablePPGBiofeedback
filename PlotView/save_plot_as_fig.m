function save_plot_as_fig(figHandle, sessionPath, baseName, suffix)
% DESCRIPTION: Saves the figure as a MATLAB .fig file and closes the window.
    savePath = fullfile(sessionPath, [baseName, suffix, '.fig']);
    savefig(figHandle, savePath);
    close(figHandle); % Conserve memory during batch processing
end