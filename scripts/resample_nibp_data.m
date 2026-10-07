% function for resampling the data into a new, lower frequency sampled data

function [resampled_signal] = resample_nibp_data(signal, new_fs)

    % signal is a table with channel 1 and 2
    signal_ch_1 = signal.Channel_1;
    signal_ch_2 = signal.Channel_2;
    time = signal.Time; 

    % estimating the sampling frequency from time array
    dts = diff(time);
    dt = mean(dts);
    fs = 1/dt;

    fprintf("Resampling data from: %d Hz to %d Hz\n", fs, new_fs);

    resampled_signal = table();
    resampled_signal.Channel_1 = resample(signal_ch_1, new_fs, fs);
    resampled_signal.Channel_2 = resample(signal_ch_2, new_fs, fs);

    % creating new time vector
    new_time_vector = linspace(time(1), time(end), length(resampled_signal.Channel_1));
    resampled_signal.Time = new_time_vector(:);



end