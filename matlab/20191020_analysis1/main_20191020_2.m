% clear; clc;
data_dir = "/home/gskim/Dropbox/19 Summer-Fall KAIST/4. 수업/CE545/1. 프로젝트/3. main 시간순/20191020 이것저것 wip/data/";
addpath(genpath(data_dir));

%%
config;
ROI = standard_roi;

%% Parsing the file 
time_duration = "07-10";

filename = "taxi_onoffpair_2018-04-02_070000_100000.csv";
filepath = fullfile(data_dir, "onoffevent_pair", time_duration, filename);

tic
% [on_struct, off_struct, travel_times] = taxiPairEventParser(filepath);
toc

%% Metric to Grid map 
% grid_size is defined in the config.m
% but for convinience, redefine here.
GRID_SIZE = 300;

on_grid = eventstruct2gridmap(on_struct, ROI, GRID_SIZE);
off_grid = eventstruct2gridmap(off_struct, ROI, GRID_SIZE);
diff_grid = off_grid - on_grid;

% busstation_grid = ...

%% viz event grid map (ON/OFF/Diff)
color_range = [0, round(GRID_SIZE/3)];

% onofftype = "ON"; fig_idx = 2;
% makeFigureGridMap(fig_idx, on_grid, onofftype, time_duration, GRID_SIZE, color_range);
% onofftype = "OFF"; fig_idx = 3;
% makeFigureGridMap(fig_idx, off_grid, onofftype, time_duration, GRID_SIZE, color_range);
% onofftype = "Diff (OFF - ON)"; fig_idx = 4;
% makeFigureGridMap(fig_idx, diff_grid, onofftype, time_duration, GRID_SIZE, color_range);

%% save hot spot (x,y) information 
HOT_SPOT_NUM_THRES_LIST = linspace(1, 200, 200);

target_grid = diff_grid;
for HOT_SPOT_NUM_THRES = HOT_SPOT_NUM_THRES_LIST
    HOT_SPOT_NUM_THRES_ALL = 1;
    [grid_hotspot_rowidx, grid_hotspot_colidx] = find(target_grid > HOT_SPOT_NUM_THRES_ALL);
    xy_all = [];
    for idx = 1:size(grid_hotspot_rowidx, 1)
        [x, y] = gridindex2xy([grid_hotspot_colidx(idx), grid_hotspot_rowidx(idx)], ROI, GRID_SIZE);   
        xy_all = [xy_all; x, y, 0];
    end

%     HOT_SPOT_NUM_THRES = 100;
    [grid_hotspot_rowidx, grid_hotspot_colidx] = find(target_grid > HOT_SPOT_NUM_THRES);
    xy = [];
    for idx = 1:size(grid_hotspot_rowidx, 1)
        [x, y] = gridindex2xy([grid_hotspot_colidx(idx), grid_hotspot_rowidx(idx)], ROI, GRID_SIZE);    
        xy = [xy; x, y, 0];
    end
    
    figure(123); clf;

    SCATTER_SIZE_GRID300 = [20, 50];
    SCATTER_SIZE_GRID100 = [10, 20];
    
    SCATTER_SIZE = SCATTER_SIZE_GRID300;
    scatter(xy_all(:, 1), xy_all(:, 2), SCATTER_SIZE(1), 'rs'); hold on;
    scatter(xy(:, 1), xy(:, 2), SCATTER_SIZE(2), 'bs', 'filled');

    title_str = strcat("Blue: the number of events is larger than ", num2str(HOT_SPOT_NUM_THRES));
    title(title_str);

    xlim(ROI(1,:)); ylim(ROI(2,:));
    view(0, 90); 
    axis equal;
    
    pause(0.1);
end
