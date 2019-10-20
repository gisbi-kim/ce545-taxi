function [] = makeFigureGridMap(fig_idx, grid_map, onofftype, time_duration, grid_size, color_range, save)

%% draw a figure 
figure(fig_idx); clf;
imagesc(grid_map);
set(gcf, 'Position', [10, 10, 1150, 850]);

title_str = strcat(onofftype, " (time: ", time_duration, "), grid size: ", num2str(grid_size), " meter");
title(title_str);

axis equal; colormap jet;

color_minnum_event = color_range(1); 
color_maxnum_event = color_range(2);

caxis([color_minnum_event, color_maxnum_event]); 
colorbar;


%% save as png
if(save)
    save_name = strcat("fig/", onofftype, "_time", time_duration, "_gridsize", num2str(grid_size), ".png");
    saveas(gcf, save_name)   
end

end

