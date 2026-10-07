% applying a 4th-order bandpass Butterworth filter with a lower cutoff of 0.5 and higher cutoff of 10hz and 3dB attenuation 
% done so as in Shing-Hong Liu et al. "Using machine learning models for cuffless blood pressure estimation with ballistocardiogram and impedance plethysmogram"


function [filtered_signal] = apply_butterworth_filter(signal)
    
    % signal is a table with channel 1 and 2
    signal_ch_1 = signal.Channel_1;
    signal_ch_2 = signal.Channel_2;
    time = signal.Time; 

    % estimating the sampling frequency from time array
    dts = diff(time);
    dt = mean(dts);
    fs = 1/dt;

    % Design a 4th-order bandpass Butterworth filter
    low_cutoff = 10; % Lower cutoff frequency in Hz
    high_cutoff = 30; % Higher cutoff frequency in Hz
    order = 4; % Filter order

    % Normalize the cutoff frequencies by the Nyquist frequency
    nyquist_freq = fs / 2;
    low = low_cutoff / nyquist_freq;
    high = high_cutoff / nyquist_freq;

    % Design the Butterworth filter
    [sos, g] = butter(order, [low, high], 'bandpass');

    % Apply the filter to both channels
    filtered_signal_1 = filtfilt(sos, g, signal_ch_1);
    filtered_signal_2 = filtfilt(sos, g, signal_ch_2);

    % create a new table of filtered signals
    filtered_signal = table();
    filtered_signal.Channel_1 = filtered_signal_1;
    filtered_signal.Channel_2 = filtered_signal_2;
    filtered_signal.Time = time;

end