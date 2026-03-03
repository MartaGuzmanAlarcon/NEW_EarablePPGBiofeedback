function data_struct = load_and_plot_physiological_data(folder_path, date_time_str)
    % Load and plot physiological data from CSV files
    % 
    % Inputs:
    %   folder_path: Path to folder containing CSV files
    %   date_time_str: Date and time string (e.g., '2026-01-23_11-17-10')
    %
    % Output:
    %   data_struct: Structure containing all loaded data
    %
    % Example usage:
    %   data = load_and_plot_physiological_data('C:\Data\', '2026-01-23_11-17-10');
    
    % Define the signal types we want to load
    signal_files = {
        'acc_x_acc_y_acc_z'
        'respiration_rate'
        'ppg_ir_ppg_ambient_ppg_red_ppg_green'
        'theta'
        'omega'
        'phi'
    };
    
    % Initialize the data structure
    data_struct = struct();
    
    % Get the person hash from the first file found
    file_list = dir(fullfile(folder_path, '*.csv'));
    if isempty(file_list)
        error('No CSV files found in the specified folder');
    end
    
    % Extract person hash from filename (e.g., 'KV7R.8GE9')
    first_file = file_list(1).name;
    person_hash = regexp(first_file, '^[^_]+', 'match', 'once');
    
    % Load each signal file
    for i = 1:length(signal_files)
        signal_name = signal_files{i};
        
        % Construct filename
        filename = sprintf('%s_%s_%s.csv', person_hash, date_time_str, signal_name);
        filepath = fullfile(folder_path, filename);
        
        % Check if file exists
        if ~exist(filepath, 'file')
            warning('File not found: %s', filename);
            continue;
        end
        
        % Read the CSV file
        fprintf('Loading: %s\n', filename);
        
        % Read the entire file as cell array to handle mixed types better
        fid = fopen(filepath, 'r');
        if fid == -1
            warning('Could not open file: %s', filename);
            continue;
        end
        
        % Read all lines
        file_lines = {};
        while ~feof(fid)
            file_lines{end+1} = fgetl(fid);
        end
        fclose(fid);
        
        if length(file_lines) < 13
            warning('File too short: %s', filename);
            continue;
        end
        
        % Extract metadata (rows 1-11)
        metadata = struct();
        for row = 1:11
            line_parts = strsplit(file_lines{row}, ',');
            if length(line_parts) >= 2
                key = strtrim(line_parts{1});
                value = strtrim(line_parts{2});
                if ~isempty(key)
                    field_name = matlab.lang.makeValidName(key);
                    metadata.(field_name) = value;
                end
            end
        end
        
        % Extract column headers from row 12
        header_line = file_lines{12};
        headers_raw = strsplit(header_line, ',');
        headers = {};
        for i = 1:length(headers_raw)
            h = strtrim(headers_raw{i});
            if ~isempty(h)
                headers{end+1} = h;
            end
        end
        
        if isempty(headers)
            warning('No headers found in: %s', filename);
            continue;
        end
        
        % Extract actual data (rows 13+)
        num_data_rows = length(file_lines) - 12;
        data_matrix = zeros(num_data_rows, length(headers));
        
        for row = 1:num_data_rows
            line_idx = row + 12;
            if line_idx <= length(file_lines)
                line_parts = strsplit(file_lines{line_idx}, ',');
                for col = 1:min(length(headers), length(line_parts))
                    val_str = strtrim(line_parts{col});
                    if ~isempty(val_str)
                        data_matrix(row, col) = str2double(val_str);
                    end
                end
            end
        end
        
        % Store in structure
        clean_signal_name = matlab.lang.makeValidName(signal_name);
        data_struct.(clean_signal_name).metadata = metadata;
        data_struct.(clean_signal_name).headers = headers;
        data_struct.(clean_signal_name).data = data_matrix;
        
        fprintf('  Loaded %d rows × %d columns\n', size(data_matrix, 1), size(data_matrix, 2));
    end
    
    % Create plots
    plot_all_signals(data_struct);
end

function plot_all_signals(data_struct)
    % Plot all signals in subplots
    
    field_names = fieldnames(data_struct);
    num_signals = length(field_names);
    
    if num_signals == 0
        warning('No data to plot');
        return;
    end
    
    % Create figure
    figure('Name', 'Physiological Signals', 'Position', [100, 100, 1200, 800]);
    
    % Determine subplot layout
    num_cols = 2;
    num_rows = ceil(num_signals / num_cols);
    
    % Plot each signal
    for i = 1:num_signals
        signal_name = field_names{i};
        signal_data = data_struct.(signal_name);
        
        subplot(num_rows, num_cols, i);
        
        % Get time vector (first column)
        time = signal_data.data(:, 1);
        
        % Plot all data columns (excluding time)
        if size(signal_data.data, 2) > 1
            plot(time, signal_data.data(:, 2:end), 'LineWidth', 1.5);
            
            % Create legend from headers (excluding time)
            if length(signal_data.headers) > 1
                legend(signal_data.headers{2:end}, 'Location', 'best', 'Interpreter', 'none');
            end
        end
        
        % Format plot
        grid on;
        xlabel('Time (s)');
        title(strrep(signal_name, '_', ' '), 'Interpreter', 'none');
        
        % Add y-label based on signal type
        if contains(signal_name, 'acc')
            ylabel('Acceleration');
        elseif contains(signal_name, 'respiration')
            ylabel('Respiration Rate');
        elseif contains(signal_name, 'ppg')
            ylabel('PPG Signal');
        else
            ylabel('Value');
        end
    end
    
    % Add overall title
    sgtitle('Physiological Signal Analysis', 'FontSize', 14, 'FontWeight', 'bold');
end