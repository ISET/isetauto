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

% Load the test preset
testScenario = 'pedRoadsideRight';
roadData = paebNHTSA(testScenario, 'lighting','nighttime');


%% Place any additional "actors" and static assets

%% Now we can assemble the scene using ISET3d methods
% the roadData object comes with a base ISET3d recipe for rendering
roadData.assemble();
roadRecipe = roadData.recipe; % short-hand for convenience

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
    caption = sprintf("Speed %2.1f at %2.1f meters",roadData.actors{roadData.targetVehicleNumber}.velocity(1), pedMeters);
    
    % Look for our pedestrian
    rgb = ipGet(ip, 'srgb');
    [bboxes,scores,labels] = detect(yDetect,rgb);

    % Cheat and assume there is only one object for now:)
    fprintf('We have %d scores\n', numel(scores));

    if numel(scores) > 0 && scores(1) > detectionThreshhold
        roadData.actors{roadData.targetVehicleNumber}.braking = true;
    end
    rgb = insertObjectAnnotation(rgb,"rectangle",bboxes,scores, 'FontSize', 16);
    if roadData.actors{roadData.targetVehicleNumber}.braking % cheat & assume we are actor 1
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

