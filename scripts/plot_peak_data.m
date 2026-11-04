function plot_peak_data(nibp_data, fs, random_interval_size)

    arguments
        nibp_data
        fs
        random_interval_size uint32 = 3
    end

    % unpacking nibp data
    time = nibp_data.Time;
    carotid_signal = nibp_data.Channel_1;
    chest_signal = nibp_data.Channel_2;

    % applying our findpeaks algorithm
    peak_data = apply_findpeaks_2(nibp_data, fs);

    % unpacking peak_data
    chest_beats = peak_data.chest_beats;
    carotid_beats = peak_data.carotid_beats;
    delays = peak_data.delays;
    mean_delay = peak_data.mean_delay;
    std_delay = peak_data.std_delay;
    var_delay = peak_data.var_delay;
    median_delay = peak_data.median_delay;

    if random_interval_size == 0
        random_interval_size = 3;
    end

    % creating a random interval the size of random_interval_size to visualize the peaks
    max_start = max(time) - random_interval_size; % ensure the random interval is within the bounds of the data
    if max_start < 1
        error("random_interval_size is too large for the data length");
    end

    start_time = randi([1, max_start]);
    end_time = start_time + random_interval_size - 1;

    % filter peaks to be within the random interval
    %interval_chest_beats = chest_beats(chest_beats >= start_idx & chest_beats <= end_idx);
    %interval_carotid_beats = carotid_beats(carotid_beats >= start_idx & carotid_beats <= end_idx);

    % create a new time axis for the random interval
    interval_time_mask = time >= start_time & time <= end_time;
    carotid_peak_mask = time(carotid_beats) >= start_time & time(carotid_beats) <= end_time;
    chest_peak_mask = time(chest_beats) >= start_time & time(chest_beats) <= end_time;

    % plot whole signal with peaks then plot the random interval with peaks
    figure;
    tiledlayout(2,1);

    nexttile;
    plot(time, carotid_signal, 'b', 'LineWidth', 1.5);
    hold on;
    plot(time, chest_signal, 'r', 'LineWidth', 1.5);
    plot(time(carotid_beats), carotid_signal(carotid_beats), 'ro', 'MarkerFaceColor', 'r');
    plot(time(chest_beats), chest_signal(chest_beats), 'ro', 'MarkerFaceColor', 'r');
    hold off;
    title('Whole Signal with Detected Peaks');
    xlabel('Time (s)');
    ylabel('Signal Amplitude');

    nexttile;
    % plot the random interval with detected peaks
    plot(time(interval_time_mask), carotid_signal(interval_time_mask), 'b', 'LineWidth', 1.5);
    hold on;
    plot(time(interval_time_mask), chest_signal(interval_time_mask), 'r', 'LineWidth', 1.5);
    plot(time(carotid_beats(carotid_peak_mask)), carotid_signal(carotid_beats(carotid_peak_mask)), ...
         'ro', 'MarkerFaceColor', 'r');
    plot(time(chest_beats(chest_peak_mask)), chest_signal(chest_beats(chest_peak_mask)), ...
         'ro', 'MarkerFaceColor', 'r');
    
    hold off;
    
    title(sprintf('Random Interval [%d:%d] seconds with Detected Peaks', start_time, end_time));
    xlabel('Time (s)');
    ylabel('Signal Amplitude');

    % quality analysis (TODO: move it to another function)
    percent_of_valid_beats = (length(chest_beats) / length(peak_data.all_chest_beats)) ...
                                * 100 ;

    fprintf('Mean delay: %f s \n', mean_delay);
    fprintf('Median delay: %f s \n', median_delay);
    fprintf('delay std: %f s \n', std_delay);
    fprintf('delay variance: %f s \n', var_delay);
    fprintf('proportion of valid identified beats: %.2f%% \n', percent_of_valid_beats);

    figure

    tiledlayout(2,1);

    nexttile;
    histogram(peak_data.delays);
    title("Distribution of delay across signal");
    xlabel("delay in secs");
    ylabel("Number of beats");


end