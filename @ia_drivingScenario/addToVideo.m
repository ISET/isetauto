function addToVideo(scenario, scene)

persistent yDetect;
persistent detectionThreshhold;
persistent v;
persistent ourVideo;

if isempty(yDetect)
    yDetect = yolov4ObjectDetector("csp-darknet53-coco");
    detectionThreshhold = .95; % How confident do we need to be

    % to save we use a Videowriter
    % Need to parameterize these
    testScenario = 'LabDemo';
    sceneQuality = 'quick';
    v = VideoWriter(strcat(testScenario, "-", sceneQuality),'MPEG-4');
    v.FrameRate = 1;
    % video structure with frames for creating clips
    ourVideo = struct('cdata',[],'colormap',[]);
end

useSensor = 'MT9V024SensorRGB'; % one of our automotive sensors
shutterspeed = 1/30;
ip = piRadiance2RGB(scene,'etime',shutterspeed,'sensor',useSensor);
% this if from the old iset only version
% caption = sprintf("%2.1f m/s at %2.1f m, %2.1f s",roadData.actors{roadData.targetVehicleNumber}.velocity(1), pedDistance, elapsedTime);
caption = "VIDEO";

% Look for our pedestrian
rgb = ipGet(ip, 'srgb');
[bboxes,scores,labels] = detect(yDetect,rgb);

peds = ismember(labels,'person');
foundPed = scores(peds) > detectionThreshhold;
if foundPed > 0
    % needs updating
    %roadData.actors{roadData.targetVehicleNumber}.braking = true;
end
rgb = insertObjectAnnotation(rgb,"rectangle",bboxes,scores, 'FontSize', 16);

% Need to track pedmeters
%if pedMeters <= .1
%    caption = strcat(caption, " ***CRASH*** ");
%end
%if roadData.actors{roadData.targetVehicleNumber}.braking % cheat & assume we are actor 1
%    rgb = insertText(rgb,[0 0],strcat(caption, " -- BRAKING"),'FontSize',48, 'TextColor','red');
%else
    rgb = insertText(rgb,[0 0],caption,'FontSize',36);
%end

dRGB = double(rgb); % version for movie
ourVideo(scenario.frameNum) = im2frame(dRGB);

% plot time versus distance
%ieNewGraphWin
%plot(runData(:,1),runData(:,2))

% for quick viewing use mmovie
%movie(ourVideo, 10, 1);

% SEE if this still works, but certainly wasteful
open(v);
writeVideo(v, ourVideo);
close(v);

scenario.frameNum = scenario.frameNum + 1;

end
