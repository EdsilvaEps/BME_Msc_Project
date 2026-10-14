% apply findpeaks algorithm to filtered data and return peakIndices, widths and prominences

function apply_findpeaks(nibp_data, fs, interval)

    arguments
        nibp_data
        fs
        interval (1,2) double = [0 0]
    end

    % separating variables for plotting
    % if interval is provided, filter the data accordingly
    if interval(2) ~= 0
        nibp_data = nibp_data(nibp_data.Time >= interval(1) & nibp_data.Time <= interval(2), :);
    end

    % unpack signals
    time = nibp_data.Time;
    channel_1 = nibp_data.Channel_1;
    channel_2 = nibp_data.Channel_2;

    window_length = fs; % divide the signal into 1s windows for processing
    th_channel_1 = 0.02; % threshold of acceptable peak amplitude
    th_channel_2 = 0.02;

    % setting boundaries for delay so we miscalculate some peak
    min_delay = round(0.01*fs);
    max_delay = round(0.06*fs);

    delays = []; % delays between peaks
    locs_che = [];
    locs_car = [];

    if length(channel_1) > fs

        N = length(channel_1);

        for k = 1:window_length:N

            % process windows of 1s size or smaller size if leftover at the end
            idx_end = min(k + window_length - 1, N);
            idx = k:idx_end;

            seg_car = -channel_1(idx);
            seg_che = -channel_2(idx);

            [pks1, locs1] = findpeaks(seg_car, ...
                                'MinPeakHeight', th_channel_1);

            [pks2, locs2] = findpeaks(seg_che, ...
                                'MinPeakHeight', th_channel_2);

            if ~isempty(locs1) && ~isempty(locs2)
                % first peak above threshold
                peak_car = locs1(1);
                peak_che = locs2(1);

                % convert window-relative location to signal-relative location
                absolute_car = k + peak_car - 1;
                absolute_che = k + peak_che - 1;

                delays(end+1) = (absolute_che - absolute_car)/fs;
                locs_car(end+1) = absolute_car;
                locs_che(end+1) = absolute_che;

            end
        end
    else 
        disp("apply_findpeaks: interval too small for analysis");
    end

    disp("apply_findpeaks info: ");
    delays
    fprintf('Mean delay: %f s \n', mean(delays));
    fprintf('delay std: %f s \n', std(delays));
    fprintf('delay variance: %f s \n', var(delays));


    peak_times_che = time(locs_che);
    peak_times_car = time(locs_car);

    % plot the results for channel 1 (move this to plot function later)
    figure;
    plot(time, channel_1);

    hold on;
    plot(peak_times_car, channel_1(locs_car), 'ro', 'MarkerFaceColor', 'r');
    plot(time, channel_2);
    plot(peak_times_che, channel_2(locs_che), 'ro', 'MarkerFaceColor', 'r');

    hold off;

    title('Detected Peaks');
    xlabel('Time (s)');
    ylabel('Amplitude');


end