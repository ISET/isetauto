%% Automatically assemble an automotive scene and render locally
%
%    t_piDrivingScene_demo
%
% Dependencies
%    ISETAuto, ISET3d, ISETCam and scitran
%    Prefix: ia- means isetauto
%            pi- means pbrt2iset(iset3d)
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
%--------------------------------------------------------------------------
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
%--------------------------------------------------------------------------
% To see the available roadTypes use iaRoadTypes

% For this demo, here is one of the road types
roadType = 'curve_6lanes_001';

% Available trafficflowDensity: low, medium, high
trafficflowDensity = 'low';

% Choose a timestamp(1~360), which is the moment in the SUMO
% simulation we will use.

% simulation that we record the data. 
timestamp = 100;

% Available sceneTypes: city1, city2, city3, city4, citymix, suburb
sceneType = 'suburb';

% The time of day of the sky
skymapTime = '16:30';  

%% Initialize the recipe for the type of driving conditions
%--------------------------------------------------------------------------
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
%--------------------------------------------------------------------------

tic
disp('*** Scene Generation...')

% The recipe returned here, thisR, includes all the information about
% the assets and driving conditions
[sceneR, sceneInfo] = iaSceneAuto('sceneType',sceneType,...
                                  'roadType',roadType,...
                                  'trafficflowDensity',trafficflowDensity,...
                                  'timeStamp',timestamp,...
                                  'skymapTime',skymapTime,...
                                  'scitran',st);
toc

disp('*** Driving scene is generated.')

%% Set the file names for input and output

if piContains(sceneType,'city')
    outputDir = fullfile(iaRootPath,'local',strrep(sceneInfo.roadinfo.name,'city',sceneType));
    sceneR.inputFile = fullfile(outputDir,[strrep(sceneInfo.roadinfo.name,'city',sceneType),'.pbrt']);
else
    outputDir = fullfile(iaRootPath,'local',strcat(sceneType,'_',sceneInfo.name));
    sceneR.inputFile = fullfile(outputDir,[strcat(sceneType,'_',sceneInfo.name),'.pbrt']);
end

% We might use md5 to hash the parameters and put them in the file
% name.  But we have not.  Instead we make these really complicated
% file names.
if ~exist(outputDir,'dir'), mkdir(outputDir); end
filename = sprintf('%s_%i%i%i%i%i%0.0f_demo.pbrt', sceneType, clock);
sceneR.outputFile = fullfile(outputDir,filename);

%% Assign predefined automotive related materials to the scene

% Remove duplicated material
sceneR = piMaterialCleanup(sceneR);

iaAutoMaterialGroupAssign(sceneR);  

%% Write the recipe for the scene we generated
piWrite(sceneR,'overwriteresources',false,'lightsFlag',false,'thistrafficflow',thisTrafficflow);

% If you want to see the file, use
%  edit(thisR.outputFile)
disp('*** Scene written');
%% remove some assets for faster rendering (to do)

%%
oi = piRender(sceneR);

%% Show the OI and some metadata

oiWindow(oi);

% Save a png of the OI, but after passing through a sensor
fname = fullfile(iaRootPath,'local',[oi.name,'.png']);
% piOI2ISET is a similar function, but frequently changed by Zhenyi for different experiments, 
% so this function is better for a tutorial.
img = piSensorImage(oi,'filename',fname,'pixel size',2.5);
%{
ieNewGraphWin
imagesc(ieObject.metadata.meshImage)
%}
