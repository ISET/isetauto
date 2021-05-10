function [sceneR,sceneInfo] = iaSceneAuto(varargin)
% Generate scene(s) for Autonomous driving scenarios using SUMO/SUSO
%
% Syntax
%
% Description
%  Assembles assets from Flywheel and SUMO into a city or suburban street
%  scene.
%
% Inputs
%  N/A
%
% Optional key/value pairs
%   scene type     - 'city' or 'suburban'
%   road type      - See piRoadTypes
%   traffice flow density -  Traffic density (Default 'medium')
%   time stamp (Default: 50) - Ticks in the SUMO simulation.  Integer
%   scitran        - Flywheel interface object (Default is 'stanfordlabs')
%   tree density   - Not currently used
%
% Returns:
%  sceneR     - Scene recipe
%  sceneInfo  - A struct containing the list of flywheel objects and road
%               information. To list this out use road.fwList;
%
% Author:
%   Zhenyi Liu
%   Update: Zhenyi, 2021
%
% See also
%   piRoadTypes, t_piDrivingScene_demo
%

%% Read input parameters

varargin =ieParamFormat(varargin);

p = inputParser;
p.addParameter('sceneType','city',@ischar);
p.addParameter('treeDensity','random',@ischar);
p.addParameter('roadType','crossroad',@ischar);
p.addParameter('trafficflow',[]);
p.addParameter('trafficflowDensity','medium',@ischar);
p.addParameter('timestamp',50,@isnumeric);
p.addParameter('skymapTime','16:30');
p.addParameter('scitran',[],@(x)(isa(x,'scitran')));

p.parse(varargin{:});

sceneType          = p.Results.sceneType;
treeDensity        = p.Results.treeDensity;  % Not yet used
roadType           = p.Results.roadType;
trafficflowDensity = p.Results.trafficflowDensity;
trafficflow        = p.Results.trafficflow;
timestamp          = p.Results.timestamp;
skymapTime         = p.Results.skymapTime;
st                 = p.Results.scitran;

%% Flywheel init

if isempty(st), st = scitran('stanfordlabs'); end

%% Read a road from Flywheel that we will use with SUMO and SUSO
[sceneInfo,sceneR] = iaRoadCreate('roadtype',roadType,...
                                  'trafficflowDensity',trafficflowDensity,...
                                  'sceneType',sceneType,...
                                  'scitran',st);
disp('--> Base road is created')
%% Read a local traffic flow if available
% Find the proper trafficflow file from data folder 
tfDataPath   = fullfile(iaRootPath,'data','sumo_input','demo',...
    'trafficflow',sprintf('%s_%s_trafficflow.mat',roadType,trafficflowDensity));

localTF = fullfile(iaRootPath,'local','trafficflow');

% Copy the file to a local directory
if ~exist(localTF,'dir'), mkdir(localTF);end
copyfile(tfDataPath, localTF);
load(tfDataPath, 'trafficflow');
%{
% This is where SUMO is called, or the local file is read
tfPath   = fullfile(iaRootPath,'local',...
    'trafficflow', sprintf('%s_%s_trafficflow.mat', roadType, trafficflowDensity));
trafficflowFolder = fileparts(tfPath);

if ~exist(trafficflowFolder,'dir'), mkdir(trafficflowFolder); end

if ~exist(tfPath,'file')
    trafficflow = piTrafficflowGeneration(sceneInfo);
    save(tfPath, 'trafficflow');
    disp('-----> Traffic flow using SUMO is generated.')
elseif isempty(trafficflow)
    load(tfPath,'trafficflow');
    disp('-----> Local file of traffic flow is loaded.')
end
%}
disp('--> Traffic flow is generated')

%% SUSO Simulation of urban static objects
% Put stationary assets into the city or suburban street
disp('--> SUSO is planning...')

tree_interval = rand(1)*4+2;
if piContains(sceneType,'city')|| piContains(sceneType,'suburb')
    
    %% place objects on sidewalk,e.g. street lights, trees,etc.
    susoPlaced = iaSidewalkPlan(sceneInfo,st,trafficflow(timestamp),...
                                'tree_interval',tree_interval);

    %% place parked cars
    parallelParking = false;
    if piContains(roadType,'parking')
        trafficflow = iaParkingPlace(sceneInfo, trafficflow,...
                                    'parallelParking', parallelParking);
    end
    
    %% place buildings
    building_listPath = fullfile(iaRootPath,'local','AssetLists',...
        sprintf('%s_building_list.mat',sceneType));
    
    if ~exist(building_listPath,'file')
        building_list = iaAssetListCreate('session',sceneType,'scitran',st);
        save(building_listPath,'building_list')
    else
        load(building_listPath,'building_list');
    end
    
    showfigure          = false; % draw planned 2d building blocks;
    buildingPosList     = iaBuildingPosList(building_list, sceneR, showfigure);
    susoPlaced.building = iaSUSOPlace(building_list,buildingPosList);  
   
    % Add flywheel info
    sceneInfo = fwInfoAppend(sceneInfo,susoPlaced);

    disp('--> SUSO Assets are placed on the road.');
