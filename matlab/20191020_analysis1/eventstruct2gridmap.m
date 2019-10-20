function grid_map = eventstruct2gridmap(event_struct, roi, grid_size)

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

end

