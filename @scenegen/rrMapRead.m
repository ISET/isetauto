function obj = rrMapRead(obj, rrDataPath, varargin)
% RoadRunner exports a scenes with several files:
%       scene.fbx
%       (3D mesh decription file which is used for 3d rendering)
%       scene.geojson
%       (3D coordinates which describes the position of lane boundary and driving lane and terrain)
%       scene.xodr
%       (opendrive file which describes the lane function, e.g. left lane, driving lane)
%
% We parse scene.fbx and scene.xodr and return the road information saved in scenegen class.
%{
                scenegen.rrMapRead(scenegen,'Path/to/rrdata');
%}
%
%%
varargin = ieParamFormat(varargin);
p = inputParser;

% The scene folder which exported from roadrunner
% we assume the folder name is the sceneName
p.addRequired('rrDataPath',@(x)(exist(rrDataPath,'dir')));
% unit is meter, for interpolating road coordinates
p.addParameter('step',0.5,@isnumeric);

p.parse(rrDataPath, varargin{:});

step = p.Results.step;

%% Get file names
[~, sceneName] = fileparts(rrDataPath);

xodrfile = fullfile(rrDataPath,[sceneName,'.xodr']);
geojsonfile = fullfile(rrDataPath,[sceneName, '.geojson']);

%%
% read laneID from xodr file
openDriveMap = readstruct(xodrfile,"FileType","xml");

for ii=1:numel(openDriveMap.road.lanes.laneSection.left.lane)
    if strcmp(openDriveMap.road.lanes.laneSection.left.lane(ii).typeAttribute,"shoulder")
        leftshoulderID=openDriveMap.road.lanes.laneSection.left.lane(ii).userData.vectorLane.laneIdAttribute;
    elseif strcmp(openDriveMap.road.lanes.laneSection.left.lane(ii).typeAttribute,"driving")
        leftdrivingID=openDriveMap.road.lanes.laneSection.left.lane(ii).userData.vectorLane.laneIdAttribute;
    end
end

for ii=1:numel(openDriveMap.road.lanes.laneSection.right.lane)
    if strcmp(openDriveMap.road.lanes.laneSection.right.lane(ii).typeAttribute,"shoulder")
        rightshoulderID=openDriveMap.road.lanes.laneSection.right.lane(ii).userData.vectorLane.laneIdAttribute;
    elseif strcmp(openDriveMap.road.lanes.laneSection.right.lane(ii).typeAttribute,"driving")
        rightdrivingID=openDriveMap.road.lanes.laneSection.right.lane(ii).userData.vectorLane.laneIdAttribute;
    end
end


%%
% read original (uneven) lane coordinates from geojson file and transform
% them into evenly spread points
geoInformation = jsonread(geojsonfile);
for ii = 1:numel(geoInformation.features)
    if strcmp(geoInformation.features(ii).properties.Id,leftshoulderID)
        leftShoulderCoordinates = geoInformation.features(ii).geometry.coordinates; 
        % Convert geographic corrdiantes to local cartesian coordinates
        lon=leftShoulderCoordinates(:,1);
        lat=leftShoulderCoordinates(:,2);
        alt=leftShoulderCoordinates(:,3);
        origin = [0,0,0];
        % will do z soon! Zhenyi
        [x,y,~] = latlon2local(lat,lon,alt,origin);
        xi=min(x):step:max(x);
        yi=interp1(x,y,xi);
        leftShoulderCoordinates=[xi;yi]';
        %         plot(xi,yi,'o')
        %         axis equal;hold on;

    elseif strcmp(geoInformation.features(ii).properties.Id,rightshoulderID)
        rightShoulderCoordinates = geoInformation.features(ii).geometry.coordinates; 
        % Convert geographic corrdiantes to local cartesian coordinates
        lon=rightShoulderCoordinates(:,1);
        lat=rightShoulderCoordinates(:,2);
        alt=rightShoulderCoordinates(:,3);
        origin = [0,0,0];
        [x,y,~] = latlon2local(lat,lon,alt,origin);
        xi=min(x):step:max(x);
        yi=interp1(x,y,xi);
        rightShoulderCoordinates=[xi;yi]';
        %         plot(xi,yi,'o')

    elseif strcmp(geoInformation.features(ii).properties.Id,leftdrivingID)
        leftDrivingCoordinates = geoInformation.features(ii).geometry.coordinates; 
        lon=leftDrivingCoordinates(:,1);
        lat=leftDrivingCoordinates(:,2);
        alt=leftDrivingCoordinates(:,3);
        origin = [0,0,0];
        [x,y,~] = latlon2local(lat,lon,alt,origin);
        xi=min(x):step:max(x);
        yi=interp1(x,y,xi);
        leftDrivingCoordinates=[xi;yi]';
        %         plot(xi,yi,'s')

    elseif strcmp(geoInformation.features(ii).properties.Id,rightdrivingID)
        rightDrivingCoordinates = geoInformation.features(ii).geometry.coordinates;
        lon=rightDrivingCoordinates(:,1);
        lat=rightDrivingCoordinates(:,2);
        alt=rightDrivingCoordinates(:,3);
        origin = [0,0,0];
        [x,y,~] = latlon2local(lat,lon,alt,origin);
        xi=min(x):step:max(x);
        yi=interp1(x,y,xi);
        rightDrivingCoordinates=[xi;yi]';
        %         plot(xi,yi,'s')

    end
end
obj.rrdatadirectory = rrDataPath;
obj.road.leftShoulderCoordinates = leftShoulderCoordinates;
obj.road.rightShoulderCoordinates= rightShoulderCoordinates;
obj.road.leftDrivingCoordinates  = leftDrivingCoordinates;
obj.road.rightDrivingCoordinates = rightDrivingCoordinates;

end