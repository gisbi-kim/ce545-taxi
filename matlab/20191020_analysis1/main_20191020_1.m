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
GRID_SIZE = 500;

on_grid = eventstruct2gridmap(on_struct, ROI, GRID_SIZE);
off_grid = eventstruct2gridmap(off_struct, ROI, GRID_SIZE);
diff_grid = off_grid - on_grid;

% busstation_grid = ...

%% viz hot spots
color_range = [0, round(GRID_SIZE/3)];
save = 1;

onofftype = "ON"; fig_idx = 2;
makeFigureGridMap(fig_idx, on_grid, onofftype, time_duration, GRID_SIZE, color_range, save);
onofftype = "OFF"; fig_idx = 3;
makeFigureGridMap(fig_idx, off_grid, onofftype, time_duration, GRID_SIZE, color_range, save);
onofftype = "Diff (OFF - ON)"; fig_idx = 4;
makeFigureGridMap(fig_idx, diff_grid, onofftype, time_duration, GRID_SIZE, color_range, save);




