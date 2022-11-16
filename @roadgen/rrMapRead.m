function obj = rrMapRead(obj, rrDataPath, varargin)
% Reads a road map exported by road runner
%
% Synopsis
%    obj = rrMapRead(obj, rrDataPath, varargin)
%
% Brief description
% 
%   RoadRunner exports a scenes with several files:
%       scene.obj
%       (3D mesh decription file which is used for 3d rendering and road elevation calculation)
%       scene.geojson
%       (3D coordinates which describes the position of lane boundary and driving lane and terrain)
%       scene.xodr
%       (opendrive file which describes the lane function, e.g. left lane, driving lane)
%
% We parse scene.obj and scene.xodr and return the road information saved in roadgen class.
%{
                roadgen.rrMapRead(roadgen,'Path/to/rrdata');
%}
%
% See also
%   roadgen
%

%% Parse inputs
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
xodrfile    = fullfile(rrDataPath,[sceneName,'.xodr']);
geojsonfile = fullfile(rrDataPath,[sceneName, '.geojson']);
objfile     = fullfile(rrDataPath,[sceneName, '.obj']);

%% 
% read laneID from xodr file
openDriveMap = readstruct(xodrfile,"FileType","xml");

i=1;j=1;k=1;

leftdrivingID  = ""; rightdrivingID  = "";
leftshoulderID = ""; rightshoulderID = "";
leftsidewalkID = ""; rightsidewalkID = "";

for ii=1:numel(openDriveMap.road.lanes.laneSection.left.lane)
    if strcmp(openDriveMap.road.lanes.laneSection.left.lane(ii).typeAttribute,"shoulder")
        leftshoulderID(i)=openDriveMap.road.lanes.laneSection.left.lane(ii).userData.vectorLane.laneIdAttribute;
        i=i+1;
    elseif strcmp(openDriveMap.road.lanes.laneSection.left.lane(ii).typeAttribute,"driving")
        leftdrivingID(j)=openDriveMap.road.lanes.laneSection.left.lane(ii).userData.vectorLane.laneIdAttribute;
        j=j+1;
    elseif strcmp(openDriveMap.road.lanes.laneSection.left.lane(ii).typeAttribute,"sidewalk")
        leftsidewalkID(k)=openDriveMap.road.lanes.laneSection.left.lane(ii).userData.vectorLane.laneIdAttribute;
        k=k+1;
    end
end

i=1;j=1;k=1;
for ii=1:numel(openDriveMap.road.lanes.laneSection.right.lane)
    if strcmp(openDriveMap.road.lanes.laneSection.right.lane(ii).typeAttribute,"shoulder")
        rightshoulderID(i)=openDriveMap.road.lanes.laneSection.right.lane(ii).userData.vectorLane.laneIdAttribute;
        i=i+1;
    elseif strcmp(openDriveMap.road.lanes.laneSection.right.lane(ii).typeAttribute,"driving")
        rightdrivingID(j)=openDriveMap.road.lanes.laneSection.right.lane(ii).userData.vectorLane.laneIdAttribute;
        j=j+1;
    elseif strcmp(openDriveMap.road.lanes.laneSection.right.lane(ii).typeAttribute,"sidewalk")
        rightsidewalkID(k)=openDriveMap.road.lanes.laneSection.right.lane(ii).userData.vectorLane.laneIdAttribute;
        k=k+1;
    end
end

%% Read original (uneven) lane coordinates from geojson file 
%  transform them into evenly spread points

ieNewGraphWin;

geoInformation = jsonread(geojsonfile);
leftDrivingCoordinates   = cell(1,numel(leftdrivingID));
rightDrivingCoordinates  = cell(1,numel(rightdrivingID));
leftShoulderCoordinates  = cell(1,numel(leftshoulderID));
rightShoulderCoordinates = cell(1,numel(rightshoulderID));
leftSidewalkCoordinates  = cell(1,numel(leftsidewalkID));
rightSidewalkCoordinates = cell(1,numel(rightsidewalkID));


for ii = 1:numel(geoInformation.features)
    for j=1:numel(leftshoulderID)
        if strcmp(geoInformation.features(ii).properties.Id,leftshoulderID(j))
            leftShoulderCoordinates{j} = geoInformation.features(ii).geometry.coordinates;
            % Convert geographic corrdiantes to local cartesian coordinates
            lon=leftShoulderCoordinates{j}(:,1);
            lat=leftShoulderCoordinates{j}(:,2);
            alt=leftShoulderCoordinates{j}(:,3);            
            origin = [0,0,0];
            [x,y,~] = iaGPS2Local(lat,lon,alt,origin);
            xi=min(x):step:max(x);
            yi=interp1(x,y,xi);
