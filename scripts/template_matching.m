function template_data = template_matching(nibp_table, fs, base_name, folder_name, template)
    % template_matching - performs template matching on the NIBP data
    %
    % Syntax: template_data = template_matching(nibp_table, fs, peak_data, base_name, folder_name)
    %
    % Inputs:
    %   nibp_table - table containing the NIBP data
    %   fs - sampling frequency of the NIBP data
    %   base_name - base name of the file being processed
    %   folder_name - name of the folder where the results will be saved
    %   template - the template to be used for matching
    %
    % Outputs:
    %   template_data - struct containing the results of the template matching

    % unpacking nibp data
    time = nibp_table.Time;
    carotid_signal = nibp_table.Channel_1;
    chest_signal = nibp_table.Channel_2;

    % clearing a template filter for the template matching
    h = flipud(template(:)); % flip the template for convolution
    mf_output = conv(chest_signal, h, "same");

    % normalize output for visualization
    mf_output = mf_output/max(abs(mf_output));

    random_interval_size = 3;
    % creating a random interval the size of random_interval_size to visualize the peaks
    min_start = ceil(min(time));
    max_start = floor(max(time) - random_interval_size);

    if max_start < min_start
        error("No valid integer start time for this interval");
    end

    start_time = randi([min_start, max_start]);
    end_time = start_time + random_interval_size;
    % create a new time axis for the random interval
    interval_time_mask = time >= start_time & time <= end_time;

    % plotting
    figure;

    subplot(2,1,1)

    % plot the random interval with detected peaks
    %plot(time(interval_time_mask), carotid_signal(interval_time_mask), 'b', 'LineWidth', 1.5);
    %hold on;
    plot(time(interval_time_mask), chest_signal(interval_time_mask), 'r', 'LineWidth', 1.5);
    
    %hold off;

    subplot(2,1,2);
    plot(time(interval_time_mask), mf_output(interval_time_mask), 'r', 'LineWidth', 1.5);

     % plotting
    figure;

    subplot(2,1,1)

    % plot the random interval with detected peaks
    %plot(time(interval_time_mask), carotid_signal(interval_time_mask), 'b', 'LineWidth', 1.5);
    %hold on;
    plot(time, chest_signal, 'r', 'LineWidth', 1.5);
    
    %hold off;

    subplot(2,1,2);
    plot(time, mf_output, 'r', 'LineWidth', 1.5);

end