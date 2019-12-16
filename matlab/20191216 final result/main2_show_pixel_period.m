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
        taxi_hitmap_history_3d(:, :, end+1) = hitmap;
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
target_pixel_loc = [82, 55]; % (row = y, col = 5x)

target_pixel_on_history ...
    = squeeze(taxi_hitmap_history_3d(target_pixel_loc(1), target_pixel_loc(2), :));
disp(size(target_pixel_on_history));

viz_signal = 1;
if(viz_signal)
   figure(2); clf;
   plot(target_pixel_on_history);
end




