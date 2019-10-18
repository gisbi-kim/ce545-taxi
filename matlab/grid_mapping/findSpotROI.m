function [filtered_spots] = findSpotROI(original_spots, roi)

% original_spots: N x 3
% roi: 2 x 2 ([xmin, xmax; ymin, ymax]

valid_xlim = roi(1, :);
valid_ylim = roi(2, :);

taxi_traj_allspots = original_spots;
taxi_traj_allspots  = ... 
    taxi_traj_allspots(find(taxi_traj_allspots(:, 2) > valid_ylim(1)), :);
taxi_traj_allspots  = ... 
    taxi_traj_allspots(find(taxi_traj_allspots(:, 2) < valid_ylim(2)), :);
taxi_traj_allspots  = ... 
    taxi_traj_allspots(find(taxi_traj_allspots(:, 1) > valid_xlim(1)), :);
taxi_traj_allspots  = ... 
    taxi_traj_allspots(find(taxi_traj_allspots(:, 1) < valid_xlim(2)), :);

filtered_spots = taxi_traj_allspots;

end

