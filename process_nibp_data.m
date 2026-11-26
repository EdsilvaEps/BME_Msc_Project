function [output] = process_nibp_data(input_path, interval, random_interval_size)

    arguments
        input_path (1,:) char  % path to a single .lvm file or a folder containing .lvm files
        interval (1,2) double = [0 0] % optional time interval for plotting
        random_interval_size uint32 = 3 % optional size of random interval sample for verification
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

    % process raw data inputs
    if isfile(input_path)
        disp("single file given, processing...")

        output = processing_pipeline(input_path, interval, random_interval_size);
        return;

    end

    if ~isfolder(input_path)
        error("Input path is not a valid file or folder: %s", input_path);
    end

    disp("processing full patient data")

    % load existing results, or creat an empty array
    results_file = "Results.mat"; % TODO: adjust this later for allowing the file to be given

    if isfile(results_file)
        saved = load(results_file, "Patient");

        if ~isfield(saved, "Patient")
            error("Results.mat does not contains the correct variables");
        end

        Patient = saved.Patient;

    else
        % create a new patient file if not results exist
        Patient = struct("name", {}, "mode", {});
    end

    % grab the folder name for processing and plot naming
    [~, folder_name] = fileparts(input_path);

    % building a new record that will be returned after processing
    patient = struct();
    patient.name = folder_name;
    %patient.modes = create_mode_template([]);
    patient.modes = repmat(create_mode_template(),0,1);

    % list all the .lvm files in this folder
    all_folder_files = dir(fullfile(input_path));

    % search the folder for the types of files we have
    for k = 1:numel(file_types)

        for i = 1:numel(all_folder_files)

            % if found one of the extensions we support, process it
            if contains(all_folder_files(i).name, file_types(k))

                fprintf("Found %s files, processing...\n", file_types(k));


                filename = strcat(folder_name, file_types(k), '1.lvm');
                full_path = fullfile(input_path, filename);
                disp(filename);

                if ~isfile(full_path)
                    continue
                end

                % get the type of breathing mode
                mode_name = get_breathing_mode(filename);

                [~, patient] = processing_pipeline(full_path, ...
                                    interval, ...
                                    random_interval_size, ...
                                    patient, ...
                                    mode_name);

                % move on to the next file type at first finding
                break;
            end
        end
    end

    % aggregate patient data into dataset-wise results file
    patient_idx = find(strcmp({Patient.name}, folder_name));

    if numel(patient_idx) > 1
        error('Multiple entries found for patient: %s', folder_name);
    elseif isempty(patient_idx)
        patient_idx = numel(Patient) + 1;
        fprintf('Adding %s\n', folder_name);
    else
        fprintf('Replacing data for %s\n', folder_name);
    end

    Patient(patient_idx).name = patient.name;
    Patient(patient_idx).modes = patient.modes;

    % Preserve any other variables already stored in Results.mat.
    if isfile(results_file)
        save(results_file, "Patient", "-append");
    else
        save(results_file, "Patient");
    end

end

function [output, patient] = processing_pipeline(input_path, interval, random_interval_size, patient, mode_name)

    
     % get base folder
    [folder, ~, ~] = fileparts(input_path); 

    % find all files related to the input file
    [files, base_name] = find_related_files(input_path);

    % create folder for storing the current analysis plots
    folder_name = create_folder(folder);

    % get the reference data
    bphr_table = get_bphr_table(folder, files(end));

    % concatenate raw data files (reference file is the last one)
    [nibp_table, ~] = concatenate_nibp_data(folder, files(1:end-1));
    
    % resample data to improve filtering
    new_fs = 500;
    nibp_table = resample_nibp_data(nibp_table, new_fs);

    % plot power spectral density before filtering
    %plot_power_spectrum(nibp_table); % TODO: apply also STFT for time-frequency plot

    % apply butterworth filter to nipb data
    nibp_table = apply_butterworth_filter(nibp_table);

    % plot power spectral density after filtering
    %plot_power_spectrum(nibp_table);

    % apply findpeaks to filtered data
    %apply_findpeaks(nibp_table, new_fs, interval);

    % apply improved findpeaks algorithm
    peak_data = apply_findpeaks_2(nibp_table, new_fs, interval);

    % apply hilbert envelope for generalization of curve
    %envelope = apply_envelope(nibp_table, interval);
    %apply_cross_correlation(nibp_table, envelope, interval);

    % plot everything
    plot_nibp_data(nibp_table, ...
                   bphr_table, ...
                   [], ...% transition_pts, - resampled data loses transition points location
                   base_name, ...
                   interval, ...
                   folder_name);

    plot_peak_data(nibp_table, ...
                   new_fs, ...
                   random_interval_size, ...
                   base_name, ...
                   folder_name);


    [template, template_data] = template_correlation(nibp_table, ... 
                                                    new_fs, ...
                                                    peak_data, ...
                                                    base_name, ...
                                                    folder_name);

    template_matching(nibp_table, new_fs, base_name, folder_name, template);

    output = peak_data; % output for analysis


    if nargin >= 4 && ~isempty(patient)
            
        if nargin < 5 % Patient struct is provided and we should save patient analysis on aggregated file
            error("Mode name is required when a patient is provided");
        end
            
        % register patient data
        mode = create_mode_template();
        mode.name = mode_name;
        % add the rest of data here
        mode.mean_PTT = peak_data.mean_delay;
        mode.std_PTT = peak_data.std_delay;
        mode.var_PTT = peak_data.var_delay;
        mode.median_PTT = peak_data.median_delay;
        mode.missing_beats = length(peak_data.all_chest_beats) - length(peak_data.chest_beats);
        mode.percent_of_valid_beats = (length(peak_data.chest_beats) / length(peak_data.all_chest_beats)) ...
                                         * 100 ;

        mode.mean_correlation = template_data.correlation_mean;
        mode.std_correlation = template_data.correlation_std;
        mode.median_correlation = template_data.correlation_median;
        mode.correlation_values = template_data.correlation_values;
        

        % TODO: add correlation data
        mode_idx = numel(patient.modes) + 1;
        patient.modes(mode_idx) = mode;

    end



end 