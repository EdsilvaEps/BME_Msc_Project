function template_correlation(nibp_data, fs ,peak_data)

    % unpack signals
    time_axis = nibp_data.Time;
    carotid_signal = nibp_data.Channel_1;
    chest_signal = nibp_data.Channel_2;

    % unpack peak data
    chest_beats = peak_data.chest_beats;
    carotid_beats = peak_data.carotid_beats;
    delays = peak_data.delays;

    % variables for template creation
    pre_time = 0.150; % time before beat in seconds
    post_time = 0.300; % time after beat in seconds
    number_of_beats_per_template = 10;
    pre_t_sampled = round(pre_time*fs); % time before beat within sampled time
    post_t_sampled = round(post_time*fs); % time after beat, sampled
    beat_length = pre_t_sampled + post_t_sampled + 1; % absolute lenght of beat


    % isolate chest beats for template creation
    beats = [];
    for n = 1:number_of_beats_per_template
        idx_start = chest_beats(n) - pre_t_sampled;
        idx_end = chest_beats(n) + post_t_sampled;

        beat = chest_signal(idx_start:idx_end);
        beats = [beats; beat(:)'];

    end

    % size(beats)

    % create template (mean of beats)
    template = mean(beats, 1); 
    % alternative:median, it is more robust to outliers
    % template = median(beats, 1);

    % plotting all extracted beats
    figure;

    t = (-pre_t_sampled:post_t_sampled) / fs ;
    plot(t, beats', "Color", [0.5 0.5 0.5], "LineWidth", 1.5);
    hold on;
    plot(t, template, "Color", "r", "LineWidth", 2.5);

    xlabel("Time (s)");
    ylabel("Amplitude (A.U)");
    title("Aligned beats");

    legend("Extracted beats", "Template (red line)");
    title("Ensemble-averaged template of chest beats");

    % remove beat offset
    % this subtracts the mean from each beat and makes correlation more shape driven
    % instead of amplitude or baseline driven
    beats = beats - mean(beats, 2);



end