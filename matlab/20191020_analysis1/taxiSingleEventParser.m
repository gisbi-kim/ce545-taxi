function [struct] = taxiSingleEventParser(file)
% return struct

%%
% file = csvread(filename);
num_records = length(file);

%% id
struct.id = file(:, 1);
struct.len = num_records;

%% xyz 
on_spots = file(:, 2:4);
on_spots_lng = on_spots(:, 1);
on_spots_lat = on_spots(:, 2);
on_spots_alt = on_spots(:, 3);

on_spots_lng_real = on_spots_lng / 10e6;
on_spots_lat_real = on_spots_lat / 10e6;

[on_x, on_y, tmp] = deg2utm(on_spots_lat_real, on_spots_lng_real);
on_z = ones(num_records, 1);

spots = [on_x, on_y, on_z];
struct.spot = spots;

nosiy_spots = [on_x, on_y, on_spots_alt];
struct.nosiy_spots = nosiy_spots;

%% time 
struct.time = num2str(file(:, 5));

month_str = struct.time(:, 5:6);
day_str = struct.time(:, 7:8);
hour_str = struct.time(:, 9:10);
min_str = struct.time(:, 11:12);
sec_str = struct.time(:, 13:14);

month = zeros(num_records, 1);
day = zeros(num_records, 1);
hour = zeros(num_records, 1);
min = zeros(num_records, 1);
sec= zeros(num_records, 1);
for idx = 1:num_records
    month(idx) = str2double(month_str(idx, :));
    day(idx) = str2double(day_str(idx, :));
    hour(idx) = str2double(hour_str(idx, :));
    min(idx) = str2double(min_str(idx, :));
    sec(idx) = str2double(sec_str(idx, :));
end
struct.month = month;
struct.day = day;
struct.hour = hour;
struct.min = min;
struct.sec = sec;

%% others
struct.azim = file(:, 6);
struct.vel = file(:, 7);


end

