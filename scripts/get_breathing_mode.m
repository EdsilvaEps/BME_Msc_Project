function mode = get_breathing_mode(filename)

    filename = lower(string(filename));

    if contains(filename, "1_mreg_fa25_abdominal_oikea")
        mode = "abdominal_oikea";

    elseif contains(filename, "1_mreg_fa25_abdominal")
        mode = "abdominal";

    elseif contains(filename, "1_mreg_fa25_controlled")
        mode = "controlled";

    elseif contains(filename, "1_mreg_fa25_ec")
        mode = "EC";

    elseif contains(filename, "1_mreg_fa25_slow")
        mode = "slow";

    elseif contains(filename, "1_mreg_fa25_uijay")
        mode = "uijay";

    else
        error("Unknown breathing mode in filename: %s", filename);
    end
end