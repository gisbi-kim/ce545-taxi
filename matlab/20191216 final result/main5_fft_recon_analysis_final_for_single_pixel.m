addpath(genpath('./utils/'));
addpath(genpath('../data'));

%% load parsed all hitmap data (x, y, t) 
% details are in parse hitmap data or main3_fft_pred_seperated_figs
taxi_hitmap_history_3d = load("taxi_hitmap_history_3d.mat");
taxi_hitmap_history_3d = taxi_hitmap_history_3d.taxi_hitmap_history_3d;


%% get pixel history for each pixel (== 1D signal) 
hitmap_size_y = size(hitmap, 1);
hitmap_size_x = size(hitmap, 2);
num_hitmap = size(taxi_hitmap_history_3d, 3);

% NOTE: change here!
target_pixel_loc = [60, 59]; % (row = y, col = x)
% target_pixel_loc = [53, 38]; % (row = y, col = x)
% target_pixel_loc = [78, 40]; % (row = y, col = x)

% where, location == pixel
target_loc_history = squeeze(taxi_hitmap_history_3d(target_pixel_loc(1), target_pixel_loc(2), :));
% target_loc_history = target_loc_history(14: end);

TRAIN_RATIO = 1/(4.2);
target_loc_history_to_train = target_loc_history(1 : round(length(target_loc_history)*TRAIN_RATIO));
num_train_datapoints = length(target_loc_history_to_train);

num_subfigures = 7;
idx_cur_cubfigure = 1;
figure(10); clf;
subplot(num_subfigures, 1, idx_cur_cubfigure); idx_cur_cubfigure = idx_cur_cubfigure + 1;
plot(target_loc_history, 'Color', [0.7, 0.7, 0.7]); hold on;
plot(target_loc_history_to_train, 'b');
line([num_train_datapoints, num_train_datapoints], [0, 400], 'Color','red', 'LineWidth', 1.5);
title("The PARTIAL data of the original event history used (up to the red line while the whole data is 30 days)");
yrange = [0, max(target_loc_history_to_train) * 1.2];
xlim([1, 1500]);
ylim(yrange);
x = [1 9];
y = [2 12];



%% fft
sampling_freq = 2; % unit: hour, and 2 measurements (i.e., every 30 min) per hour

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
TOTLA_PRED_HOURS = 720;
num_datapoints_to_pred = size(target_loc_history, 1);
target_pred_days = linspace(0, TOTLA_PRED_HOURS, num_datapoints_to_pred);

Topk = 2;
target_loc_pred = ... % last arg: num_freqs_to_use
    reconstructSignalUsingFreqs(target_pred_days, amplitude, freq_domain, phase, Topk); 
figure(10); 
subplot(num_subfigures, 1, idx_cur_cubfigure); idx_cur_cubfigure = idx_cur_cubfigure + 1;
plot(target_loc_history, 'g'); hold on; 
plot(target_loc_pred, 'b'); 
line([num_train_datapoints, num_train_datapoints], [0, 400], 'Color','red', 'LineWidth', 1.5);
title_str = strcat("A reconstructed signal using frequencies top ", num2str(Topk), " (green: true, blue: reconstructed (pred))");
title(title_str);
ylim(yrange);

Topk = 10;
target_loc_pred = ... % last arg: num_freqs_to_use
    reconstructSignalUsingFreqs(target_pred_days, amplitude, freq_domain, phase, Topk); 
figure(10); 
subplot(num_subfigures, 1, idx_cur_cubfigure); idx_cur_cubfigure = idx_cur_cubfigure + 1;
plot(target_loc_history, 'g'); hold on; 
plot(target_loc_pred, 'b'); 
line([num_train_datapoints, num_train_datapoints], [0, 400], 'Color','red', 'LineWidth', 1.5);
title_str = strcat("A reconstructed signal using frequencies top ", num2str(Topk), " (green: true, blue: reconstructed (pred))");
title(title_str);
ylim(yrange);

Topk = 30;
target_loc_pred = ... % last arg: num_freqs_to_use
    reconstructSignalUsingFreqs(target_pred_days, amplitude, freq_domain, phase, Topk); 
figure(10); 
subplot(num_subfigures, 1, idx_cur_cubfigure); idx_cur_cubfigure = idx_cur_cubfigure + 1;
plot(target_loc_history, 'g'); hold on;
plot(target_loc_pred, 'b'); 
line([num_train_datapoints, num_train_datapoints], [0, 400], 'Color','red', 'LineWidth', 1.5);
title_str = strcat("A reconstructed signal using frequencies top ", num2str(Topk), " (green: true, blue: reconstructed (pred))");
title(title_str);
ylim(yrange);

Topk = 100;
target_loc_pred = ... % last arg: num_freqs_to_use
    reconstructSignalUsingFreqs(target_pred_days, amplitude, freq_domain, phase, Topk); 
figure(10); 
subplot(num_subfigures, 1, idx_cur_cubfigure); idx_cur_cubfigure = idx_cur_cubfigure + 1;
plot(target_loc_history, 'g'); hold on;
plot(target_loc_pred, 'b'); 
line([num_train_datapoints, num_train_datapoints], [0, 400], 'Color','red', 'LineWidth', 1.5);
title_str = strcat("A reconstructed signal using frequencies top ", num2str(Topk), " (green: true, blue: reconstructed (pred))");
title(title_str);
ylim(yrange);

Topk = round((num_train_datapoints/2) * 0.95);
target_loc_pred = ... % last arg: num_freqs_to_use
    reconstructSignalUsingFreqs(target_pred_days, amplitude, freq_domain, phase, Topk); 
figure(10); 
subplot(num_subfigures, 1, idx_cur_cubfigure); idx_cur_cubfigure = idx_cur_cubfigure + 1;
plot(target_loc_history, 'g'); hold on; 
plot(target_loc_pred, 'b'); 
line([num_train_datapoints, num_train_datapoints], [0, 400], 'Color','red', 'LineWidth', 1.5);
title_str = strcat("A reconstructed signal using frequencies top ", num2str(Topk), " (green: true, blue: reconstructed (pred))");
title(title_str);
ylim(yrange);


