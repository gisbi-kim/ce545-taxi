% clear; clc;

DATES = {"2018-04-02", "2018-04-06", "2018-04-09", "2018-04-13", ...
        "2018-04-16", "2018-04-20", "2018-04-23", "2018-04-27"};

num_dates = length(DATES);

for date_idx = 1:num_dates
    if(rem(date_idx,2) == 0)
        whatday = "FRI";
    else
        whatday = "MON";
    end
    
    ON_OR_OFF = "ON";
    gridmap = on_grid_list{date_idx};

    
    fig_idx = 2; 
    onofftype = strcat(DATES{date_idx}, " ", whatday, ", ", ON_OR_OFF);
    time_duration = "17-20";
    GRID_SIZE = 300;
    color_range = [0, 100]; 
    save = 1;
    makeFigureGridMap(fig_idx, gridmap, onofftype, time_duration, GRID_SIZE, color_range, save);
    pause(1);

end