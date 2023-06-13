function [image, detectionResults] = imageAndDetect(scenario, scene)

persistent yDetect;
persistent detectionThreshhold;

if isempty(yDetect)
    yDetect = yolov4ObjectDetector("csp-darknet53-coco");
    detectionThreshhold = .95; % How confident do we need to be
end

% Now generate results through a sensor
useSensor = 'MT9V024SensorRGB'; % one of our automotive sensors
shutterspeed = 1/30;

% We probably want to return the IP or something besides the
% annotated image...
ip = piRadiance2RGB(scene,'etime',shutterspeed,'sensor',useSensor);

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

% Return detection results, along with other data
detectionResults.bboxes = bboxes;
detectionResults.scores = scores;
detectionResults.labels = labels;
detectionResults.foundPed = foundPed;

% Need to track pedmeters
%if pedMeters <= .1
%    caption = strcat(caption, " ***CRASH*** ");
%end
%if roadData.actors{roadData.targetVehicleNumber}.braking % cheat & assume we are actor 1
%    rgb = insertText(rgb,[0 0],strcat(caption, " -- BRAKING"),'FontSize',48, 'TextColor','red');
%else
    image = insertText(rgb,[0 0],caption,'FontSize',36);
%end


% plot time versus distance
%ieNewGraphWin
%plot(runData(:,1),runData(:,2))

% for quick viewing use mmovie
%movie(ourVideo, 10, 1);


end
