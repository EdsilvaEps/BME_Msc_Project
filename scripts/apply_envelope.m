
function [envelope] = apply_envelope(signal, interval)

    arguments
        signal
        interval (1,2) double = [0 0]
    end

    % separating variables for plotting
    % if interval is provided, filter the data accordingly
    if interval(2) ~= 0
        signal = signal(signal.Time >= interval(1) & signal.Time <= interval(2), :);
    end

    % signal is a table with channel 1 and 2
    signal_ch_1 = signal.Channel_1;
    signal_ch_2 = signal.Channel_2;
    time = signal.Time; 

    % taking only the lower side of the envelope
    env_1 = -abs(hilbert(signal_ch_1));
    env_2 = -abs(hilbert(signal_ch_2));

    envelope = table();
    envelope.Channel_1 = env_1;
    envelope.Channel_2 = env_2;
    envelope.Time = time;


    % comparing different approaches:
    % 1st - calculate the gradients in the envelop as the points of most inflection, then use these points to find the peaks in the original signal
    d1 = gradient(env_1)
    d2 = gradient(env_2)

    [~, idx1] = max(-d1);
    [~, idx2] = max(-d2);

    % 2nd - find the peaks in the envelope and use these points to find the peaks in the original signal
    [~, peak_indices_1] = findpeaks(-env_1);
    [~, peak_indices_2] = findpeaks(-env_2);

    % plot the envelope of both channels over the signals
    figure;

    tiledlayout(2,1);

    nexttile;
    plot(time, signal_ch_1, 'b', 'DisplayName', 'Signal');
    hold on;
    plot(time, env_1, 'r', 'DisplayName', 'Envelope');

    % plot the points of maximum inflection in the envelope
    plot(time(idx1), env_1(idx1), 'ko', 'MarkerFaceColor', 'k', 'DisplayName', 'Max Inflection Point');
    % annotate y-axis value of the point
    text(time(idx1), env_1(idx1), sprintf('(%0.2f, %0.2f)', time(idx1), env_1(idx1)), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

    %plot the peaks in the envelope
    plot(time(peak_indices_1), env_1(peak_indices_1), 'go', 'MarkerFaceColor', 'g', 'DisplayName', 'Envelope Peaks');
    % annotate y-axis value of the point
    text(time(peak_indices_1), env_1(peak_indices_1), arrayfun(@(x,y) sprintf('(%0.2f, %0.2f)', x, y), time(peak_indices_1), env_1(peak_indices_1), 'UniformOutput', false), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

    hold off;
    title('Carotid Artery - Signal and Envelope');
    xlabel('Time (s)');

    ylabel('Amplitude');
    legend('show');

    nexttile;
    plot(time, signal_ch_2, 'b', 'DisplayName', 'Signal');
    hold on;
    plot(time, env_2, 'r', 'DisplayName', 'Envelope');

    % plot the points of maximum inflection in the envelope
    plot(time(idx2), env_2(idx2), 'ko', 'MarkerFaceColor', 'k', 'DisplayName', 'Max Inflection Point');
    % annotate y-axis value of the point
    text(time(idx2), env_2(idx2), sprintf('(%0.2f, %0.2f)', time(idx2), env_2(idx2)), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

    %plot the peaks in the envelope
    plot(time(peak_indices_2), env_2(peak_indices_2), 'go', 'MarkerFaceColor', 'g', 'DisplayName', 'Envelope Peaks');
    % annotate y-axis value of the point
    text(time(peak_indices_2), env_2(peak_indices_2), arrayfun(@(x,y) sprintf('(%0.2f, %0.2f)', x, y), time(peak_indices_2), env_2(peak_indices_2), 'UniformOutput', false), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

    hold off;
    hold off;
    title('Chest - Signal and Envelope');
    xlabel('Time (s)');
    ylabel('Amplitude');




end