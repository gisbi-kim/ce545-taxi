clear; clc;
addpath(genpath('../data'));

config;

%%
filename = "taxi_on_2018-04-09_070000_100000.csv";
event_struct = taxiEventParser(filename);

event_spots = findSpotROI(event_struct.spot, gangnam_roi);

figure(1); clf;
pcshow(event_spots, 'MarkerSize', 30);
axis equal;

set(gcf,'color','w');
set(gca,'color','w');

view(0, 90);
