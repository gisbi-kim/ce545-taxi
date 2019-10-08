filename = "taxi_on_2018-04-09_070000_100000.csv";
file = csvread(filename);

on_spots = file(:, 2:3);
on_spots_lng = on_spots(:, 1);
on_spots_lat = on_spots(:, 2);

on_spots_lng_real = on_spots_lng / 10e6;
on_spots_lat_real = on_spots_lat / 10e6;

[on_x, on_y, tmp] = deg2utm(on_spots_lat_real, on_spots_lng_real);
on_z = ones(length(on_x), 1);

valid_xlim = [2.5*1e5, 3.6*1e5];
valid_ylim = [4.1*1e6, 4.2*1e6];

taxi_traj_allspots = [on_x, on_y, on_z];
taxi_traj_allspots  = ... 
    taxi_traj_allspots(find(taxi_traj_allspots(:, 2) > valid_ylim(1)), :);
taxi_traj_allspots  = ... 
    taxi_traj_allspots(find(taxi_traj_allspots(:, 1) < valid_xlim(2)), :);

figure(1); clf;
% scatter(taxi_traj_allspots(:,1), taxi_traj_allspots(:,2));
pcshow(taxi_traj_allspots)
axis equal;

set(gcf,'color','w');
set(gca,'color','w');

view(0, 90);
