function [index] = xy2gridindex(xy, roi, grid_size)
% xy: event location 
% roi: [xmin, xmax; ymin, ymax]
% index: [row, col] of grid map matrix

%%
x = xy(1);
y = xy(2);

xmin = roi(1,1);
xmax = roi(1,2);
ymin = roi(2,1);
ymax = roi(2,2);

num_grid_map_x = round((roi(1,2) - roi(1,1)) / grid_size);
num_grid_map_y = round((roi(2,2) - roi(2,1)) / grid_size);

%%
x_idx_ratio = (x-xmin) / (xmax-xmin);
y_idx_ratio = (y-ymin) / (ymax-ymin);

x_idx = round(num_grid_map_x * x_idx_ratio);
y_idx = num_grid_map_y - round(num_grid_map_y * y_idx_ratio); 

index = [x_idx, y_idx];

if(x_idx > num_grid_map_x || ...
   y_idx > num_grid_map_y || ...
   x_idx < 1 || ...
   y_idx < 1)
    index = [0, 0];
end

end

