function process_nibp_data(input_path, interval)

    arguments
        input_path (1,:) char  % path to a single .lvm file or a folder containing .lvm files
        interval (1,2) double = [0 0] % optional time interval for plotting
    end


    file_types = [
        "_1_mreg_fa25_abdominal_", ...
        "_1_mreg_fa25_abdominal_oikea_", ...
        "_1_mreg_fa25_controlled_", ...
        "_1_mreg_fa25_ec_", ...
        "_1_mreg_fa25_slow_", ...
        "_1_mreg_fa25_uijay_"
    ];

    % get base folder
    [folder, ~, ~] = fileparts(input_path); 

    if isfile(input_path)
        disp("single file given, processing...")
        
        % find all files related to the input file
        [files, base_name] = find_related_files(input_path);

        % concatenate raw data files (reference file is the last one)
        [nibp_table, transition_pts] = concatenate_nibp_data(folder, files(1:end-1));
        
        % get the reference data
        bphr_table = get_bphr_table(folder, files(end));

        % plot everything
        plot_nibp_data(nibp_table, bphr_table, transition_pts, base_name, interval);    

    elseif isfolder(input_path)
        disp("processing whole folder")

        % grab the folder name for processing and plot naming
        [~, folder_name] = fileparts(input_path);

        % list all the .lvm files in this folder
        all_folder_files = dir(fullfile(input_path));

        % search the folder for the types of files we have
        for k = 1:numel(file_types)

            for i = 1:numel(all_folder_files)

                if contains(all_folder_files(i).name, file_types(k))

                    fprintf("Found %s files, processing...\n", file_types(k));

                    filename = strcat(folder_name, file_types(k), '1.lvm');
                    disp(filename)

                    % once a file with the pattern is found, find its similar files
                    [files, ~] = find_related_files(fullfile(input_path, filename));

                    % concatenate raw data files (reference file is the last one)
                    [nibp_table, transition_pts] = concatenate_nibp_data(input_path, files(1:end-1));
                    
                    % get the reference data
                    bphr_table = get_bphr_table(input_path, files(end));

                    % plot everything
                    plot_nibp_data(nibp_table, ...
                                   bphr_table, ...
                                   transition_pts, ...
                                   strcat(folder_name, "-", file_types(k)), ...
                                   interval);

                    % move on to the next file type at first finding
                    break;
                end
            end
        end

    else
        error("not a valid file");
    end
        

end