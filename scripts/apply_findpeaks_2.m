function apply_findpeaks_2(nibp_data, fs, interval)

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
    time_axis = nibp_data.Time;
    carotid_signal = nibp_data.Channel_1;
    chest_signal = nibp_data.Channel_2;

    % threshold for detecting peaks
    chest_signal_threshold = 0.04;
    carotid_signal_threshold = 0.02;

    % detect all candidate chest peaks (negative side for dyastolic)
    [pks_chest, locs_chest] = findpeaks(-chest_signal, ...
                                'MinPeakProminence', chest_signal_threshold);

        
    % cluster configuration - 250ms time range
    cluster_width = round(0.25*fs);

    % array for storing the cluster indices
    clusters = [];
    current_cluster = 1;

    clusters{current_cluster} = 1;

    % clustering peaks
    for i = 2:length(locs_chest)

        % if the distance between the current and previous detected
        % peak is smaller than the defined cluster width
        % then the detected peak is part of the current cluster
        % otherwise, it belongs to the next cluster
        if (locs_chest(i) - locs_chest(i-1)) < cluster_width

            clusters{current_cluster}(end+1) = i;

        else 

            current_cluster = current_cluster + 1;
            clusters{current_cluster} = i;
    
        end
    
    end

    disp("detected clusters:")
    clusters


    % selecting the most prominent chest peaks for
    % heartbeat marker
    chest_beats = [];
    for c = 1:length(clusters)

        % array of peaks that constitute a single cluster
        cluster = clusters{c};

        % index of the most prominent peak in the cluster
        [~, max_idx] = max(pks_chest(cluster));

        % store the absolute location of the peak 
        chest_beats(c) = locs_chest(cluster(max_idx));
        fprintf("Chest peak at: %.6f s\n", time_axis(chest_beats(c)));

    end 

    %disp("selected prominent chest peaks")
    %chest_beats

    % determining the range where the equivalent carotid peak
    % might be found
    min_delay = round(0.02*fs);
    max_delay = round(0.06*fs);

    carotid_beats = [];
    delays = [];
    % find equivalent carotid signal peaks
    % and compute delay
    for n = 1:length(chest_beats)

        found_carotid_peaks = false;
        start_idx = chest_beats(n) + min_delay;
        end_idx = chest_beats(n) + max_delay;
        
        % interval exceeds time axis, finish loop
        if(end_idx > length(time_axis)) 
            break
        end

        fprintf("Looking for carotid peaks between %f s and %f s \n", time_axis(start_idx), time_axis(end_idx));

        % adaptive search interval
        while(found_carotid_peaks == false && end_idx < length(time_axis))

            % carotid signal segment to search
            carotid_segment = carotid_signal(start_idx:end_idx);

            [pks_car, locs_car] = findpeaks(-carotid_segment, ...
                                        'MinPeakProminence', carotid_signal_threshold);

            if isempty(locs_car)
                % expand search interval by 10ms
                end_idx = end_idx + round(0.01*fs);
                fprintf("Not found, searching between %f s and %f s \n", time_axis(start_idx), time_axis(end_idx));
            else
                fprintf("found carotid peak at %f\n", time_axis(locs_car(1)));
                found_carotid_peaks = true;
            end

            % carotid peak should not be over 200ms away from chest peak
            if(end_idx - start_idx) > round(0.2*fs)
                i = end_idx - start_idx;
                fprintf("Interval too large: %f s \n", i/fs);
                break
            end

        end
 
        if(found_carotid_peaks == false)
            continue
        end

                                        
        [~, idx] = max(pks_car); % highest peak in the region
        % convert peak to absolute index and compute delay
        absolute_car = start_idx + locs_car(idx) - 1;
        carotid_beats(n) = absolute_car;
        delays(n) = (carotid_beats(n) - chest_beats(n))/fs;

    end

    carotid_beats = carotid_beats(isfinite(carotid_beats) & carotid_beats>0);
    carotid_beats = round(carotid_beats);

    disp("apply_findpeaks__2 info: ");
    %delays
    fprintf('Mean delay: %f s \n', mean(delays));
    fprintf('delay std: %f s \n', std(delays));
    fprintf('delay variance: %f s \n', var(delays));

    figure;
    plot(time_axis, carotid_signal);

    hold on;
    plot(time_axis(carotid_beats), carotid_signal(carotid_beats), 'ro', 'MarkerFaceColor', 'r');

    plot(time_axis, chest_signal);
    plot(time_axis(chest_beats), chest_signal(chest_beats), 'ro', 'MarkerFaceColor', 'r');

    plot(time_axis(locs_chest), chest_signal(locs_chest), 'rx');
    
    hold off;

    title('Detected Peaks-2');
    xlabel('Time (s)');
    ylabel('Amplitude');

end
