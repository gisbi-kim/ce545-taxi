clear sim_frames;

addpath(genpath('./utils/'));
addpath(genpath('../data'));

%% load parsed all hitmap data (x, y, t) 
% details are in parse hitmap data or main3_fft_pred_seperated_figs
taxi_hitmap_history_3d = load("taxi_hitmap_off_history_3d.mat");
taxi_hitmap_history_3d = taxi_hitmap_history_3d.taxi_hitmap_history_3d;


%% get pixel history for each pixel (== 1D signal) 
sampling_freq = 2; % unit: hour, and 2 measurements (i.e., every 30 min) per hour

hitmap_size_y = size(taxi_hitmap_history_3d, 1);
hitmap_size_x = size(taxi_hitmap_history_3d, 2);
num_hitmap = size(taxi_hitmap_history_3d, 3);

% NOTE: change here!
% target_pixel_loc = [60, 60]; % (row = y, col = x)
target_pixel_loc = [37, 89]; % (row = y, col = x)

% show loc 
figure(9); clf;
any_frame = 30;
imagesc(taxi_hitmap_history_3d(:, :, any_frame)); hold on;
scatter(target_pixel_loc(2), target_pixel_loc(1), 100, 'red', 'filled', "MarkerEdgeColor", 'black', 'LineWidth', 2);
caxis([0, 30]);
saveas(gcf,'results/place.png');

TRAIN_DAYS = [4, 7, 10, 14, 21, 28];

figsave_frame_idx = 1;
for TRAIN_DAY = TRAIN_DAYS

% where, location == pixel
target_loc_history = squeeze(taxi_hitmap_history_3d(target_pixel_loc(1), target_pixel_loc(2), :));

% remove the april 1 (sunday) and starts from monday 
num_remove_front_days = 0; % 1 means only remove the first sunday because april 2018 starts at sunday
target_loc_history = target_loc_history(48*num_remove_front_days + 1: end); % 48 measurements per day 
num_original_datapoints = length(target_loc_history);

% TRAIN_RATIO = 1/(4.2);
target_loc_history_to_train = target_loc_history(1 : sampling_freq*24*TRAIN_DAY);
num_train_datapoints = length(target_loc_history_to_train);

num_subfigures = 7;
idx_cur_cubfigure = 1;

figure(10); clf;
subplot(num_subfigures, 1, idx_cur_cubfigure); idx_cur_cubfigure = idx_cur_cubfigure + 1;
plot(target_loc_history, 'Color', [0.7, 0.7, 0.7]); hold on;
plot(target_loc_history_to_train, 'b');
line([num_train_datapoints, num_train_datapoints], [0, 400], 'Color', 'red', 'LineWidth', 2.5);
for i = 0:4 % monday start line 
    line([sampling_freq*24*((1-num_remove_front_days)+i*7), sampling_freq*24*((1-num_remove_front_days)+i*7)], [0, 400], 'Color', [0.4, 0.4, 0.4], 'LineWidth', 1.0); % monday
end
title("The PARTIAL data of the original event history used (up to the red line while the whole data is 30 days)");
yrange = [0, max(target_loc_history) * 1.2];
xlim([1, num_original_datapoints]);
ylim(yrange);


%% fft
fft_target_loc_history = fft(target_loc_history_to_train);
sig_len = length(target_loc_history_to_train);

phase = atan2(imag(fft_target_loc_history), real(fft_target_loc_history)); % *180/pi; %phase information
amplitude = abs(fft_target_loc_history/sig_len);
amplitude = amplitude(1:floor(sig_len/2) + 1);
amplitude(2:end-1) = 2 * amplitude(2:end-1); % take even members 

freq_domain = sampling_freq*(0:(sig_len/2))/sig_len;

figure(10); 
subplot(num_subfigures, 1, idx_cur_cubfigure); idx_cur_cubfigure = idx_cur_cubfigure + 1;
plot(freq_domain, amplitude, 'black');
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (1/hour)')
ylabel('|P1(f)|')


%% signal reconstruction (prediction)
TOTAL_PRED_HOURS = 720; % i.e,. 30 days == the duration of the original whole data 
num_datapoints_to_pred = size(target_loc_history, 1);
target_pred_days = linspace(0, TOTAL_PRED_HOURS, num_datapoints_to_pred);

Topk = 2;
target_loc_pred = ... % last arg: num_freqs_to_use
    reconstructSignalUsingFreqs(target_pred_days, amplitude, freq_domain, phase, Topk); 
figure(10); 
subplot(num_subfigures, 1, idx_cur_cubfigure); idx_cur_cubfigure = idx_cur_cubfigure + 1;
plot(target_loc_history, 'g'); hold on; 
plot(target_loc_pred, 'b'); 
line([num_train_datapoints, num_train_datapoints], [0, 400], 'Color','red', 'LineWidth', 2.5);
for i = 0:4 % monday start line 
    line([sampling_freq*24*((1-num_remove_front_days)+i*7), sampling_freq*24*((1-num_remove_front_days)+i*7)], [0, 400], 'Color', [0.4, 0.4, 0.4], 'LineWidth', 1.0); % monday
end
title_str = strcat("A reconstructed signal using frequencies top ", num2str(Topk), " (green: true, blue: reconstructed (pred))");
title(title_str);
ylim(yrange);
xlim([1, num_original_datapoints]);