%             zi = interp1(x,z, xi);
            leftShoulderCoordinates{j}=[xi;yi]';
            plot(xi,yi,'s');axis equal;hold on;
        end
    end    

    for j=1:numel(rightshoulderID)
        if strcmp(geoInformation.features(ii).properties.Id,rightshoulderID(j))
            rightShoulderCoordinates{j} = geoInformation.features(ii).geometry.coordinates;
            lon=rightShoulderCoordinates{j}(:,1);
            lat=rightShoulderCoordinates{j}(:,2);
            alt=rightShoulderCoordinates{j}(:,3);            
            origin = [0,0,0];
            [x,y,~] = iaGPS2Local(lat,lon,alt,origin);
            xi=min(x):step:max(x);
            yi=interp1(x,y,xi);
%             zi = interp1(x,z, xi);
            rightShoulderCoordinates{j}=[xi;yi]';
            plot(xi,yi,'o');
        end
    end

    for j=1:numel(leftdrivingID)
        if strcmp(geoInformation.features(ii).properties.Id,leftdrivingID(j))
            leftDrivingCoordinates{j} = geoInformation.features(ii).geometry.coordinates;
            % Convert geographic corrdiantes to local cartesian coordinates
            lon=leftDrivingCoordinates{j}(:,1);
            lat=leftDrivingCoordinates{j}(:,2);
            alt=leftDrivingCoordinates{j}(:,3);            
            origin = [0,0,0];
            [x,y,~] = iaGPS2Local(lat,lon,alt,origin);
            xi=min(x):step:max(x);
            yi=interp1(x,y,xi);
%             zi = interp1(x,z, xi);
            leftDrivingCoordinates{j}=[xi;yi]';
            plot(xi,yi,'-');
        end
    end  

    for j=1:numel(rightdrivingID)
        if strcmp(geoInformation.features(ii).properties.Id,rightdrivingID(j))
        
            rightDrivingCoordinates{j} = geoInformation.features(ii).geometry.coordinates;
            lon=rightDrivingCoordinates{j}(:,1);
            lat=rightDrivingCoordinates{j}(:,2);
            alt=rightDrivingCoordinates{j}(:,3);            
            origin = [0,0,0];
            
            [x,y,~] = iaGPS2Local(lat,lon,alt,origin);
            xi=min(x):step:max(x);
            yi=interp1(x,y,xi);
%             zi = interp1(x,z, xi);
            rightDrivingCoordinates{j}=[xi;yi]';
            plot(xi,yi,'-');
        end
    end

    for j=1:numel(leftsidewalkID)
        if strcmp(geoInformation.features(ii).properties.Id,leftsidewalkID(j))
            leftSidewalkCoordinates{j} = geoInformation.features(ii).geometry.coordinates;
            % Convert geographic corrdiantes to local cartesian coordinates
            lon=leftSidewalkCoordinates{j}(:,1);
            lat=leftSidewalkCoordinates{j}(:,2);
            alt=leftSidewalkCoordinates{j}(:,3);
            origin = [0,0,0];
            [x,y,~] = iaGPS2Local(lat,lon,alt,origin);
            xi=min(x):step:max(x);
            yi=interp1(x,y,xi);
%             zi = interp1(x,z, xi);
            leftSidewalkCoordinates{j}=[xi;yi]';
            plot(xi,yi,'-');
%             plot(xi,zi,'-');

        end
    end

    for j=1:numel(rightsidewalkID)
        if strcmp(geoInformation.features(ii).properties.Id,rightsidewalkID(j))
            rightSidewalkCoordinates{j} = geoInformation.features(ii).geometry.coordinates;
            lon=rightSidewalkCoordinates{j}(:,1);
            lat=rightSidewalkCoordinates{j}(:,2);
            alt=rightSidewalkCoordinates{j}(:,3);
            origin = [0,0,0];
            [x,y,~] = iaGPS2Local(lat,lon,alt,origin);
            xi=min(x):step:max(x);
            yi=interp1(x,y,xi);
%             zi = interp1(x,z, xi);
            rightSidewalkCoordinates{j}=[xi;yi]';
            plot(xi,yi,'-');
%             plot(xi,zi,'-');
        end
    end
end

xlabel('Position (m)'); ylabel('Position (m)');
grid on;
% hold on;% tmp
obj.roaddirectory = rrDataPath;
obj.road.leftshoulderID = leftshoulderID;
obj.road.leftdrivingID  = leftdrivingID;
obj.road.leftsidewalkID = leftsidewalkID;
obj.road.rightshoulderID = rightshoulderID;
obj.road.rightdrivingID  = rightdrivingID;
obj.road.rightsidewalkID = rightsidewalkID;

obj.road.leftShoulderCoordinates = leftShoulderCoordinates;
obj.road.rightShoulderCoordinates= rightShoulderCoordinates;
obj.road.leftDrivingCoordinates  = leftDrivingCoordinates;
obj.road.rightDrivingCoordinates = rightDrivingCoordinates;

if isfile(objfile)
    obj.road.geometryOBJ  = readObj(objfile);
else
    obj.road.geometryOBJ = [];
end
end