% visualization script
% TODO: drop unused columns

% file_dir = "C:\Users\netos\OneDrive\Documents\BME_Msc_Project\"; % windows personal machine
file_dir = "/home/enascime24/NIBP/20240909/"; % OYS linux machine
%filename = "20240909_1_mreg_fa25_abdominal_1.lvm";
filenames = ["20240909_1_mreg_fa25_abdominal_1.lvm", ...
            "20240909_1_mreg_fa25_abdominal_2.lvm", ...
            "20240909_1_mreg_fa25_abdominal_3.lvm", ...
            "20240909_1_mreg_fa25_abdominal_4.lvm", ...
            "20240909_1_mreg_fa25_abdominal_5.lvm", ...
            "20240909_1_mreg_fa25_abdominal_6.lvm"];

% get the software reference for HR
bphr_filename = "20240909_1_mreg_fa25_abdominal_BPHR.lvm"; 
bphr_path = fullfile(file_dir, bphr_filename);
bphr_table = get_bphr_table(bphr_path);

function data = extract_table_from_lvm(path)
    % TODO: verify for missing values

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
table_data = table();
transition_points = zeros(length(filenames), 1);
%table_data = table( ...
%    'Size', [0, n], ...
%    'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'double'}, ...
%    'VariableNames', {'Time', 'Channel_1', 'Channel_2', 'Channel_3_noise', 'Channel_4_voltage', 'Channel_5_voltage_'} ...
%);

for file_index = 1:length(filenames)
    
    file = filenames(file_index);
    fprintf("Processing file %s...\n", file);

    path = fullfile(file_dir, file);
    data = extract_table_from_lvm(path);

    table_data = [table_data; data]; % append the data to the table

    transition_points(file_index) = height(table_data); % store the transition point
end

% separating variables for plotting
time = table_data.Time;
channel_1 = table_data.Channel_1;
channel_2 = table_data.Channel_2;
channel_3 = table_data.Channel_3_noise;
channel_4 = table_data.Channel_4_voltage;

time_bphr = bphr_table.Time;
mock_y_axis = zeros(size(time)); % create a mock y-axis for plotting
channel_1_bphr = bphr_table.Channel_1_HR;
channel_2_bphr = bphr_table.Channel_2_HR;


% plotting
figure;
tiledlayout(2, 2);

nexttile;
plot(time, channel_1);
title('Channel 1 - Raw Data');
xlabel('Time');
ylabel('Amplitude');

% annotate transition points
hold on;
for i = 1:length(transition_points)
    xline(time(transition_points(i)), 'r--', sprintf('End of file %d', i), 'LabelVerticalAlignment', 'bottom');
end
hold off;

nexttile;
plot(time, channel_2);
title('Channel 2 - Raw Data');
xlabel('Time');
ylabel('Amplitude');

% annotate transition points
hold on;
for i = 1:length(transition_points)
    xline(time(transition_points(i)), 'r--', sprintf('End of file %d', i), 'LabelVerticalAlignment', 'bottom');
end
hold off;

nexttile;
plot(time, mock_y_axis);
hold on;
plot(time_bphr, channel_1_bphr, 'g', 'LineWidth', 1.5);
hold off;
title('Channel 1 BPHR Reference');
xlabel('Time');
ylabel('Amplitude');

nexttile;
plot(time, mock_y_axis);
hold on;
plot(time_bphr, channel_2_bphr, 'g', 'LineWidth', 1.5);
hold off;
title('Channel 2 BPHR Reference');
xlabel('Time');
ylabel('Amplitude');

sgt = sgtitle("2024/09/09 1 MREG fa25 abdominal");
sgt.FontSize = 20;

%nexttile;
%plot(time, channel_3);
%title('Channel 3 (Noise)');
%xlabel('Time');
%ylabel('Amplitude');

%nexttile;
%plot(time, channel_4);
%title('Channel 4 (Voltage)');
%xlabel('Time');
%ylabel('Amplitude');
