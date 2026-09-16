function process_nibp_data(input_path)

    % file_types = [ % WILL BE USED WHEN WE START PROCESSING FULL FOLDERS
    %    "mreg_fa25_abdominal", ...
    %    "mreg_fa25_abdominal_oikea", ...
    %    "mreg_fa25_controlled", ...
    %    "mreg_fa25_ec", ...
    %    "mreg_fa25_slow", ...
    %    "mreg_fa25_uijay"
    %];

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
        plot_nibp_data(nibp_table, bphr_table, transition_pts, base_name);    

    elseif isfolder(input_path)
        disp("nothing yet, leaving...")

    else
        error("not a valid file");
    end
        

end