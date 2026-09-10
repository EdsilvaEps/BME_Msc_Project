% visualization script
% TODO: drop unused columns

file_dir = "C:\Users\netos\OneDrive\Documents\BME_project\"; % windows
%filename = "20240909_1_mreg_fa25_abdominal_1.lvm";
filenames = ["20240909_1_mreg_fa25_abdominal_1.lvm", ...
            "20240909_1_mreg_fa25_abdominal_2.lvm"];
path = fullfile(file_dir, filename);

function data = extract_table_from_lvm(path)

    data = readtable(path, "FileType", "text", ... 
                        "Delimiter", "\t", ... 
                        "ReadVariableNames", false);

    variable_names =  {'Time', 'Channel_1', 'Channel_2', 'Channel_3_noise', 'Channel_4_voltage', 'Channel_5_voltage_'};
    data.Properties.VariableNames = variable_names;

    % replace decimal commas with decimal points
    data{:,:} = strrep(data{:, :}, ',', '.');

    % convert to numeric
    numeric_data = str2double(data{:, :});

    % add column names to numerical 
    data = array2table(numeric_data, 'VariableNames', variable_names);

end

% create an empty table for storing the data from all files
%n = 2;
%table_data = table( ...
%    'Size', [0, n], ...
%    'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'double'}, ...
%    'VariableNames', {'Time', 'Channel_1', 'Channel_2', 'Channel_3_noise', 'Channel_4_voltage', 'Channel_5_voltage_'} ...
%);

for file_index = 1:length(filenames)
    file = filenames(file_index);
    path = fullfile(file_dir, file);
    data = extract_table_from_lvm(path);

    table_data = [table_data; data]; % append the data to the table

    % separating variables for plotting
    time = data.Time;
    channel_1 = data.Channel_1;
    channel_2 = data.Channel_2;
    channel_3 = data.Channel_3_noise;
    channel_4 = data.Channel_4_voltage;

    % plotting in a 4x4 grid
    figure;
    tiledlayout(2, 2);

    nexttile;
    plot(time, channel_1);
    title('Channel 1');
    xlabel('Time');
    ylabel('Amplitude');

    nexttile;
    plot(time, channel_2);
    title('Channel 2');
    xlabel('Time');
    ylabel('Amplitude');

    nexttile;
    plot(time, channel_3);
    title('Channel 3 (Noise)');
    xlabel('Time');
    ylabel('Amplitude');

    nexttile;
    plot(time, channel_4);
    title('Channel 4 (Voltage)');
    xlabel('Time');
    ylabel('Amplitude');
end