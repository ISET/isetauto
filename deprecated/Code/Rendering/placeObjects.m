function objects = placeObjects(varargin)

p = inputParser;
p.addParameter('cityId',1);
p.addParameter('nCars',5);
p.addParameter('nTrucks',1);
p.addParameter('nPeople',10);
p.addParameter('nBuses',1);

p.parse(varargin{:});
inputs = p.Results;

constants;

objects = [];
cntr = 1;


%% Trucks
%  Trucks are placed on the road at an arbitrary location, but the
%  orientation depends on how far from the centerline the truck is
for i=1:inputs.nTrucks
    currentClass = 'truck';
    nClass = length(assets.(currentClass));
    
    objects(cntr).class = currentClass;
    objects(cntr).id = randi(nClass);
    objects(cntr).modelPath = assets.(currentClass)(objects(cntr).id).modelPath;
    
    nAreas = length(assets.city(inputs.cityId).road);
    currentAreaId = randi(nAreas);
    currentArea = assets.city(inputs.cityId).road(currentAreaId);
    
    objects(cntr).area = currentAreaId;
    
    xpos = rand(1,1)*(currentArea.xrange(2) - currentArea.xrange(1)) + currentArea.xrange(1);
    ypos = rand(1,1)*(currentArea.yrange(2) - currentArea.yrange(1)) + currentArea.yrange(1);
    zpos = rand(1,1)*(currentArea.zrange(2) - currentArea.zrange(1)) + currentArea.zrange(1);
    
    objects(cntr).position = [xpos, ypos, zpos];
    objects(cntr).prefix = sprintf('%s_inst_%i_',currentClass,i);
    
    cvx_begin quiet
        variables p(1,2)
        minimize norm(p - [xpos, ypos],2)
        subject to
            currentArea.centerline.xrange(1) < p(1) < currentArea.centerline.xrange(2);
            currentArea.centerline.yrange(1) < p(2) < currentArea.centerline.yrange(2);
    cvx_end
    
    distance = sqrt((p(1)-xpos)^2 + (p(2)-ypos)^2);
    maxDistance = currentArea.laneSeparation/2;
    
    distanceFrac = distance/maxDistance;
    
    selector = (randi(2) - 1);
    orientation = selector * currentArea.lane(1).orientation + ...
                  (1-selector) * currentArea.lane(2).orientation + ...
                  distanceFrac * (rand(1,1)*20 - 10);
    
    objects(cntr).orientation = orientation;
    
    
    cntr = cntr+1;
end

%% Busses
for i=1:inputs.nBuses
    currentClass = 'bus';
    nClass = length(assets.(currentClass));
    
    objects(cntr).class = currentClass;
    objects(cntr).id = randi(nClass);
    objects(cntr).modelPath = assets.(currentClass)(objects(cntr).id).modelPath;
    
    nAreas = length(assets.city(inputs.cityId).road);
    currentAreaId = randi(nAreas);
    currentArea = assets.city(inputs.cityId).road(currentAreaId);
    
    objects(cntr).area = currentAreaId;
    
    xpos = rand(1,1)*(currentArea.xrange(2) - currentArea.xrange(1)) + currentArea.xrange(1);
    ypos = rand(1,1)*(currentArea.yrange(2) - currentArea.yrange(1)) + currentArea.yrange(1);
    zpos = rand(1,1)*(currentArea.zrange(2) - currentArea.zrange(1)) + currentArea.zrange(1);
    
    objects(cntr).position = [xpos, ypos, zpos];
    objects(cntr).prefix = sprintf('%s_inst_%i_',currentClass,i);
    
    cvx_begin quiet
        variables p(1,2)
        minimize norm(p - [xpos, ypos],2)
        subject to
            currentArea.centerline.xrange(1) < p(1) < currentArea.centerline.xrange(2);
            currentArea.centerline.yrange(1) < p(2) < currentArea.centerline.yrange(2);
    cvx_end
    
    distance = sqrt((p(1)-xpos)^2 + (p(2)-ypos)^2);
    maxDistance = currentArea.laneSeparation/2;
    
    distanceFrac = distance/maxDistance;
    
    selector = (randi(2) - 1);
    orientation = selector * currentArea.lane(1).orientation + ...
                  (1-selector) * currentArea.lane(2).orientation + ...
                  distanceFrac * (rand(1,1)*20 - 10);
    
    objects(cntr).orientation = orientation;
    
    cntr = cntr+1;
end

%% Cars
%  Cars are placed on the road at an arbitrary location and orientation.
for i=1:inputs.nCars
    
    currentClass = 'car';
    nClass = length(assets.(currentClass));
    
    objects(cntr).class = currentClass;
    objects(cntr).id = randi(nClass);
    objects(cntr).modelPath = assets.(currentClass)(objects(cntr).id).modelPath;
    
    nAreas = length(assets.city(inputs.cityId).road);
    currentAreaId = randi(nAreas);
    currentArea = assets.city(inputs.cityId).road(currentAreaId);
    
    objects(cntr).area = currentAreaId;
    objects(cntr).orientation = randi(360);
    
    xpos = rand(1,1)*(currentArea.xrange(2) - currentArea.xrange(1)) + currentArea.xrange(1);
    ypos = rand(1,1)*(currentArea.yrange(2) - currentArea.yrange(1)) + currentArea.yrange(1);
    zpos = rand(1,1)*(currentArea.zrange(2) - currentArea.zrange(1)) + currentArea.zrange(1);
    
    objects(cntr).position = [xpos, ypos, zpos];
    objects(cntr).prefix = sprintf('%s_inst_%i_',currentClass,i);
    
    cntr = cntr+1;
end

%% Pedestrians
%  Pedestrians are placed on the sidewalk at arbitrary location and
%  orientation.

for i=1:inputs.nPeople
    currentClass = 'person';
    nClass = length(assets.(currentClass));
    
    objects(cntr).class = currentClass;
    objects(cntr).id = randi(nClass);
    objects(cntr).modelPath = assets.(currentClass)(objects(cntr).id).modelPath;
    
    nAreas = length(assets.city(inputs.cityId).sidewalk);
    currentAreaId = randi(nAreas);
    currentArea = assets.city(inputs.cityId).sidewalk(currentAreaId);
    
    objects(cntr).area = currentAreaId;
    objects(cntr).orientation = randi(360);
    
    xpos = rand(1,1)*(currentArea.xrange(2) - currentArea.xrange(1)) + currentArea.xrange(1);
    ypos = rand(1,1)*(currentArea.yrange(2) - currentArea.yrange(1)) + currentArea.yrange(1);
    zpos = rand(1,1)*(currentArea.zrange(2) - currentArea.zrange(1)) + currentArea.zrange(1);
    
    objects(cntr).position = [xpos, ypos, zpos];
    objects(cntr).prefix = sprintf('%s_inst_%i_',currentClass,i);
    
    cntr = cntr+1;
end



end


    
    