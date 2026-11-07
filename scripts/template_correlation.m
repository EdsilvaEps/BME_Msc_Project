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


    % isolate chest beats
    beats = [];
    for n = 1:length(chest_beats)
        idx_start = chest_beats(n) - pre_t_sampled;
        idx_end = chest_beats(n) + post_t_sampled;

        % prevent boundary errors
        if idx_start < 1 || idx_end > length(chest_signal)
            continue;
        end

        beat = chest_signal(idx_start:idx_end);
        beats = [beats; beat(:)'];

    end

    % size(beats)

    % create template using number_of_beats_per_template (mean of beats)
    template = mean(beats(1:number_of_beats_per_template, :), 1);
    % alternative:median, it is more robust to outliers
    % template = median(beats, 1);

    % plotting all extracted beats
    figure;

    t = (-pre_t_sampled:post_t_sampled) / fs ;
    plot(t, beats', "Color", [0.4 0.7 1], "LineWidth", 1.5);
    hold on;
    plot(t, template, "Color", "black", "LineWidth", 2.5, "LineStyle", "--");

    xlabel("Time (s)");
    ylabel("Amplitude (A.U)");
    title("Aligned beats");

    legend("Extracted beats", "Template (red line)");
    title("Ensemble-averaged template of chest beats");

    % normalizing every beat individually, subtracting mean and dividing by std
    % mean becomes 0 and std becomes 1
    normalized_chest_beats = zeros(size(beats));
    for k = 1:size(beats,1)

        mu = mean(beats(k, :));
        sigma = std(beats(k,:));

        normalized_chest_beats(k,:) = (beats(k,:) - mu) / sigma;

    end

    % normalize template
    normalized_template = ...
        (template - mean(template)) / std(template);
    % if using median:
    % template = median(chest_beats, 1);

    % verification:
    fprintf('Mean of beats after normalization %f\nStd of beats after normalization %f\n', ...
                 mean(mean(normalized_chest_beats,2)), mean(std(normalized_chest_beats, 0, 2)));

    % computing beat-template pearson correlation
    correlation_values = zeros(size(normalized_chest_beats,1),1);
    
    for k = 1:size(normalized_chest_beats,1)
        
        R = corrcoef(normalized_chest_beats(k,:), normalized_template);

        correlation_values(k) = R(1,2);
    end

    % plot histogram of correlation values
    figure;
    histogram(correlation_values, 20);
    xlabel('Pearson correlation coefficient');
    ylabel('Count');
    title('Histogram of beat-template correlation values');

    % plotting a number of the most correlated beats with the template
    [sorted_corr, sorted_idx] = sort(correlation_values, 'descend');

    figure;
    num_beats_to_plot = 5;

    for k = 1:num_beats_to_plot
        subplot(num_beats_to_plot, 1, k);
        plot(t, normalized_chest_beats(sorted_idx(k),:), 'Color', [0.4 0.7 1], 'LineWidth', 1.5);
        hold on;
        plot(t, normalized_template, 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', '--');
        hold off;
        xlabel('Time (s)');
        ylabel('Normalized Amplitude');
        title(sprintf('Beat %d (Correlation: %.2f)', sorted_idx(k), sorted_corr(k)));
    end
    sgtitle("High correlation beats")

    % plotting a number of the least correlated beats with the template
    [sorted_corr, sorted_idx] = sort(correlation_values, "ascend");

    figure;

    for k = 1:num_beats_to_plot
        subplot(num_beats_to_plot, 1, k);
        plot(t, normalized_chest_beats(sorted_idx(k),:), 'Color', [0.4 0.7 1], 'LineWidth', 1.5);
        hold on;
        plot(t, normalized_template, 'Color', 'black', 'LineWidth', 1.5, 'LineStyle', '--');
        hold off;
        xlabel('Time (s)');
        ylabel('Normalized Amplitude');
        title(sprintf('Beat %d (Correlation: %.2f)', sorted_idx(k), sorted_corr(k)));
    end
    sgtitle("Low correlation beats")



end