%% 
% randomly generate points for RoadRunner lane

% Input: 
% xodrfile
% geojsonfile
% lane  -lane of interest
% step  -lane sample step, shorter step means accuracier lane curve
% pos   -point position, 'in' or 'by' the lane
% d     -distance away from lane (for points 'by' the lane only)
% forestwidth   -the 1st forestwidth has pointnum(1) points, ith has pointnum(i) points (for points 'by' the lane only)
% pointnum  -num of points to be generated
% 
% Output:
% points-position of points
% dir   -direction of road, polarcoordinate
% 
% Example:
% {
%     [points,dir]=random_generate_points();
%     plot(points(:,1),points(:,2),'*');
% }
% {
%     pointnum=[15 5 3];
%     [points,dir]=random_generate_points('lane','rightshoulder','pos','by','pointnum',pointnum,'forestwidth',5e-5,'d',2e-5)
%     plot(points(:,1),points(:,2),'*')    
% }



%% 
function [points,dir]=random_generate_points(varargin)

p = inputParser;
p.addParameter('xodrfile','/Volumes/USBshare_1/ISETAuto/RRdata/simple3_21/simple3_21.xodr')
p.addParameter('geojsonfile','/Volumes/USBshare_1/ISETAuto/RRdata/simple3_21/simple3_21.geojson')
p.addParameter('lane','leftdriving')
p.addParameter('step',0.5,@isnumeric);
p.addParameter('pos','in');
p.addParameter('pointnum',5);
p.addParameter('forestwidth',2,@isnumeric);
p.addParameter('d',2,@isnumeric);
p.parse(varargin{:});
xodrfile=p.Results.xodrfile;
geojsonfile=p.Results.geojsonfile;
lane=p.Results.lane;
step=p.Results.step;
pos=p.Results.pos;
d=p.Results.d;
forestwidth=p.Results.forestwidth;
pointnum=p.Results.pointnum;

pointsum=sum(pointnum);
points=zeros(pointsum,2);
dir=zeros(pointsum,1);

%% 
% read laneID from xodr file
S = readstruct(xodrfile,"FileType","xml")

for ii=1:numel(S.road.lanes.laneSection.left.lane)
    if strcmp(S.road.lanes.laneSection.left.lane(ii).typeAttribute,"shoulder")
        leftshoulderID=S.road.lanes.laneSection.left.lane(ii).userData.vectorLane.laneIdAttribute
    elseif strcmp(S.road.lanes.laneSection.left.lane(ii).typeAttribute,"driving")
        leftdrivingID=S.road.lanes.laneSection.left.lane(ii).userData.vectorLane.laneIdAttribute
    end
end

for ii=1:numel(S.road.lanes.laneSection.right.lane)
    if strcmp(S.road.lanes.laneSection.right.lane(ii).typeAttribute,"shoulder")
        rightshoulderID=S.road.lanes.laneSection.right.lane(ii).userData.vectorLane.laneIdAttribute
    elseif strcmp(S.road.lanes.laneSection.right.lane(ii).typeAttribute,"driving")
        rightdrivingID=S.road.lanes.laneSection.right.lane(ii).userData.vectorLane.laneIdAttribute
    end
end


