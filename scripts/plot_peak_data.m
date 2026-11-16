function plot_peak_data(nibp_data, fs, random_interval_size, plot_name, dest)

    arguments
        nibp_data
        fs
        random_interval_size uint32 = 3
        plot_name = ''
        dest = '' % location where plots are saved to
    end

    % unpacking nibp data
    time = nibp_data.Time;
    carotid_signal = nibp_data.Channel_1;
    chest_signal = nibp_data.Channel_2;

    % applying our findpeaks algorithm
    peak_data = apply_findpeaks_2(nibp_data, fs);

    % unpacking peak_data
    all_chest_beats = peak_data.all_chest_beats; % all chest beats
    chest_beats = peak_data.chest_beats; % valid chest beats
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


     if ~isempty(plot_name)
        sgt = sgtitle(plot_name, 'Interpreter', 'none');
        sgt.FontSize = 20;
        % exportgraphics(gcf, strcat(dest, plot_name,'.png'));
        exportgraphics(gcf, [dest plot_name '_peak_data.png']);
    end
    


    % quality analysis (TODO: move it to another function)
    percent_of_valid_beats = (length(chest_beats) / length(peak_data.all_chest_beats)) ...
                                * 100 ;

    fprintf('Mean delay: %f s \n', mean_delay);
    fprintf('Median delay: %f s \n', median_delay);
    fprintf('delay std: %f s \n', std_delay);
    fprintf('delay variance: %f s \n', var_delay);
    fprintf('proportion of valid identified beats: %.2f%% \n', percent_of_valid_beats);

    % write to file
    fid = fopen([dest 'results.txt'], "w");
    fprintf(fid, 'Mean delay: %f s \n', mean_delay);
    fprintf(fid, 'Median delay: %f s \n', median_delay);
    fprintf(fid, 'delay std: %f s \n', std_delay);
    fprintf(fid, 'delay variance: %f s \n', var_delay);
    fprintf(fid, 'proportion of valid identified beats: %.2f%% \n', percent_of_valid_beats);
    fclose(fid);

    figure;
    histogram(peak_data.delays);
    title("Distribution of delay across signal");
    xlabel("delay in secs");
    ylabel("Number of beats");

    if ~isempty(plot_name)
        sgt = sgtitle(plot_name, 'Interpreter', 'none');
        sgt.FontSize = 20;
        % exportgraphics(gcf, strcat(dest, plot_name,'.png'));
        exportgraphics(gcf, [dest plot_name '_peak_data_histogram.png']);
    end


    % plotting invalid chest signals for debugging
    invalid_chest_beats = setdiff(all_chest_beats, chest_beats);
    invalid_beats_to_plot = length(invalid_chest_beats);
    
    if invalid_beats_to_plot > 0 
        figure;

        for k = 1:min(6, invalid_beats_to_plot)
            
            beat_idx = invalid_chest_beats(k);

            plotting_window = round(0.5*fs); % 500ms on each side

            % setting plotting boundaries
            left_limit = max(1, beat_idx-plotting_window);
            right_limit = min(length(chest_signal), beat_idx + plotting_window);

            subplot(3,2,k)

            plot(time(left_limit:right_limit), chest_signal(left_limit:right_limit), 'r', 'LineWidth', 1.5);
            hold on;
            plot(time(left_limit:right_limit), carotid_signal(left_limit:right_limit), 'b', 'LineWidth', 1.5);
            plot(time(beat_idx), chest_signal(beat_idx), 'ro', 'MarkerFaceColor', 'r');
            hold off;

            title(sprintf('Invalid Chest Beat %d', k));
            xlabel('Time (s)');
            ylabel('Signal Amplitude');
        
        end

    end

    if ~isempty(plot_name)
        sgt = sgtitle(plot_name, 'Interpreter', 'none');
        sgt.FontSize = 20;
        % exportgraphics(gcf, strcat(dest, plot_name,'.png'));
        exportgraphics(gcf, [dest plot_name '_invalid_peaks.png']);
    end





end