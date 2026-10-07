
function apply_cross_correlation(envelope)

    % signal is a table with channel 1 and 2
    signal_ch_1 = envelope.Channel_1;
    signal_ch_2 = envelope.Channel_2;
    time = envelope.Time; 

    % calculate cross-correlation between the two channels
    [cross_corr, lags] = xcorr(signal_ch_1, signal_ch_2, 'coeff');

    % plot the cross-correlation
    figure;
    plot(lags, cross_corr);
    title('Cross-Correlation between Channel 1 and Channel 2');
    xlabel('Lag');
    ylabel('Cross-Correlation Coefficient');
    grid on;

    % confirm the result with finddelay function
    delay = finddelay(signal_ch_1, signal_ch_2);
    % considering the signal is sampled at 500Hz, convert the delay from samples to seconds
    delay_in_seconds = delay / 500;
    fprintf('The delay between Channel 1 and Channel 2 is: %d seconds\n', delay_in_seconds);

end