function [lookAt, asset] = assetAdd(obj, varargin)
% Add asset by user specified distance and relative degree to camera lookAt
% 
% Input:
%       lookat:   Camera lookAt;
%       distance: Distance to camera along the direction of lookAt;
%       degree:   Offset degree to the direction of the lookAt, -90 to 90
%                 is allowed.
%
% Zheny_lane, VistaLab, 2022
p = inputParser;
p.addParameter('lookat',''); % this can be empty, or a lookAt struct
p.addParameter('distance',10);% meter
p.addParameter('degree',0); % -90 to 90 degree

p.parse(varargin{:});

lookAt   = p.Results.lookat;
distance = p.Results.distance;
offDeg   = p.Results.degree;
%%
% random pick one type of driving, then one of the lanes.
randomPickLane = randi([0 1]);
pickCamLane = randi([0 1]);
% randomPickLane = 1;
if randomPickLane==1
    lanecoordinates = obj.road.leftDrivingCoordinates;
    disp('Asset is on left lane.')
%     delta = -0.1;
else
    lanecoordinates = obj.road.rightDrivingCoordinates;
%     delta =  0.1;
end
laneID = randi(numel(lanecoordinates));
x_lane=lanecoordinates{laneID}(:,1);y_lane=lanecoordinates{laneID}(:,2);
% if no lookAt is given, pick a random point on road
if strcmp(lookAt,'')
    
    if pickCamLane==1
        lanecoordinates = obj.road.leftDrivingCoordinates;
        disp('Camera is on left lane')
    else
        lanecoordinates = obj.road.rightDrivingCoordinates;
    end
    laneID = randi(numel(lanecoordinates));
    x_lane_cam=lanecoordinates{laneID}(:,1);y_lane_cam=lanecoordinates{laneID}(:,2);
    n1=randi(round(numel(x_lane_cam)/5));
    x1=x_lane_cam(n1);y1=y_lane_cam(n1);
    x2=x_lane_cam(n1+1);y2=y_lane_cam(n1+1);
    k=(y2-y1)/(x2-x1);
    points(1)=x1+rand*(x2-x1);
    points(2)=y1+k*(points(1)-x1);
    [dir,~] = cart2pol(x2-x1,y2-y1);
    lookAt.from = [points(1), points(2), 0];
    
    if pickCamLane==1
        disp('Camera is on left lane');
        %             dir = pi+dir;
        lookAt.to = [-acos(dir)+lookAt.from(1) -asin(dir)+lookAt.from(2) 0];
    else
        lookAt.to = [acos(dir)+lookAt.from(1) asin(dir)+lookAt.from(2) 0];
    end
    % elseif strcmp(lookAt, 'start')

end

% semi-circle points
center = [lookAt.from(1) lookAt.from(2)];
axis = [1 0 0];
direction = [lookAt.to(1)-lookAt.from(1) lookAt.to(2)-lookAt.from(2) 0];
Theta = atan2(norm(cross(axis, direction)), dot(axis, direction));

[x_cam, y_cam] = semiCircle(center, distance, Theta, deg2rad(offDeg)); 

% calculate intersection of semi-circle with lanes
[x_obj,y_obj] = intersections(x_lane, y_lane, x_cam, y_cam, true);
if isempty(x_obj)
    error('No intersection: something is wrong.')
end
[~, index] = min(abs(x_lane(:)-x_obj(:)));
% find direction
% [x_cam_delta, y_cam_delta] = semiCircle(center, distance + delta, Theta, deg2rad(offDeg));
% [x_obj_delta, y_obj_delta] = intersections(x_lane, y_lane, x_cam_delta, y_cam_delta, true);

[obj_dir,~] = cart2pol(x_lane(index+1) - x_obj, y_lane(index+1) - y_obj);

asset.position = [x_obj,y_obj];

if randomPickLane==1
    asset.rotation = obj_dir+pi;
else
    asset.rotation = obj_dir;
end
end

function [x,y] = semiCircle(center, radius, angle, offsetRad)
% figure;
th = linspace( pi/2 + offsetRad + angle, -pi/2 + offsetRad + angle, 100);
% center = [0, 0];
x = radius*cos(th) + center(1);
y = radius*sin(th) + center(2);
% plot(x,y); axis equal;
end