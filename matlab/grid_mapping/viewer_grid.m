% clear; clc;
addpath(genpath('../data'));

config;

%% Parsing the file 
filename = "taxi_off_2018-04-09_070000_100000.csv";
% event_struct = taxiEventParser(filename);

roi = standard_roi;
event_spots = findSpotROI(event_struct.spot, roi);


%% Viz Seoul
if(0)
    figure(1); clf;
    pcshow(event_spots, 'MarkerSize', 30);
    axis equal;

    set(gcf,'color','w');
    set(gca,'color','w');

    view(0, 90);
end


%% Metric to Grid map 
% grid_size is defined in the config.m
% but for convinience, redefine here.
grid_size = 1500;

num_grid_map_x = round((roi(1,2) - roi(1,1)) / grid_size);
num_grid_map_y = round((roi(2,2) - roi(2,1)) / grid_size);

grid_map = zeros(num_grid_map_y, num_grid_map_x);

for event_idx = 1:event_struct.len
    event_xy = event_struct.spot(event_idx, 1:2);
    event_grid_idx = xy2gridindex(event_xy, roi, grid_size);
    
    if(event_grid_idx(1) ~= 0)
        grid_map(event_grid_idx(2), event_grid_idx(1)) = ...
            grid_map(event_grid_idx(2), event_grid_idx(1)) + 1;
    end
    
end

%% how many grids are the hot spot?
num_grids_whole = size(grid_map,1) * size(grid_map,2);
num_grids_nonzeros = nnz(find(grid_map > 0));
disp([num_grids_whole, num_grids_nonzeros])

% main
HOT_SPOT_NUM_THRES = 1000;
num_hotspots = nnz(find(grid_map > HOT_SPOT_NUM_THRES));
disp([num_hotspots, ...
      100*(num_hotspots/num_grids_nonzeros), ...
      100*(num_hotspots/num_grids_whole)]);

%% viz hot spots
figure(2); clf;
imagesc(grid_map);
axis equal;
colormap jet;
% colormap(flipud(gray));

color_minnum_event = 0;
color_maxnum_event = HOT_SPOT_NUM_THRES;
caxis([color_minnum_event, color_maxnum_event]);
colorbar;

%% grid map to histogram 
grid_map_histvec = reshape(grid_map, size(grid_map,1)*size(grid_map,2), 1);
grid_map_histvec_nonzeros = grid_map_histvec(find(grid_map_histvec~=0));

num_bars = 500;
figure(3); clf;
histogram(grid_map_histvec_nonzeros, num_bars)
ylim([0, 50]);


