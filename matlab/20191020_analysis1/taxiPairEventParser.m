function [on_struct, off_struct, travel_times] = taxiPairEventParser(filename)

%%
file = csvread(filename);

on_file = file(:, 1:8);
off_file = file(:, 9:16);

on_struct = taxiSingleEventParser(on_file);
off_struct = taxiSingleEventParser(off_file);
travel_times = file(:, 17);

end

