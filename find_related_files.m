%  function that allows for aggregation of .lvm files
function [groups, base_name] = find_related_files(input_path)

    if isfile(input_path)
        [folder, name, ext] = fileparts(input_path);
        %disp([folder, name, ext])

        if ~strcmpi(ext, '.lvm')
            error('Input file must be .lvm');
        end

        % remove output suffixes _number or _BPHR
        token = regexp(name, '^(.*)_([A-Za-z]+|\d+)', 'tokens', 'once');

        if isempty(token)
            error('Unrecognized file type');
        end

        base_name = token{1}; % file name without suffixes
        % create a list of files related to the one which was input
        files = dir(fullfile(folder, [base_name '_*.lvm']));
        groups = string({files.name}');
        fprintf("Found %d files associated with %s:\n", length(groups), base_name);
    end