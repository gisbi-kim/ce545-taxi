% clear; clc;
% addpath(genpath('../src/'));
addpath(genpath('./utils/'));
addpath(genpath('../data'));

%% parse hitmap data 
DATA_DIR = "/home/gskim/Dropbox/19 Summer-Fall KAIST/4. 수업/CE545/1. 프로젝트/3. main 시간순/20191215 frequency 코딩/data/processed_data";
ANALYSIS_TYPE = "off";

DATES = {};
for date_idx = 1:30
   DATES{end+1} = strcat("2018-04-", num2str(date_idx, '%02.f'));    
end

% NOTE 1: a singel measurement is for every 30 min 
% NOTE 2: if no measurement at a time, we assume it is the same as to the adjacent previous one 
STR_FILENAMES = load("STR_FILENAMES.mat");
STR_FILENAMES = STR_FILENAMES.STR_FILENAMES;

taxi_hitmap_history = {};
taxi_hitmap_history_3d = []; 
taxi_hitmap_history_name = {};
hitmap_bfr = 0;
for date_idx = 1:30
    
    cur_date = DATES{date_idx}; disp(cur_date);    
    cur_date_dir = fullfile(DATA_DIR, cur_date, ANALYSIS_TYPE, "npy");
    hitmaps_path = listdir(cur_date_dir);

    num_hitmaps = length(hitmaps_path);
    idx_hitmap = 1;
    for idx_time = 1:length(STR_FILENAMES)
        % for obeying NOTE 2
        true_measurement_time_name = STR_FILENAMES{idx_time};        
        data_measurement_time_name = hitmaps_path{idx_hitmap};
        
        if(data_measurement_time_name == true_measurement_time_name)
            path = fullfile(cur_date_dir, data_measurement_time_name);
            hitmap = readNPY(path); 
            idx_hitmap = idx_hitmap + 1;
        else
            hitmap = hitmap_bfr;
        end
        
        % save
        if(size(taxi_hitmap_history_3d, 1) == 0)
            taxi_hitmap_history_3d(:, :, 1) = hitmap;
        else
            taxi_hitmap_history_3d(:, :, end+1) = hitmap;
        end
        taxi_hitmap_history{end+1} = hitmap;
        taxi_hitmap_history_name{end+1} = strcat(cur_date, ": ", true_measurement_time_name(1:6), "-", true_measurement_time_name(8:13));

        % renewal
        hitmap_bfr = hitmap;
    end
    
    for idx_hitmap = 1:num_hitmaps


    end 
end

disp("The number of total hitmaps:");
disp(length(taxi_hitmap_history)); % should be same as 48 (/day) * 30 (day) = 1440

% debug viz 
viz = 0;
if(viz)
for idx_hitmap = 1:length(taxi_hitmap_history)
    figure(1); clf;

    h = imagesc(taxi_hitmap_history{idx_hitmap});
    title(taxi_hitmap_history_name{idx_hitmap});
    caxis([0, 50]);
    colorbar;
    colormap bone;
    axis equal;
    
    pause(0.2);
    
end
end

%% get pixel history for each pixel (== 1D signal) 
hitmap_size_y = size(hitmap, 1);
hitmap_size_x = size(hitmap, 2);
num_hitmap = size(taxi_hitmap_history_3d, 3);

% change here!
% target_pixel_loc = [60, 59]; % (row = y, col = x)
% target_pixel_loc = [53, 38]; % (row = y, col = x)
target_pixel_loc = [78, 40]; % (row = y, col = x)

target_loc_history ... % where, location == pixel
    = squeeze(taxi_hitmap_history_3d(target_pixel_loc(1), target_pixel_loc(2), :));
disp(size(target_loc_history)); 

viz_signal = 1;
if(viz_signal)
   figure(2); clf;
   plot(target_loc_history);
end


%% fft
sampling_freq = 2; % unit: hour, and 2 measurements (i.e., every 30 min) per hour

fft_target_loc_history = fft(target_loc_history);
sig_len = length(target_loc_history);

phase = atan2(imag(fft_target_loc_history), real(fft_target_loc_history)); % *180/pi; %phase information
amplitude = abs(fft_target_loc_history/sig_len);
amplitude = amplitude(1:sig_len/2 + 1);
amplitude(2:end-1) = 2 * amplitude(2:end-1); % take even members 

freq_domain = sampling_freq*(0:(sig_len/2))/sig_len;

viz_freq = 1;
if(viz_freq)
    figure(3); clf;
    plot(freq_domain, amplitude);
%     ylim([0, 10]);
    title('Single-Sided Amplitude Spectrum of X(t)')
    xlabel('f (1/hour)')
    ylabel('|P1(f)|')
end


%% signal reconstruction (prediction)
num_freqs_to_use = 20;
[max_amp, argmax_freq] = maxk(amplitude, num_freqs_to_use);

num_datapoints_to_pred = size(target_loc_history, 1);

TOTLA_PRED_HOURS = 720;
target_pred_days = linspace(0, TOTLA_PRED_HOURS, num_datapoints_to_pred);

target_loc_pred = zeros(1, length(target_pred_days));
for ii_pred = 1:length(target_pred_days)
    x_pred = target_pred_days(ii_pred);

    pred = 0;
    for idx_freq = 1:num_freqs_to_use
        a = max_amp(idx_freq);
        f = freq_domain(argmax_freq(idx_freq));
        phi = phase(argmax_freq(idx_freq));
        pred = pred + a * cos(2*pi*f*x_pred + phi); % NOTE: using cos, not sin (ref: http://bit.ly/2MdJxHF)
    end

    target_loc_pred(ii_pred) = pred;
end

viz_recon = 1;
if(viz_recon)
    figure(4); clf;
    plot(target_loc_pred);
end



