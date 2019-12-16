clear sim_frames;

addpath(genpath('./utils/'));
addpath(genpath('../data'));

%% load parsed all hitmap data (x, y, t) 
% details are in parse hitmap data or main3_fft_pred_seperated_figs

% select the EVENT (ON / OFF) type 
EVENT_TYPES = {"on", "off"};
for idx_EVENT_TYPE = 1:length(EVENT_TYPES)
    
    EVENT_TYPE = EVENT_TYPES{idx_EVENT_TYPE};
    taxi_hitmap_history_3d_filename = strcat("taxi_hitmap_", EVENT_TYPE, "_history_3d.mat");
    taxi_hitmap_history_3d = load(taxi_hitmap_history_3d_filename);

    taxi_hitmap_history_3d = taxi_hitmap_history_3d.taxi_hitmap_history_3d;

    % init 
    taxi_hitmap_history_3d_pred = taxi_hitmap_history_3d;
    
    %% get pixel history for each pixel (== 1D signal) 
    % don't change this 
    sampling_freq = 2; % unit: hour, and 2 measurements (i.e., every 30 min) per hour

    hitmap_size_y = size(taxi_hitmap_history_3d, 1);
    hitmap_size_x = size(taxi_hitmap_history_3d, 2);

    num_hitmap = size(taxi_hitmap_history_3d, 3);

    for idx_loc_y = 1:hitmap_size_y
        for idx_loc_x = 1:hitmap_size_x

            target_pixel_loc = [idx_loc_y, idx_loc_x]; % (row = y, col = x)

            %% Main 
            % 2 week is okay 
            TRAIN_DAY = 14;

            % where, location == pixel
            target_loc_history = squeeze(taxi_hitmap_history_3d(target_pixel_loc(1), target_pixel_loc(2), :));

            % remove the april 1 (sunday) and starts from monday 
            num_remove_front_days = 0; % 1 means only remove the first sunday because april 2018 starts at sunday
            target_loc_history = target_loc_history(48*num_remove_front_days + 1: end); % 48 measurements per day 
            num_original_datapoints = length(target_loc_history);

            target_loc_history_to_train = target_loc_history(1 : sampling_freq*24*TRAIN_DAY);
            num_train_datapoints = length(target_loc_history_to_train);

            
            %% fft
            fft_target_loc_history = fft(target_loc_history_to_train);
            sig_len = length(target_loc_history_to_train);

            phase = atan2(imag(fft_target_loc_history), real(fft_target_loc_history)); % *180/pi; %phase information
            amplitude = abs(fft_target_loc_history/sig_len);
            amplitude = amplitude(1:floor(sig_len/2) + 1);
            amplitude(2:end-1) = 2 * amplitude(2:end-1); % take even members 

            freq_domain = sampling_freq*(0:(sig_len/2))/sig_len;


            %% signal reconstruction (prediction)
            TOTAL_PRED_HOURS = 720; % i.e,. 30 days == the duration of the original whole data 
            num_datapoints_to_pred = size(target_loc_history, 1);
            target_pred_days = linspace(0, TOTAL_PRED_HOURS, num_datapoints_to_pred);

            % using top 10% freqs is okay 
            Topk = round((num_train_datapoints/2) * 0.1);
            target_loc_pred = ... % last arg: num_freqs_to_use
                reconstructSignalUsingFreqs(target_pred_days, amplitude, freq_domain, phase, Topk); 

            % save to the 3d 
            taxi_hitmap_history_3d_pred(idx_loc_y, idx_loc_x, :) = target_loc_pred;

        end
        
        disp(idx_loc_y);
    end

    
    %% save predicted hitmaps 
    DAY_NAMES = {"sun", "mon", "tue", "wed", "thu", "fri", "sat"};
    DAY_NAMES_pointer = 1;
    
    STR_FILENAMES = load("taxi_hitmap_history_name.mat");
    STR_FILENAMES = STR_FILENAMES.taxi_hitmap_history_name;
    
    clear sim_frames;
    figsave_frame_idx = 1;
    
    figure(5); clf;
    set(gcf, "Position", [10 10 2200 470]); % [10 10 2200 470] is good 
    colormap parula;
    cmax = 30;
    
    for idx_frame = 1:size(taxi_hitmap_history_3d_pred, 3)
        true_hitmap = squeeze(taxi_hitmap_history_3d(:, :, idx_frame));
        pred_hitmap = squeeze(taxi_hitmap_history_3d_pred(:, :, idx_frame));
        diff_hitmap = abs(true_hitmap - pred_hitmap);

        str_filename = char(STR_FILENAMES{idx_frame});
        str_filename_date = str2double(str_filename(9:10));
        day_name = DAY_NAMES{mod(str_filename_date, 7)};
        
        % true 
        subplot(1, 3, 1)
        imagesc(true_hitmap);
        title_str = strcat("[True] ", day_name, " - ", str_filename);
        title(title_str);
        caxis([0, cmax]);
        colorbar;
        axis equal;
        
        % pred
        subplot(1, 3, 2)
        imagesc(pred_hitmap);
        title_str = strcat("[Pred] ", day_name, " - ", str_filename);
        title(title_str);
        caxis([0, cmax]);
        colorbar;
        axis equal;
        
        % diff
        subplot(1, 3, 3)
        imagesc(diff_hitmap);
        title_str = strcat("[Diff (L1)] ", day_name, " - ", str_filename);
        title(title_str);
        caxis([0, cmax]);
        colorbar;
        axis equal;
        
        pause(0.05);

        % save 
        sim_frames(figsave_frame_idx) = getframe(gcf);
        figsave_frame_idx = figsave_frame_idx + 1;

    end
    



    %% saver 
    video_name = strcat("./fft_pred_movie_", EVENT_TYPE, "_using_", num2str(TRAIN_DAY), "_days_", ...
                        num2str(Topk), '_freqs.avi');
    writerObj = VideoWriter(char(video_name));
    writerObj.FrameRate = 4;
    open(writerObj);
    for i=1:length(sim_frames)
        frame = sim_frames(i) ;    
        writeVideo(writerObj, frame);
    end
    close(writerObj);


end