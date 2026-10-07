function [nibp_table] = process_nibp_data(input_path, interval)

    arguments
        input_path (1,:) char  % path to a single .lvm file or a folder containing .lvm files
        interval (1,2) double = [0 0] % optional time interval for plotting
    end

    % add scripts folder from relative path
    projectRoot = fileparts(mfilename("fullpath")); % get root folder of current file
    scriptsDir = fullfile(projectRoot, 'scripts'); % create full path to scripts
    addpath(scriptsDir);


    file_types = [
        "_1_mreg_fa25_abdominal_", ...
        "_1_mreg_fa25_abdominal_oikea_", ...
        "_1_mreg_fa25_controlled_", ...
        "_1_mreg_fa25_ec_", ...
        "_1_mreg_fa25_slow_", ...
        "_1_mreg_fa25_uijay_"
    ];

    if isfile(input_path)
        disp("single file given, processing...")

        nibp_table = processing_pipeline(input_path, interval);

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

                    processing_pipeline(fullfile(input_path, filename), interval);

                    % move on to the next file type at first finding
                    break;
                end
            end
        end

    else
        error("not a valid file");
    end
        

end

function [nibp_table] = processing_pipeline(input_path, interval) 

     % get base folder
    [folder, ~, ~] = fileparts(input_path); 

    % find all files related to the input file
    [files, base_name] = find_related_files(input_path);

    % get the reference data
    bphr_table = get_bphr_table(folder, files(end));

    % concatenate raw data files (reference file is the last one)
    [nibp_table, transition_pts] = concatenate_nibp_data(folder, files(1:end-1));
    
    % resample data to improve filtering
    new_fs = 500;
    nibp_table = resample_nibp_data(nibp_table, new_fs);

    % plot power spectral density before filtering
    plot_power_spectrum(nibp_table); % TODO: apply also STFT for time-frequency plot

    % apply butterworth filter to nipb data
    nibp_table = apply_butterworth_filter(nibp_table);

    % plot power spectral density after filtering
    plot_power_spectrum(nibp_table);

    % apply findpeaks to filtered data
    [peak_times, peak_indices, widths, prominences] = apply_findpeaks(nibp_table, new_fs, interval);

    % apply hilbert envelope for generalization of curve
    envelope = apply_envelope(nibp_table, interval);

    apply_cross_correlation(envelope);


    % plot everything
    plot_nibp_data(nibp_table, ...
                   bphr_table, ...
                   [], ...% transition_pts, - resampled data loses transition points location
                   base_name, ...
                   interval);

end 