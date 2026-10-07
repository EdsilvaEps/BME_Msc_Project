% apply findpeaks algorithm to filtered data and return peakIndices, widths and prominences

function [peak_times, peak_indices, widths, prominences] = apply_findpeaks(nibp_data, fs, interval)

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

    % calculate amplitude threshold based on median of the signal so that it isnt affected by unusually high peaks
    % abs(s) - median(s) is the absolute deviation, or the typicla distance from signal's center
    % then multiply by 1.4826, to make this estimate comparable to standard deviation when the data follows a normal dist
    amplitude_scale_1 = 1.4826 * median(abs(channel_1) - median(channel_1));
    amplitude_scale_2 = 1.4826 * median(abs(channel_2) - median(channel_2));

    % detect peaks
    max_hr = 180; % max plausible hr (to be adjusted)
    min_distance = ceil(fs * 60 / max_hr);
    min_prominence = 2 * amplitude_scale_1;

    [~, peak_indices, widths, prominences] = findpeaks(...
        -channel_1, ...
        'MinPeakDistance', min_distance, ...
        'MinPeakProminence', min_prominence);

    peak_times = time(peak_indices);

    % plot the results for channel 1 (move this to plot function later)
    figure;
    hold on;

    plot(time, channel_1);
    plot(time, channel_2);
    plot(peak_times, channel_1(peak_indices), 'ro', 'MarkerFaceColor', 'r');
    title('Channel 1 - Detected Peaks');
    xlabel('Time (s)');
    ylabel('Amplitude');


end