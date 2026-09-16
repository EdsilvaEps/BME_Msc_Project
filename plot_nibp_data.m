% function that plots both nibp data and bphr reference
function plot_nibp_data(nibp_data, bphr_data ,transition_points, plot_name)
    arguments
        nibp_data
        bphr_data = table()
        transition_points = []
        plot_name = ''
    end


    % separating variables for plotting
    time = nibp_data.Time;
    channel_1 = nibp_data.Channel_1;
    channel_2 = nibp_data.Channel_2;
    %channel_3 = nibp_data.Channel_3_noise;
    %channel_4 = nibp_data.Channel_4_voltage;

    % if bphr_data is provided, separate its variables for plotting
    if ~isempty(bphr_data)
        time_bphr = bphr_data.Time;
        mock_y_axis = zeros(size(time)); % create a mock y-axis for plotting
        channel_1_bphr = bphr_data.Channel_1_HR;
        channel_2_bphr = bphr_data.Channel_2_HR;
    end

    % plotting
    figure;
    
    %layout depends on whether bphr_data is provided
    if ~isempty(bphr_data)
        tiledlayout(2, 2);
    else
        tiledlayout(2, 1);
    end

    nexttile;
    plot(time, channel_1);
    title('Channel 1 - Raw Data');
    xlabel('Time');
    ylabel('Amplitude');

    % if annotation data is provided, annotate transition points
    if ~isempty(transition_points)
        hold on;
        for i = 1:length(transition_points)
            xline(time(transition_points(i)), 'r--', sprintf('End of file %d', i), 'LabelVerticalAlignment', 'bottom');
        end
        hold off;
    end

    nexttile;
    plot(time, channel_2);
    title('Channel 2 - Raw Data');
    xlabel('Time');
    ylabel('Amplitude');

    % if annotation data is provided, annotate transition points
    if ~isempty(transition_points)
        hold on;
        for i = 1:length(transition_points)
            xline(time(transition_points(i)), 'r--', sprintf('End of file %d', i), 'LabelVerticalAlignment', 'bottom');
        end
        hold off;
    end

    % if bphr_data is provided, plot it
    if ~isempty(bphr_data)
        nexttile;
        plot(time, mock_y_axis);
        hold on;
        plot(time_bphr, channel_1_bphr, 'g', 'LineWidth', 1.5);
        hold off;
        title('Channel 1 BPHR Reference');
        xlabel('Time');
        ylabel('Amplitude');

        nexttile;
        plot(time, mock_y_axis);
        hold on;
        plot(time_bphr, channel_2_bphr, 'g', 'LineWidth', 1.5);
        hold off;
        title('Channel 2 BPHR Reference');
        xlabel('Time');
        ylabel('Amplitude');
    end

    if ~isempty(plot_name)
        sgt = sgtitle(plot_name);
    else
        sgt = sgtitle('NIBP Data and BPHR Reference');
    end
    sgt.FontSize = 20;
end