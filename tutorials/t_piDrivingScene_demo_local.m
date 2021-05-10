%% Automatically assemble an automotive scene and render locally
%
%    t_piDrivingScene_demo
%
% Dependencies
%    ISETCloud, ISET3d, ISETCam and scitran
%
% Description:
%   Generate driving scenes using the gcloud (kubernetes) methods.  The
%   scenes are built by sampling roads from the Flywheel database. To be
%   able to render locally, number of assets are reduced to be able to run
%   on a local computer (with less cores and memory).
%
%   To delete the cluster when you are done execute the command
%
%       gcloud container clusters delete cloudrendering
%
% Author: Zhenyi Liu;
%
% See also
%   piSceneAuto, piSkymapAdd, gCloud

%%  Initialize ISETcam
ieInit;

% We need Docker
if ~piDockerExists, piDockerConfig; end
st = scitran('stanfordlabs');

%%  Example scene creation

% We start by setting up the traffic conditions.
%
% We have pre-computed a large number of traffic scenarios using SUMO.
% We store these in the data/sumo_input/demo/trafficflow
% sub-directory.  The compute methods are stored in the
% data/sumo_input directory.

% In these simulations we typically define the conditions and use the
% pre-computed SUMO data stored in the trafficflow directoy.  Each of
% the types of trafficflow files has many different time points, so we
% do not have to reuse the exact same conditions we only reuse the
% general conditions. 
%
% To see the available roadTypes use piRoadTypes

% For this demo, here is one of the road types
roadType = 'curve_6lanes_001';

% Available trafficflowDensity: low, medium, high
trafficflowDensity = 'low';

% Choose a timestamp(1~360), which is the moment in the SUMO
% simulation we will use.

% simulation that we record the data. 
timestamp = 100;

% Find the proper trafficflow file from data folder 
trafficflowPath   = fullfile(iaRootPath,'data','sumo_input','demo',...
    'trafficflow',sprintf('%s_%s_trafficflow.mat',roadType,trafficflowDensity));
localTF = fullfile(piRootPath,'local','trafficflow');

% Copy the file to a local directory
if ~exist(localTF,'dir'), mkdir(localTF);end
copyfile(trafficflowPath,localTF);
disp('*** Road traffic flow')

%% Initialize the recipe for the type of driving conditions

% Available sceneTypes: city1, city2, city3, city4, citymix, suburb
sceneType = 'suburb';

% This takes around 150 seconds the first time.  If you run it
% multiple times, it will be shorter. 
%
% Cloud rendering is true by default. 
%
% The piSceneAuto function downloads the recipes for the assets from
% Flywheel into a local directory.  These recipes will be integrated
% into a larger scene recipe.  All the material and geometry will be
% assembled into the scene, below.  (We will need to download the
% files later, but we already know where they are on Flywheel).
%
tic
disp('*** Scene Generation.....')

% The recipe returned here, thisR, includes all the information about
% the assets and driving conditions
[sceneR, sceneInfo] = piSceneAuto('sceneType',sceneType,...
    'roadType',roadType,...
    'trafficflowDensity',trafficflowDensity,...
    'timeStamp',timestamp,...
    'scitran',st);

% SUMO parameters.  Some day we will move this code into piSceneAuto,
% which has these parameters already anyway.
sceneR.set('traffic flow density',trafficflowDensity);
sceneR.set('traffic timestamp',timestamp);
toc

disp('*** Driving scene recipe initialized.')

%% Add a skymap and add SkymapFwInfo to fwList

thisTime = '16:30';  % The time of day of the sky

% We will put a skymap in the local directory so people without
% Flywheel can see the output
[acqID, skyname] = piFWSkymapAdd(thisTime, st);

% Add a light to the merged scene

% Delete any lights that happened to be there
sceneR = piLightDelete(sceneR, 'all');

rotation = piRotationMatrix('y',45, 'x',-90);

skymap = piLightCreate('new skymap', ...
    'type', 'infinite',...
    'string mapname', skyname,...
    'rotation',rotation);

sceneR.set('light', 'add', skymap);

skymapfwInfo = [acqID,' ',skyname];
sceneInfo.fwList = [sceneInfo.fwList,' ',skymapfwInfo];
disp('*** Skymap added')

%% Camera render parameters

% The camera lenses are stored in data/lens
lensname = 'wide.56deg.6.0mm.dat';
sceneR.camera = piCameraCreate('realistic','lens file',lensname);

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
disp('*** Camera created')

%% Place the camera in the scene

% To place the camera, we find a car and place the camera at the front
% of the car.  We find the car using the trafficflow information.
tfFileName = sprintf('%s_%s_trafficflow.mat',roadType,trafficflowDensity);

% Full path to file
tfFileName = fullfile(piRootPath,'local','trafficflow',tfFileName);

% Load the trafficflow variable, which contains the whole time series
load(tfFileName,'trafficflow');

% Choose the time stamp
thisTrafficflow = trafficflow(timestamp);

% See end of script for how to assign the camera to a random car.
camPos = 'front';               % Position of the camera on the car
cameraVelocity = 0 ;            % Camera velocity (meters/sec)
CamOrientation = 270;           % Starts at x-axis.  -90 (or 270) to the z axis.
sceneR.lookAt.from = [0;3;40];   % X,Y,Z world coordinates
sceneR.lookAt.to   = [0;1.9;150];% Where the camera is pointing in the scene
sceneR.lookAt.up   = [0;1;0];    % The upward direction (towards the sky)

sceneR.set('exposure time',1/200);
disp('*** Camera positioned')

%% Set the file names for input and output

if piContains(sceneType,'city')
    outputDir = fullfile(piRootPath,'local',strrep(sceneInfo.roadinfo.name,'city',sceneType));
    sceneR.inputFile = fullfile(outputDir,[strrep(sceneInfo.roadinfo.name,'city',sceneType),'.pbrt']);
else
    outputDir = fullfile(piRootPath,'local',strcat(sceneType,'_',sceneInfo.name));
    sceneR.inputFile = fullfile(outputDir,[strcat(sceneType,'_',sceneInfo.name),'.pbrt']);
end

% We might use md5 to hash the parameters and put them in the file
% name.  But we have not.  Instead we make these really complicated
% file names.
if ~exist(outputDir,'dir'), mkdir(outputDir); end
filename = sprintf('%s_%s_v%0.1f_f%0.2f%s_o%0.2f_%i%i%i%i%i%0.0f.pbrt',...
                            sceneType,...
                            dayTime,...
                            cameraVelocity,...
                            sceneR.lookAt.from(3),...
                            camPos,...
                            CamOrientation,...
                            clock);
sceneR.outputFile = fullfile(outputDir,filename);

%% Makes the materials, particularly glass, look right.
piMaterialGroupAssign(sceneR);

%% Write the recipe for the scene we generated
piWrite(sceneR,'creatematerials',true,...
    'overwriteresources',false,'lightsFlag',false,...
    'thistrafficflow',thisTrafficflow);

% If you want to see the file, use
%  edit(thisR.outputFile)
disp('*** Scene written');

%%
oi = piRender(sceneR);

%% Show the OI and some metadata

oiWindow(oi);

% Save a png of the OI, but after passing through a sensor
fname = fullfile(piRootPath,'local',[oi.name,'.png']);
% piOI2ISET is a similar function, but frequently changed by Zhenyi for different experiments, 
% so this function is better for a tutorial.
img = piSensorImage(oi,'filename',fname,'pixel size',2.5);
%{
ieNewGraphWin
imagesc(ieObject.metadata.meshImage)
%}