else
    disp('No SUSO assets placed.  Not city or suburb');
end


%% Place vehicles/pedestrians from  SUMO traffic flow data on the road
% Put the suso placed assets on the road
disp('--> SUMO is planning...')

[sumoPlaced, ~] = iaSUMOPlace(trafficflow,...
                              'timestamp',timestamp,...
                              'scitran',st);

%% Add objects to scene
sceneR = iaObjectsAssemble(sceneR, susoPlaced);

sceneR = iaObjectsAssemble(sceneR, sumoPlaced);

sceneR.set('traffic flow density',trafficflowDensity);
sceneR.set('traffic timestamp',timestamp);
disp('--> Completed SUMO combined with SUSO');

%% Add skymap
% We will put a skymap in the local directory so people without
% Flywheel can see the output

[acqID, skyname] = piFWSkymapAdd(skymapTime, st);

% Add a light to the merged scene

% Delete any lights that happened to be there
sceneR   = piLightDelete(sceneR, 'all');

rotation = piRotationMatrix('y', 45, 'x', -90);

skymap   = piLightCreate('new skymap', ...
                       'type', 'infinite',...
                       'string mapname', skyname,...
                       'rotation',rotation);

% Add a light to the scene
sceneR.set('light', 'add', skymap);

skymapfwInfo = [acqID,' ',skyname];

% Add flywheel info
disp('--> Skymap added')

%% Camera render parameters
% The camera lenses are stored in data/lens
lensname = 'wide.56deg.6.0mm.dat';
sceneR.camera = piCameraCreate('omni','lens file',lensname);

% Set the rendering and film resolution properties in the recipe.
% Here are some suggestions about time and quality.
%
%   High quality parameters
%       film resolution:  [1280 720]
%       pixel samples:    2048
%       film diagonal:    10 (mm)
%       nbounces:         10    (indoor scenes use 50, or even more)
%       aperture:         1 (mm)
%
%  Fast low quality - mainly reduced the number of pixel samples.
%       film resolution   [1280 720]
%       pixel samples     64
%       film diagonal     10
%       nbounces          10
%       aperture          1
%
sceneR.set('film resolution',[1280 720]);
sceneR.set('pixel samples',16);   % 1024 or higher to reduce graphics noise
sceneR.set('film diagonal',10);
sceneR.set('nbounces',10);
sceneR.set('aperture',1);
disp('--> Camera is created')

%% Place the camera in the scene

% To place the camera, we find a car and place the camera at the front
% of the car.  We find the car using the trafficflow information.
tfFileName = sprintf('%s_%s_trafficflow.mat',roadType,trafficflowDensity);

% Full path to file
tfFileName = fullfile(piRootPath,'local','trafficflow',tfFileName);

% Load the trafficflow variable, which contains the whole time series
load(tfFileName,'trafficflow');

% Choose the time stamp
thisTrafficflow    = trafficflow(timestamp);

% See end of script for how to assign the camera to a random car.
camPos             = 'front';               % Position of the camera on the car
cameraVelocity     = 0 ;            % Camera velocity (meters/sec)
CamOrientation     = 270;           % Starts at x-axis.  -90 (or 270) to the z axis.
sceneR.lookAt.from = [0;3;40];   % X,Y,Z world coordinates
sceneR.lookAt.to   = [0;1.9;150];% Where the camera is pointing in the scene
sceneR.lookAt.up   = [0;1;0];    % The upward direction (towards the sky)
% To use: piCamPlace
sceneR.set('exposure time',1/200);
disp('--> Camera is positioned')

%% Add flywheel info
% Add suso placed                    
sceneInfo = fwInfoAppend(sceneInfo, susoPlaced);
% Add suso placed  
sceneInfo = fwInfoAppend(sceneInfo, sumoPlaced);
% Add suso skymap  
sceneInfo.fwList = [sceneInfo.fwList,' ',skymapfwInfo];
end

%--------------------------------------------------------------------------
%% List the selected fwInfo str with road.fwList
function sceneInfo = fwInfoAppend(sceneInfo,assets)

assetFields = fieldnames(assets);
for jj = 1:length(assetFields)
    for kk = 1: length(assets.(assetFields{jj}))
        sceneInfo.fwList = [sceneInfo.fwList,' ',assets.(assetFields{jj})(kk).fwInfo];
    end
end
end




