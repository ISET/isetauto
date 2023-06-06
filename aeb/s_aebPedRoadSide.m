%% Illustrate and animate NHTSA night time PAEB Test
% Stationary pedestrian on right side of road
%
% Dependencies
%   ISET3d, ISETAuto, ISETonline, and ISETCam
%
% D. Cardinal, Stanford University, 2023

% NOTE: Assumes only one recognizable object in scene (ped)
%       at which point it starts braking. Need to parameterize

%% Initialize ISET, Docker, and general parameters
ieInit; if ~piDockerExists, piDockerConfig; end

% Adjust these depening on desired video output
sceneQuality = 'quick'; % quick or HD or paper for video quality
numFrames = 3; % for initial zero braking time to target
carSpeed = 17;
testDuration = 4; % NHTSA standard

% Load the NHTSA test preset
testScenario = 'pedRoadsideRight';
roadData = paebNHTSA(testScenario, 'lighting','nighttime', ...
    'carspeed', carSpeed, 'testdurationinitial', testDuration);

%% Place any additional "actors" and static assets
% Optional

%% Assemble the scene for our scenario
% the roadData object comes with a base ISET3d recipe for rendering
roadData.assemble();
roadRecipe = roadData.recipe; % short-hand for convenience

%% Set the recipe parameters
%  We want to render both the scene radiance and a depth map
roadRecipe.set('film render type',{'radiance','depth'});

% Set the render quality parameters, use 'quick' preset for demo
roadRecipe = iaQualitySet(roadRecipe, 'preset', sceneQuality);
roadRecipe.set('fov',45); % Field of View

% Put the camera on the test car
camera_type = 'grille'; % Or Grille
switch camera_type
    case 'front' % which means behind the mirror -- IPMA in Ford speak
        cameraHeight = 1.8; % Mirror meters above ground
        cameraOffset = .9; % meters offset towards rear of truck
    case 'grille'
        cameraHeight = .9; % Grille
        cameraOffset = -1.9; % meters offset towards rear of truck
end

% Tweak position. Not elegant at all currently
roadRecipe.lookAt.from = [roadRecipe.lookAt.from(1) + cameraOffset ...
    roadRecipe.lookAt.from(2) cameraHeight];
roadRecipe.lookAt.to = [0 roadRecipe.lookAt.from(2) cameraHeight];

startingSceneDistance = carSpeed * testDuration; 

%% Render the scene and turn it into camera images & a video

ourVideo = struct('cdata',[],'colormap',[]);
frameNum = 1; % video frame counter
bufferFrames = 2; % additional frames to allow for slowing
shutterspeed = 1/30; % for now assume it is synced with 30fps
useSensor = 'MT9V024SensorRGB'; % one of our automotive sensors

% Get an object detector
yDetect = yolov4ObjectDetector("csp-darknet53-coco");
detectionThreshhold = .95; % How confident do we need to be
elapsedTime = 0;

%% Generate video frames over time
for testTime = [0, repelem(testLength/numFrames, numFrames+bufferFrames)]
    elapsedTime = elapsedTime + testTime;
    % Move this to a .turn method for roadScenario soon
    for ii = 1:numel(roadData.actors)
        roadData.actors{ii}.turn(testTime);
    end

    piWrite(roadRecipe);
    scene = piRender(roadRecipe);
    ip = piRadiance2RGB(scene,'etime',shutterspeed,'sensor',useSensor);
    pedMeters = targetDistance - (startingSceneDistance - roadRecipe.lookAt.from(1));
    caption = sprintf("%2.1f m/s at %2.1f m, %2.1 s",roadData.actors{roadData.targetVehicleNumber}.velocity(1), pedMeters);
    
    % Look for our pedestrian
    rgb = ipGet(ip, 'srgb');
    [bboxes,scores,labels] = detect(yDetect,rgb);

    % Cheat and assume there is only one object for now:)
    fprintf('We have %d scores\n', numel(scores));

    if numel(scores) > 0 && scores(1) > detectionThreshhold
        roadData.actors{roadData.targetVehicleNumber}.braking = true;
    end
    rgb = insertObjectAnnotation(rgb,"rectangle",bboxes,scores, 'FontSize', 16);
    if pedMeters <= .1
        caption = strcat(caption, " ***CRASH*** ");
    end
    if roadData.actors{roadData.targetVehicleNumber}.braking % cheat & assume we are actor 1
        rgb = insertText(rgb,[0 0],strcat(caption, " -- BRAKING"),'FontSize',36, 'TextColor','red');
    else
        rgb = insertText(rgb,[0 0],caption,'FontSize',36);
    end
    dRGB = double(rgb); % version for movie
    ourVideo(frameNum) = im2frame(dRGB); 
    frameNum = frameNum + 1;
end

% for quick viewing use mmovie
movie(ourVideo, 10, 1);

% to save we use a Videowriter
v = VideoWriter(strcat(testScenario, "-", sceneQuality),'MPEG-4');
v.FrameRate = 1;
open(v);
writeVideo(v, ourVideo);
close(v);