%
Topk = 10;
target_loc_pred = ... % last arg: num_freqs_to_use
    reconstructSignalUsingFreqs(target_pred_days, amplitude, freq_domain, phase, Topk); 
figure(10); 
subplot(num_subfigures, 1, idx_cur_cubfigure); idx_cur_cubfigure = idx_cur_cubfigure + 1;
plot(target_loc_history, 'g'); hold on; 
plot(target_loc_pred, 'b'); 
line([num_train_datapoints, num_train_datapoints], [0, 400], 'Color','red', 'LineWidth', 2.5);
for i = 0:4 % monday start line 
    line([sampling_freq*24*((1-num_remove_front_days)+i*7), sampling_freq*24*((1-num_remove_front_days)+i*7)], [0, 400], 'Color', [0.4, 0.4, 0.4], 'LineWidth', 1.0); % monday
end
title_str = strcat("A reconstructed signal using frequencies top ", num2str(Topk), " (green: true, blue: reconstructed (pred))");
title(title_str);
ylim(yrange);
xlim([1, num_original_datapoints]);

%
Topk = round((num_train_datapoints/2) * 0.3);
target_loc_pred = ... % last arg: num_freqs_to_use
    reconstructSignalUsingFreqs(target_pred_days, amplitude, freq_domain, phase, Topk); 
figure(10); 
subplot(num_subfigures, 1, idx_cur_cubfigure); idx_cur_cubfigure = idx_cur_cubfigure + 1;
plot(target_loc_history, 'g'); hold on;
plot(target_loc_pred, 'b'); 
line([num_train_datapoints, num_train_datapoints], [0, 400], 'Color','red', 'LineWidth', 2.5);
for i = 0:4 % monday start line 
    line([sampling_freq*24*((1-num_remove_front_days)+i*7), sampling_freq*24*((1-num_remove_front_days)+i*7)], [0, 400], 'Color', [0.4, 0.4, 0.4], 'LineWidth', 1.0); % monday
end
title_str = strcat("A reconstructed signal using frequencies top ", num2str(Topk), " (green: true, blue: reconstructed (pred))");
title(title_str);
ylim(yrange);
xlim([1, num_original_datapoints]);

%
Topk = round((num_train_datapoints/2) * 0.5);
target_loc_pred = ... % last arg: num_freqs_to_use
    reconstructSignalUsingFreqs(target_pred_days, amplitude, freq_domain, phase, Topk); 
figure(10); 
subplot(num_subfigures, 1, idx_cur_cubfigure); idx_cur_cubfigure = idx_cur_cubfigure + 1;
plot(target_loc_history, 'g'); hold on;
plot(target_loc_pred, 'b'); 
line([num_train_datapoints, num_train_datapoints], [0, 400], 'Color','red', 'LineWidth', 2.5);
for i = 0:4 % monday start line 
    line([sampling_freq*24*((1-num_remove_front_days)+i*7), sampling_freq*24*((1-num_remove_front_days)+i*7)], [0, 400], 'Color', [0.4, 0.4, 0.4], 'LineWidth', 1.0); % monday
end
title_str = strcat("A reconstructed signal using frequencies top ", num2str(Topk), " (green: true, blue: reconstructed (pred))");
title(title_str);
ylim(yrange);
xlim([1, num_original_datapoints]);

%
Topk = round((num_train_datapoints/2) * 0.95);
target_loc_pred = ... % last arg: num_freqs_to_use
    reconstructSignalUsingFreqs(target_pred_days, amplitude, freq_domain, phase, Topk); 
figure(10); 
subplot(num_subfigures, 1, idx_cur_cubfigure); idx_cur_cubfigure = idx_cur_cubfigure + 1;
plot(target_loc_history, 'g'); hold on; 
plot(target_loc_pred, 'b'); 
line([num_train_datapoints, num_train_datapoints], [0, 400], 'Color','red', 'LineWidth', 2.5);
for i = 0:4 % monday start line 
    line([sampling_freq*24*((1-num_remove_front_days)+i*7), sampling_freq*24*((1-num_remove_front_days)+i*7)], [0, 400], 'Color', [0.4, 0.4, 0.4], 'LineWidth', 1.0); % monday
end
title_str = strcat("A reconstructed signal using frequencies top ", num2str(Topk), " (green: true, blue: reconstructed (pred))");
title(title_str);
ylim(yrange);
xlim([1, num_original_datapoints]);

% save
sim_frames(figsave_frame_idx) = getframe(gcf);
figsave_frame_idx = figsave_frame_idx + 1;

end


%% saver 
writerObj = VideoWriter('fft_pred.avi');
writerObj.FrameRate = 1;
open(writerObj);
for i=1:length(sim_frames)
    frame = sim_frames(i) ;    
    writeVideo(writerObj, frame);
end
close(writerObj);


% Read in the movie.
obj = VideoReader('fft_pred.avi');
vid = read(obj);
frames = obj.NumberOfFrames;
for ii = 1 : frames
    save_name = strcat('results/recon_fft_', num2str(TRAIN_DAYS(ii)), '.png');
    imwrite(vid(:,:,:,ii), save_name);
end