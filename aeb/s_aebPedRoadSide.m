%% Illustrate and animate NHTSA night time PAEB Test
% Stationary pedestrian on right side of road
% 
% Dependencies
%   ISET3d, ISETAuto, ISETonline, and ISETCam
%   Prefix:  ia- means isetauto
%            pi- means iset3d-v4
%
%
% D. Cardinal, Stanford University, 2023

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% (Optional) isetdb() setup
% setup stanford server (n.b. ideally in user startup file)
setpref('db','server','acorn.stanford.edu'); 
setpref('db','port',49153);

% Opens a connection to the server
sceneDB = isetdb();

%% Find the road starter scene/asset and load it
% If fullpath to the asset is not given, we will find it in our database
% We have quite a few generated roads. Currently they are usually 400m long
road_name  = 'road_020';

% Create the road data object that we will populate with vehicles
% and other objects for eventual assembly into our scene
% We can find it either in our path, or the sceneDB
roadData = roadgen('road directory',road_name, 'asset directory', sceneDB);

% Create driving lane(s) for both directions
roadData.set('onroad car lanes',{'leftdriving','rightdriving'});


%% Place the offroad elements.  These are only animals and trees.  Not cars.
roadData.set('offroad tree names', {'tree_001','tree_002','tree_003'});
roadData.set('offroad n trees', [50, 1, 1]); % [50, 100, 150]
roadData.set('offroad tree lane', {'rightshoulder','leftshoulder'});

% the roadData object comes with a base ISET3d recipe for rendering
roadRecipe = roadData.recipe;

% There is some weird light in this scene that we need to remove:
roadRecipe.set('light','all','delete');

sceneName = 'PAEB_Roadside'; 
roadRecipe.set('outputfile',fullfile(piDirGet('local'),sceneName,[sceneName,'.pbrt']));

%% Set up the rendering skymap -- this is just one of many available
skymapName = 'night.exr'; % Most skymaps are in the Matlab path already
roadRecipe.set('skymap',skymapName);

% Make the scene a night time scene
% Really dark -- NHTSA says down to .2 lux needs to work
% So we should calculate what that means for how we scale the skymap
skymapNode = strrep(skymapName, '.exr','_L');
roadRecipe.set('light',skymapNode, 'specscale', 0.001);

%% Place the elements that are on the road (onroad)
% For this demo we add cars, animals, and people manually
% For the cars so far, z appears to be up, y is L/R, x is towards us

% iaAssetPlacement is relative to the car
% For x and y, and relative to the ground for z

% F150 is car type 058)
%roadRecipe = iaPlaceAsset(roadRecipe, 'car_058', [0 0 0], [0 0 180]);
roadRecipe = iaPlaceAsset(roadRecipe, 'car_004', [0 0 0], [0 0 180]);

% Add two cars coming towards us
%roadRecipe = iaPlaceAsset(roadRecipe, 'car_001', [40 -8 0], []);
%roadRecipe = iaPlaceAsset(roadRecipe, 'car_003', [28 -12 0], [0 0 0]);

% Add a truck ahead of us 
oncoming = false;
if oncoming
    roadRecipe = iaPlaceAsset(roadRecipe,'truck_001',[30 -3.2 0], [0 0 0]);
else
    %roadRecipe = iaPlaceAsset(roadRecipe,'truck_001',[60 -3.2 0], [0 0 180]);
end

% Add a pedestrian on the right side of our lane
roadRecipe = iaPlaceAsset(roadRecipe, 'pedestrian_002', [40 1 0], [0 0 0]);

%% Now we can assemble the scene using ISET3d methods
assemble_tic = tic(); % to time scene assembly
roadData.assemble();
fprintf('---> Scene assembled in %.f seconds.\n',toc(assemble_tic));

%% Set the recipe parameters
%  We want to render both the scene radiance and a depth map
roadRecipe.set('film render type',{'radiance','depth'});

% Set the render quality parameters, use 'quick' preset for demo
roadRecipe = iaQualitySet(roadRecipe, 'preset', 'quick');
roadRecipe.set('fov',45);                       % Field of View

% Put the camera on the F150
camera_type = 'grille'; % Or Grille
switch camera_type
    case 'front' % which means behind the mirror -- IPMA in Ford speak
        cameraHeightF150 = 1.8; % Mirror meters above ground
        cameraOffsetF150 = .9; % meters offset towards rear of truck
    case 'grille'
        cameraHeightF150 = .9; % Grille 
        cameraOffsetF150 = -1.9; % meters offset towards rear of truck
end

% Tweak position. Not elegant at all currently
roadRecipe.lookAt.from = [roadRecipe.lookAt.from(1) + cameraOffsetF150 ...
    roadRecipe.lookAt.from(2) cameraHeightF150];
roadRecipe.lookAt.to = [0 roadRecipe.lookAt.from(2) cameraHeightF150];

%% Render the scene, and maybe an OI (Optical Image through the lens)
scene = piWRS(roadRecipe,'render flag','hdr');

%% Add Flare if desired
% flare parameters are borrowed from other code, may not be ideal
sceneSampleSize = sceneGet(scene,'sample size','m');
[flareOI,pupilmask, psf] = piFlareApply(scene,...
                    'psf sample spacing', sceneSampleSize, ...
                    'numsidesaperture', 10, ...
                    'fnumber',5, 'dirtylevel',0);

% These parameters yield a good result, but can't be right
flareIP = piRadiance2RGB(flareOI,'etime',1/6000,'sensor', 'MT9V024SensorRGB.mat',...
            'analoggain', 1/5);

%% Process the (non-flare) scene through a sensor to the ip 
%
% This isn't great because the sensor is not explicit.
ip = piRadiance2RGB(scene,'etime',1/30,'sensor','MT9V024SensorRGB');

% In case we want to check
%oiWindow(flareOI);

% Get a detector
yDetect = yolov4ObjectDetector("csp-darknet53-coco");

% Now look at the non-flare case
rgb = ipGet(ip, 'srgb');
[bboxes,scores,labels] = detect(yDetect,rgb);
rgb = insertObjectAnnotation(rgb,"rectangle",bboxes,scores);

ieNewGraphWin;
imshow(rgb);
title("Rendered Image -- No flare");

flareRGB = ipGet(flareIP, 'srgb');
[bboxes,scores,labels] = detect(yDetect,flareRGB);
flareRGB = insertObjectAnnotation(flareRGB,"rectangle",bboxes,labels);
ieNewGraphWin;
imshow(flareRGB);
title("Rendered Image -- With flare");

