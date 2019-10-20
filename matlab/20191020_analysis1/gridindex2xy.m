function [x, y] = gridindex2xy(grid_index, roi, grid_size)
% xy: event location 
% roi: [xmin, xmax; ymin, ymax]
% index: [row, col] of grid map matrix

%%
xmin = roi(1,1);
xmax = roi(1,2);
ymin = roi(2,1);
ymax = roi(2,2);

num_grid_map_x = round((roi(1,2) - roi(1,1)) / grid_size);
num_grid_map_y = round((roi(2,2) - roi(2,1)) / grid_size);

x_idx = grid_index(1);
y_idx = grid_index(2);

%%

% inverse of the equations in xy2gridindex.m
x_idx_ratio = (x_idx / num_grid_map_x); 
% from: x_idx_ratio = (x-xmin) / (xmax-xmin);
x = xmin + x_idx_ratio * (xmax-xmin);

% inverse of the equations in xy2gridindex.m
y_idx_ratio = (num_grid_map_y - y_idx) / num_grid_map_y; 
% from: x_idx_ratio = (x-xmin) / (xmax-xmin);
y = ymin + y_idx_ratio * (ymax-ymin);

end

