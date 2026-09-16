function process_nibp_data(input_path)

    file_types = [
        "mreg_fa25_abdominal", ...
        "mreg_fa25_abdominal_oikea", ...
        "mreg_fa25_controlled", ...
        "mreg_fa25_ec", ...
        "mreg_fa25_slow", ...
        "mreg_fa25_uijay"
    ];

    if isfile(input_path)
        disp("single file given, processing...")
        files = find_related_files(input_path);

    elseif isfolder(input_path)
        disp("nothing yet, leaving...")

    else
        error("not a valid file");
    end
        

end