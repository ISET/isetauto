function addToVideo(scenario, scene)

persistent yDetect;
persistent detectionThreshhold;

if isempty(yDetect)
    yDetect = yolov4ObjectDetector("csp-darknet53-coco");
    detectionThreshhold = .95; % How confident do we need to be
end

% Save out our scene list each frame, so we have it for later
save(saveName, sceneList);

% Now generate results through a sensor
useSensor = 'MT9V024SensorRGB'; % one of our automotive sensors
shutterspeed = 1/30;
ip = piRadiance2RGB(scene,'etime',shutterspeed,'sensor',useSensor);
% this if from the old iset only version
% caption = sprintf("%2.1f m/s at %2.1f m, %2.1f s",roadData.actors{roadData.targetVehicleNumber}.velocity(1), pedDistance, elapsedTime);
caption = sprintf("Car: %s, Time: %2.1f \n", scenario.egoVehicle.Name, ...
    scenario.SimulationTime);

% Look for our pedestrian
rgb = ipGet(ip, 'srgb');
[bboxes,scores,labels] = detect(yDetect,rgb);

peds = ismember(labels,'person');
foundPed = scores(peds) > detectionThreshhold;
if foundPed > 0
    % needs updating
    %roadData.actors{roadData.targetVehicleNumber}.braking = true;
end
rgb = insertObjectAnnotation(rgb,"rectangle",bboxes,labels, 'FontSize', 16);

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
scenario.ourVideo(scenario.frameNum) = im2frame(dRGB);

% plot time versus distance
%ieNewGraphWin
%plot(runData(:,1),runData(:,2))

% for quick viewing use mmovie
%movie(ourVideo, 10, 1);

% SEE if this still works, but certainly wasteful
open(scenario.v);
writeVideo(scenario.v, scenario.ourVideo);
close(scenario.v);

scenario.frameNum = scenario.frameNum + 1;

end
