% function that creates a folder for this patient's plots
function folder_name = create_folder(parent_folder_name)

    %fprintf("Creating folder for analysis plots in : %s\n", parent_folder_name);

    folder_name = string(strcat(parent_folder_name, '_analysis'));

    fprintf("Creating folder for analysis plots in : %s\n", folder_name);

    if ~exist(folder_name, 'dir')
        mkdir(folder_name);
    end

    % refresh results file if exists
    results_file = string(strcat(folder_name, 'results.txt'));
    if exist(results_file, 'file')
        delete(results_file);
    end

    if ispc
        folder_name = string(strcat(folder_name, '\')); % backslash for windows systems
    else
        folder_name = string(strcat(folder_name, '/'));
    end

end