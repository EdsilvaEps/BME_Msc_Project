% function that takes several consecutive nibp datasets and concatenates them into
% a single table

function [nibp_table, transition_points] = concatenate_nibp_data(file_dir, filenames)

    % create an empty table for storing the data from all files
    nibp_table = table();
    transition_points = zeros(length(filenames), 1);

    for file_index = 1:length(filenames)
        
        file = filenames(file_index);
        fprintf("Processing file %s...\n", file);

        path = fullfile(file_dir, file);
        data = extract_table_from_lvm(path);

        nibp_table = [nibp_table; data]; % append the data to the table

        transition_points(file_index) = height(nibp_table); % store the transition point
    end

end

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