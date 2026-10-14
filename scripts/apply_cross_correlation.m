
function apply_cross_correlation(nibp_table, envelope, interval)

    arguments
        nibp_table
        envelope
        interval (1,2) double = [0 0] % optional time interval for plotting;
    end

    % separating variables for plotting
    % if interval is provided, filter the data accordingly
    if interval(2) ~= 0
        nibp_table = nibp_table(nibp_table.Time >= interval(1) & nibp_table.Time <= interval(2), :);
    end

    original_ch_1 = nibp_table.Channel_1;
    original_ch_2 = nibp_table.Channel_2;

    % signal is a table with channel 1 and 2
    signal_ch_1 = envelope.Channel_1;
    signal_ch_2 = envelope.Channel_2;
    time = envelope.Time; 

    % calculate cross-correlation between the two channels
    %[cross_corr, lags] = xcorr(signal_ch_1, signal_ch_2, 'coeff');
    [cross_corr, lags] = xcorr(original_ch_1, original_ch_2, 'coeff');

    % plot the cross-correlation
    figure;
    plot(lags, cross_corr);
    title('Cross-Correlation between Channel 2 and Channel 1');
    xlabel('Lag');
    ylabel('Cross-Correlation Coefficient');
    grid on;

    % confirm the result with finddelay function
    delay = finddelay(signal_ch_1, signal_ch_2);
    % considering the signal is sampled at 500Hz, convert the delay from samples to seconds
    delay_in_seconds = (delay / 500) * 10e3;
    fprintf('finddelay: The delay between Channel 1 and Channel 2 is: %d samples or %d miliseconds\n', ...
             delay, delay_in_seconds);

    % plot the signals with the calculated delay
    signal_ch_1_shifted = circshift(signal_ch_1, delay);
    original_ch_1_shifted = circshift(original_ch_1, delay);
    n = min(numel(time), numel(original_ch_1_shifted));

    figure;
    plot(time, signal_ch_1_shifted, 'y', 'DisplayName', 'Channel 1 (Shifted)');
    hold on;
    plot(time, signal_ch_2, 'g', 'DisplayName', 'Channel 2');
    plot(time(1:n), original_ch_1_shifted(1:n), 'b');
    plot(time(1:n), original_ch_2(1:n), 'r');

    hold off;
    legend('Envelope 1 Shifted', 'Envelope 2', 'Channel 1 Shifted', 'Channel 2');
    title('Superimposed Shifted Signals');
    xlabel('Time');
    ylabel('Amplitude');



end