% function that creates a folder for this patient's plots
function folder_name = create_folder(parent_folder_name)

    folder_name = [parent_folder_name '_analysis'];

    if ~exist(folder_name, 'dir')
        mkdir(folder_name);
    end

    % refresh results file if exists
    results_file = [folder_name 'results.txt'];
    if exist(results_file, 'file')
        delete(results_file);
    end

    if ispc
        folder_name = [folder_name '\']; % backslash for windows systems
    else
        folder_name = [folder_name '/'];
    end

end