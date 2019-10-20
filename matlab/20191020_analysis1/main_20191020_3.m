% clear; clc;
data_dir = "/home/gskim/Dropbox/19 Summer-Fall KAIST/4. 수업/CE545/1. 프로젝트/3. main 시간순/20191020 이것저것 wip/data/";
addpath(genpath(data_dir));

DATES = {"2018-04-02", "2018-04-06", "2018-04-09", "2018-04-13", ...
        "2018-04-16", "2018-04-20", "2018-04-23", "2018-04-27"};
%%
config;

ROI = standard_roi;
GRID_SIZE = 300;

%% Parsing the file 
time_duration = "17-20";

on_grid_list = {};
off_grid_list = {};
diff_grid_list = {};
for date_idx = 1:length(DATES)
    
    DATE = DATES{date_idx};
    filename = strcat("taxi_onoffpair_", DATE, "_170000_200000.csv");
    disp(filename)
    filepath = fullfile(data_dir, "onoffevent_pair", time_duration, filename);
    tic; [on_struct, off_struct, travel_times] = taxiPairEventParser(filepath); toc;

    %% Metric to Grid map 
    on_grid = eventstruct2gridmap(on_struct, ROI, GRID_SIZE);
    off_grid = eventstruct2gridmap(off_struct, ROI, GRID_SIZE);
    diff_grid = off_grid - on_grid;
    
    on_grid_list{date_idx} = on_grid;
    off_grid_list{date_idx} = off_grid;
    diff_grid_list{date_idx} = diff_grid;
    
    disp(size(on_grid_list));
end
save("data/on_g300_sroi_allday.mat", "on_grid_list");
save("data/off_g300_sroi_allday.mat", "off_grid_list");
save("data/diff_g300_sroi_allday.mat", "diff_grid_list");

