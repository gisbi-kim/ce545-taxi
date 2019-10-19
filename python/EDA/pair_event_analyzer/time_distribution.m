
% onoff_pairs = csvread("taxi_onoffpair_2018-04-16_070000_100000.csv");

timediffs = onoff_pairs(:, end);

VALID_DURATION = [0, 7200]; % sec, e.g., up to 2 hours
timediffs = timediffs(find(timediffs > VALID_DURATION(1)));
timediffs = timediffs(find(timediffs < VALID_DURATION(2)));

figure(1); clf;
histogram(timediffs, 200);