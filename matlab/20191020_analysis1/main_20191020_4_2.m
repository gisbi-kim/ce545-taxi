% clear; clc;

DATES = {"2018-04-02", "2018-04-06", "2018-04-09", "2018-04-13", ...
        "2018-04-16", "2018-04-20", "2018-04-23", "2018-04-27"};

num_dates = length(DATES);

gridmap = on_grid_list{1};
gridmap_size = size(gridmap);

mean_mon_gridmap = zeros(gridmap_size);
mean_fri_gridmap = zeros(gridmap_size);
mean_gridmap = zeros(gridmap_size);

for date_idx = 1:num_dates
    
    gridmap = on_grid_list{date_idx};

    if(rem(date_idx,2) == 0)
        whatday = "FRI";
        mean_fri_gridmap = mean_fri_gridmap + gridmap;
    else
        whatday = "MON";
        mean_mon_gridmap = mean_mon_gridmap + gridmap;
    end
    
    mean_gridmap = mean_gridmap + gridmap;

end
mean_mon_gridmap = mean_mon_gridmap./ (num_dates/2);
mean_fri_gridmap = mean_fri_gridmap./ (num_dates/2);
mean_gridmap = mean_gridmap./num_dates;
fri_mon_diff_gridmap = mean_fri_gridmap - mean_mon_gridmap;

save("data/on_g300_sroi_all_avg.mat", "mean_gridmap");
save("data/on_g300_sroi_mon_avg.mat", "mean_mon_gridmap");
save("data/on_g300_sroi_fri_avg.mat", "mean_fri_gridmap");
save("data/on_g300_sroi_fri_mon_avg_diff.mat", "fri_mon_diff_gridmap");
% save("data/off_g300_sroi_all_avg.mat", "mean_gridmap");
% save("data/off_g300_sroi_mon_avg.mat", "mean_mon_gridmap");
% save("data/off_g300_sroi_fri_avg.mat", "mean_fri_gridmap");
% save("data/off_g300_sroi_fri_mon_avg_diff.mat", "fri_mon_diff_gridmap");


%%

fig_idx = 2; 
ON_OR_OFF = "ON";
% onofftype = strcat("Diff (Friday Mean - Monday Mean)", ", ", ON_OR_OFF);
onofftype = strcat("Friday Mean", ", ", ON_OR_OFF);
% onofftype = strcat("Monday Mean", ", ", ON_OR_OFF);

time_duration = "17-20";
GRID_SIZE = 300;

% color_range = [0, 50]; % for diff
% color_range = [20, 50]; % for diff
color_range = [0, 100]; 

save_figure = 1;
makeFigureGridMap(fig_idx, mean_fri_gridmap, onofftype, time_duration, GRID_SIZE, color_range, save_figure);
pause(1);

