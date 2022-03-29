function [points, rot] = rrMapPlace(obj,varargin)
% Generate a position list for assets on the map
% Input:
%
% lane:
%   'leftdriving': left lane.
%   'rightdriving': right lane.
%   'leftshoulder': shoulder of left lane.
%   'rightshoulder': shoulder of right lane.
%
% pos:
%   'onroad': generate points on lane.
%   'offroad':generate points on offroad
%
% 'pointnum':
%    number of points. This can be a single number or an array.
%'layerWidth':
%    offroad sub-areas divided by pointnum input.
%'minDistanceToRoad':
%    mininum distance to the road which an asset is allowed to
%    place.
% We will use the diagram below to show three parameters above:
%
%    pointnum = [100, 50, 30]
%    layerWidth is denoated by LW.
%    minDistanceToRoad is denoted by MDR
%
%    |< LW  >|< LW  >|< LW  >|<MDR>|--------|
%    |       |       |       |<MDR>|--------|
%    |30     |50     |100    |<MDR>|--road--|
%    |objects|objects|objects|<MDR>|--------|
%    |       |       |       |<MDR>|--------|
%    (The other side of the road is symmetric)
%
%    We can gradually reduced the number of assets with the
%    increase on distance to the road, this is mainly for
%    saving memory sapce and rendering time.
%
% Output:
%    points: a list of positions defined by [x, y, z]
%    rot   : a list of rotations defined by radian.
%
%
%%
p = inputParser;
p.addParameter('lane','leftdriving');
p.addParameter('pos','onroad');
p.addParameter('pointnum',0,@isnumeric);
p.addParameter('layerWidth',5,@isnumeric);
p.addParameter('minDistanceToRoad',2,@isnumeric);
p.addParameter('posOffset',0); % allow an offset to add randomness (meter)
p.addParameter('rotOffset',0); % allow an offset to add randomness (radian)
p.parse(varargin{:});

pos=p.Results.pos;
lane = p.Results.lane;
minDistanceToRoad=p.Results.minDistanceToRoad;
layerWidth=p.Results.layerWidth;
pointnum=p.Results.pointnum;
posOffset = p.Results.posOffset;
rotOffset = p.Results.rotOffset;

% On road objects does not distributed on different layers, so we sum the
% number of points here, and sum is used for onroad case.
sumofpoints=sum(pointnum);

points=zeros(sumofpoints,2);

rot=zeros(sumofpoints,1);
% choose a lane
switch lane
    case 'leftdriving'
        laneCoordinates=obj.road.leftDrivingCoordinates;
    case 'leftshoulder'
        laneCoordinates=obj.road.leftShoulderCoordinates;
    case 'rightdriving'
        laneCoordinates=obj.road.rightDrivingCoordinates;
    case 'rightshoulder'
        laneCoordinates=obj.road.rightShoulderCoordinates;
    otherwise
        disp('wrong lane type')
end

xi=laneCoordinates(:,1); yi=laneCoordinates(:,2);

%%
% randomly generate points in the driving lane or by the road shoulder
switch pos
    case 'onroad'
        for i=1:sumofpoints
            n1=randi(numel(xi)-1);
            x1=xi(n1);y1=yi(n1);
            x2=xi(n1+1);y2=yi(n1+1);
            k=(y2-y1)/(x2-x1);
            points(i,1)=x1+rand*(x2-x1);
            points(i,2)=y1+k*(points(i,1)-x1) + rand(1)*posOffset;
            [rot(i),~] = cart2pol(x2-x1,y2-y1);
            if contains(lane,'left')
                rot(i) = pi+rot(i);
            end
            points(i,1) = points(i,1) + rand(1)*posOffset;
            points(i,2) = points(i,2) + rand(1)*posOffset;
            rot(i) = rot(i)+rand(1)*rotOffset;
        end
    case 'offroad'
        switch lane
            case 'leftshoulder'
                j=1;
                for layer=1:numel(pointnum)
                    for i=1:pointnum(layer)
                        n1=randi(numel(xi)-1);
                        x1=xi(n1);y1=yi(n1);x2=xi(n1+1);y2=yi(n1+1);k=(y2-y1)/(x2-x1);
                        x3=x1+rand*(x2-x1);y3=y1+k*(x3-x1);
                        dd=minDistanceToRoad+layerWidth*(layer-1)+layerWidth*rand;
                        points(j,1)=x3-dd*k/sqrt(k*k+1);points(j,2)=y3+dd/sqrt(k*k+1);
                        %                                     plot(points(j,1),points(j,2),'r*');
                        [rot(j),~]=cart2pol(x2-x1,y2-y1);
                        %                                     rot(j) = pi-rot(j);
                    
                        points(j,1) = points(j,1) + rand(1)*posOffset;
                        points(j,2) = points(j,2) + rand(1)*posOffset;
                        rot(j) = rot(j)+rand(1)*rotOffset;

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
                        dd=minDistanceToRoad+layerWidth*(layer-1)+layerWidth*rand;
                        points(j,1)=x3+dd*k/sqrt(k*k+1);points(j,2)=y3-dd/sqrt(k*k+1);
                        %                                     plot(points(j,1),points(j,2),'r*');
                        [rot(j),~]=cart2pol(x2-x1,y2-y1);

                        points(j,1) = points(j,1) + rand(1)*posOffset;
                        points(j,2) = points(j,2) + rand(1)*posOffset;
                        rot(j) = rot(j)+rand(1)*rotOffset;

                        j=j+1;
                    end
                end
        end
    otherwise
        disp('unsupported position, only [rightshoulder, leftshoulder] are supported now');
end
end


