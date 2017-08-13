% 
close all;
clear all;
clc;

constants;

% Concerns the first city block
lane(1).xrange = [-1500 -1500];
lane(1).yrange = [-45000 45000];
lane(1).orientation = -90;

lane(2).xrange = [+1500 +1500];
lane(2).yrange = [-45000 45000];
lane(2).orientation = 90;

lane(3).xrange = [-45000 45000];
lane(3).yrange = [-1500 -1500];
lane(3).orientation = 0;

lane(4).xrange = [-45000 45000];
lane(4).yrange = [1500 1500];
lane(4).orientation = 180;

nCars = 5;
% nTrucks = 1;
% nBuses = 1;
% nMales = 5;
% nFemales = 5;

objects = [];

cntr = 1;
for i=1:nCars
    objects(cntr).prefix = sprintf('car_inst_%i_',i);
    objects(cntr).class = 'car';
    objects(cntr).id = randi(length(car2directory));
    objects(cntr).lane = randi(4);
    
    currentLane = lane(objects(cntr).lane);
    
    objects(cntr).orientation = currentLane.orientation;
    
    xpos = randn(1,1)*(currentLane.xrange(2) - currentLane.xrange(1)) + currentLane.xrange(1);
    ypos = randn(1,1)*(currentLane.yrange(2) - currentLane.yrange(1)) + currentLane.yrange(1);
    
    objects(cntr).position = [xpos, ypos, 0];
    
    cntr = cntr+1;
end