%% 
% read original (uneven) lane coordinates from geojson file and transform
% them into evenly spread points
road = jsonread(geojsonfile);
for ii = 1:numel(road.features)
    if strcmp(road.features(ii).properties.Id,leftshoulderID)
        leftshouldercoordinates = road.features(ii).geometry.coordinates*1e5;
        x=leftshouldercoordinates(:,1);y=leftshouldercoordinates(:,2);
        xi=min(x):step:max(x);
        yi=interp1(x,y,xi);
        leftshouldercoordinates=[xi;yi]';
        plot(xi,yi,'-')
        axis equal;hold on;

    elseif strcmp(road.features(ii).properties.Id,rightshoulderID)
        rightshouldercoordinates = road.features(ii).geometry.coordinates*1e5;
        x=rightshouldercoordinates(:,1);y=rightshouldercoordinates(:,2);
        xi=min(x):step:max(x);
        yi=interp1(x,y,xi);
        rightshouldercoordinates=[xi;yi]';
        plot(xi,yi,'-')

    elseif strcmp(road.features(ii).properties.Id,leftdrivingID)
        leftdrivingcoordinates = road.features(ii).geometry.coordinates*1e5;
        x=leftdrivingcoordinates(:,1);y=leftdrivingcoordinates(:,2);
        xi=min(x):step:max(x);
        yi=interp1(x,y,xi);
        leftdrivingcoordinates=[xi;yi]';
        plot(xi,yi,'-')

    elseif strcmp(road.features(ii).properties.Id,rightdrivingID)
        rightdrivingcoordinates = road.features(ii).geometry.coordinates*1e5;
        x=rightdrivingcoordinates(:,1);y=rightdrivingcoordinates(:,2);
        xi=min(x):step:max(x);
        yi=interp1(x,y,xi);
        rightdrivingcoordinates=[xi;yi]';
        plot(xi,yi,'-')
        
    end
end
%% 
% choose a lane
switch lane
    case 'leftdriving'
        lanecoordinates=leftdrivingcoordinates;
    case 'leftshoulder'
        lanecoordinates=leftshouldercoordinates;
    case 'rightdriving'
        lanecoordinates=rightdrivingcoordinates;
    case 'rightshoulder'
        lanecoordinates=rightshouldercoordinates;
    otherwise
        disp('wrong lane type')
end
xi=lanecoordinates(:,1);yi=lanecoordinates(:,2);

%% 
% randomly generate points in the driving lane or by the road shoulder
switch pos
    case 'in'
        for i=1:pointsum
            n1=randi(numel(xi));
            x1=xi(n1);y1=yi(n1);x2=xi(n1+1);y2=yi(n1+1);k=(y2-y1)/(x2-x1);
            points(i,1)=x1+rand*(x2-x1);points(i,2)=y1+k*(points(i,1)-x1);
            [dir(i),~]=cart2pol(x2-x1,y2-y1);
        end
    case 'by'
        switch lane
            case 'leftshoulder'
                j=1;
                for layer=1:numel(pointnum)
                    for i=1:pointnum(layer)
                        n1=randi(numel(xi)-1);
                        x1=xi(n1);y1=yi(n1);x2=xi(n1+1);y2=yi(n1+1);k=(y2-y1)/(x2-x1);
                        x3=x1+rand*(x2-x1);y3=y1+k*(x3-x1);
                        dd=d+forestwidth*(layer-1)+forestwidth*rand;
                        points(j,1)=x3-dd*k/sqrt(k*k+1);points(j,2)=y3+dd/sqrt(k*k+1);
                        plot(points(j,1),points(j,2),'r*');
                        [dir(j),~]=cart2pol(x2-x1,y2-y1);
                        j=j+1;
                    end
                end
            case 'rightshoulder'
                j=1;
                for layer=1:numel(pointnum)
                    for i=1:pointnum(layer)
                        n1=randi(numel(xi)-1);
                        x1=xi(n1);y1=yi(n1);x2=xi(n1+1);y2=yi(n1+1);k=(y2-y1)/(x2-x1);
                        x3=x1+rand*(x2-x1);y3=y1+k*(x3-x1);
                        dd=d+forestwidth*(layer-1)+forestwidth*rand;
                        points(j,1)=x3+dd*k/sqrt(k*k+1);points(j,2)=y3-dd/sqrt(k*k+1);
                        plot(points(j,1),points(j,2),'r*');
                        [dir(j),~]=cart2pol(x2-x1,y2-y1);
                        j=j+1;
                    end
                end
        end
    otherwise
        disp('unsupported position')
end