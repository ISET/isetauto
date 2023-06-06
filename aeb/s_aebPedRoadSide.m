%% Illustrate and animate NHTSA night time PAEB Test
% Stationary pedestrian on right side of road
%
% Dependencies
%   ISET3d, ISETAuto, ISETonline, and ISETCam
%
% D. Cardinal, Stanford University, 2023

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

sceneQuality = 'quick'; % quick or HD or paper for video quality

%% (Optional) isetdb() setup (using existing prefs)
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

% Not sure how much we can/should put in the NHTSA preset
testScenario = [];
testScenario.testName = 'pedRoadsideRight';
paebNHTSA(roadRecipe, testScenario);

%% Set up the rendering skymap -- this is just one of many available
skymapName = 'night.exr'; % Most skymaps are in the Matlab path already
roadRecipe.set('skymap',skymapName);

% Make the scene a night time scene
% Really dark -- NHTSA says down to .2 lux needs to work
% So we should calculate what that means for how we scale the skymap
skymapNode = strrep(skymapName, '.exr','_L');
roadRecipe.set('light',skymapNode, 'specscale', 0.001);

testDuration = 4; % Set test length to NHTSA 4 seconds

%% Place our "actors" and static assets
% For the cars so far, z appears to be up, y is L/R, x is towards us
% iaAssetPlacement is relative to the car
% For x and y, and relative to the ground for z

% This is our test vehicle
carSpeed = 17; % 60kph
targetDistance = testDuration * carSpeed; % tests start 4 seconds away
ourCar = actor();
ourCar.position = [0 0 0]; % e.g. uss
ourCar.rotation = [0 0 180]; % facing forward
ourCar.assetType = 'car_004';
ourCar.name = 'Shelby Cobra'; % car_004
ourCar.velocity = [carSpeed 0 0]; % moving forward at 10 m/s
ourCar.hasCamera = true; % move camera with us
ourCar.place(roadRecipe);

% Add to the actors in our scenario and set as target vehicle
targetVehicleNumber = numel(roadData.actors) + 1;
roadData.actors{end+1} = ourCar;

%% (Optionally) Add two cars coming towards us and a truck
%{
roadRecipe = iaPlaceAsset(roadRecipe, 'car_001', [40 -8 0], []);
roadRecipe = iaPlaceAsset(roadRecipe, 'car_003', [28 -12 0], [0 0 0]);

oncoming = false;
if oncoming
    roadRecipe = iaPlaceAsset(roadRecipe,'truck_001',[30 -3.2 0], [0 0 0]);
else
    roadRecipe = iaPlaceAsset(roadRecipe,'truck_001',[60 -3.2 0], [0 0 180]);
end
%}

% Add a pedestrian on the right side of our lane at the .25 mark
roadRecipe = iaPlaceAsset(roadRecipe, 'pedestrian_002', [carSpeed * testDuration 1 0], [0 0 90]);

%% Now we can assemble the scene using ISET3d methods
% Modifies roadRecipe (roadData.recipe) to include our assets 
roadData.assemble();

%% Set the recipe parameters
%  We want to render both the scene radiance and a depth map
roadRecipe.set('film render type',{'radiance','depth'});

% Set the render quality parameters, use 'quick' preset for demo
roadRecipe = iaQualitySet(roadRecipe, 'preset', sceneQuality);
roadRecipe.set('fov',45); % Field of View

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

% Get a detector
yDetect = yolov4ObjectDetector("csp-darknet53-coco");
detectionThreshhold = .95; % How confident do we need to be

% Tweak position. Not elegant at all currently
roadRecipe.lookAt.from = [roadRecipe.lookAt.from(1) + cameraOffsetF150 ...
    roadRecipe.lookAt.from(2) cameraHeightF150];
roadRecipe.lookAt.to = [0 roadRecipe.lookAt.from(2) cameraHeightF150];

startingSceneDistance = carSpeed * testDuration;

%% Render the scene, and maybe an OI (Optical Image through the lens)

ourVideo = struct('cdata',[],'colormap',[]);
frameNum = 1; % video frame counter
numFrames = 18; % for initial zero braking time to target

for testTime = [0, repelem(testLength/numFrames, numFrames+3)] % test time in seconds
    for ii = 1:numel(roadData.actors)
        % Maybe actors should be a property of @recipe?
        roadData.actors{ii}.turn(testTime);
    end
    %scene = piWRS(roadRecipe,'render flag','hdr');
    piWrite(roadRecipe);
    scene = piRender(roadRecipe); %  , 'mean luminance', 100);
    ip = piRadiance2RGB(scene,'etime',1/30,'sensor','MT9V024SensorRGB');
    pedMeters = targetDistance - (startingSceneDistance - roadRecipe.lookAt.from(1));
    caption = sprintf("Speed %2.1f at %2.1f meters",roadData.actors{targetVehicleNumber}.velocity(1), pedMeters);
    
    % Look for our pedestrian
    rgb = ipGet(ip, 'srgb');
    [bboxes,scores,labels] = detect(yDetect,rgb);

    % Cheat and assume there is only one object for now:)
    fprintf('We have %d scores\n', numel(scores));

    if numel(scores) > 0 && scores(1) > detectionThreshhold
        roadData.actors{targetVehicleNumber}.braking = true;
    end
    rgb = insertObjectAnnotation(rgb,"rectangle",bboxes,scores, 'FontSize', 16);
    if roadData.actors{targetVehicleNumber}.braking % cheat & assume we are actor 1
        rgb = insertText(rgb,[0 0],caption,'FontSize',36, 'TextColor','red');
    else
        rgb = insertText(rgb,[0 0],caption,'FontSize',36);
    end
    if pedMeters <= .1
        rgb = insertText(rgb, [.3,.3], "OOPS!", 'FontSize', 72, ....
            'TextColor', 'red');
    end
    dRGB = double(rgb); % version for movie
    ourVideo(frameNum) = im2frame(dRGB); 
    frameNum = frameNum + 1;
    %ieNewGraphWin;
    %imshow(rgb);
    % need to set the meters as we run
    %title(caption);
end

% for quick viewing use mmovie
movie(ourVideo, 10, 1);

% to save we use a Videowriter
v = VideoWriter('paebDemoHD','MPEG-4');
v.FrameRate = 1;
open(v);
writeVideo(v, ourVideo);
close(v);

