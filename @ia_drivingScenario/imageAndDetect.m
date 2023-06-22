function [image] = imageAndDetect(scenario, scene)
% image our scene through a camera of our choosing,
% and then run an object detector on it
% (YOLOv4 by default, but could be any compatible detector)

% We only want to fire up the detector once if we can
% as it takes some time to initialize
persistent yDetect; % Our (YOLO) detector
persistent detectionThreshhold; % for declaring a match

if isempty(yDetect)
    yDetect = yolov4ObjectDetector("csp-darknet53-coco");
    detectionThreshhold = scenario.predictionThreshold; % How confident do we need to be
end

% Now generate results through a sensor
useSensor = scenario.sensorModel;
shutterspeed = 1/30; % typical of auto video cameras

% We probably want to return the IP or something besides the
% annotated image...
% I think we need to do this slightly differently...
ip = piRadiance2RGB(scene,'etime',shutterspeed,'sensor',useSensor);

caption = sprintf("Car: %s, Time: %2.1f \n", scenario.egoVehicle.Name, ...
    scenario.SimulationTime);

% Detect object classes that our detector is trained on
rgb = ipGet(ip, 'srgb');
[bboxes,scores,labels] = detect(yDetect,rgb);

% See if we have found a person (e.g. pedestrian)
% NOTE: We don't (yet) distinguish between multiple pedestrians
peds = ismember(labels,'person'); % Any person?

if ~exist('foundPed', 'var') || max(scores(peds)) > detectionThreshhold 
    foundPed = max(scores(peds)) > detectionThreshhold; % Are we confident?
else
    foundPed = 0;
end

if foundPed > 0
    cprintf('*Yellow', 'Identified Pedestrian...\n');
    scenario.roadData.actorsIA{scenario.roadData.targetVehicleNumber}.braking = true;
end

% Should have both label & score here:
rgb = insertObjectAnnotation(rgb,"rectangle",bboxes,labels, 'FontSize', 16);

% Return detection results, along with other data
scenario.detectionResults.bboxes = bboxes;
scenario.detectionResults.scores = scores;
scenario.detectionResults.labels = labels;

scenario.detectionResults.foundPed = foundPed;

% Need to track pedmeters
%if pedMeters <= .1
%    caption = strcat(caption, " ***CRASH*** ");
%end
if scenario.roadData.actorsIA{scenario.roadData.targetVehicleNumber}.braking % cheat & assume we are actor 1
    image = insertText(rgb,[0 0],strcat(caption, " -- BRAKING"),'FontSize',48, 'TextColor','red');
else
    image = insertText(rgb,[0 0],caption,'FontSize',36);
end


% plot time versus distance
%ieNewGraphWin
%plot(runData(:,1),runData(:,2))

% for quick viewing use mmovie
%movie(ourVideo, 10, 1);


end
