% function for verifying the frequency distribution of signal intensity

function plot_power_spectrum(signal)
    
    % signal is a table with channel 1 and 2
    signal_ch_1 = signal.Channel_1;
    signal_ch_2 = signal.Channel_2;
    time = signal.Time; 

    % estimating the sampling frequency from time array
    dts = diff(time);
    dt = mean(dts);
    fs = 1/dt;

    % get Power Spectral Density using Welch's Method
    [pxx_1, f_1] = pwelch(signal_ch_1, [], [], [], fs);
    [pxx_2, f_2] = pwelch(signal_ch_2, [], [], [], fs);

    [~, idx_1] = max(pxx_1);
    dominantFreq = f_1(idx_1);
    fprintf('Channel 1: Dominant frequency = %.2f Hz\n', dominantFreq)

    figure;
    tiledlayout(2,1);

    nexttile;
    plot(f_1, 10*log10(pxx_1));
    xlabel('Frequency (Hz)')
    ylabel('PSD (dB/Hz)')
    title('Power Spectral Density - Channel 1')

    nexttile;    
    plot(f_2, 10*log10(pxx_2));
    xlabel('Frequency (Hz)')
    ylabel('PSD (dB/Hz)')
    title('Power Spectral Density - Channel 2')

    sgtitle("Power Spectral Density Plot");


end
