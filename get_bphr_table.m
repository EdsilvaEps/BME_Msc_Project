% get the BPHR reference 

function BPHR_table = get_bphr_table(file_dir, file)
    % TODO: verify for missing values

    bphr_path = fullfile(file_dir, file);
    fprintf("Processing file %s...\n", file);
    
    BPHR_table = readtable(bphr_path, "FileType", "text", ...
                    "Delimiter", "\t", ...
                    "ReadVariableNames", false);

    % keep only columns 4 5 and 6, for time and ch1/ch2 hr
    BPHR_table = BPHR_table(:,[4 5 6]);

    % name columns
    variable_names = {'Time', 'Channel_1_HR', 'Channel_2_HR'};
    BPHR_table.Properties.VariableNames = variable_names;

    % replace decimal commas with decimal points
    BPHR_table{:,:} = strrep(BPHR_table{:, :}, ',', '.');

    % convert to numeric
    numeric_data = str2double(BPHR_table{:, :});

    % add column names to numerical 
    BPHR_table = array2table(numeric_data, 'VariableNames', variable_names);

end
    