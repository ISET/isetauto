function [objects] = getBndBox(labelImage, instanceImage, labelMap, sceneMetadata)

% This function generates object annotations from a labelImage where pixels
% representing objects from the same class have the same numerical value,
% and an instanceImage where objects belonging to the same instance have
% the same numerical value. The label map is a structure that maps
% numerical values from label image into different semantic categories.
% Scene metadata is necessary to load the .json file specifying object
% positions in the scene and the camera position/orientation etc.
%
% Copyright, Henryk Blasinski 2018

objects = {};

h = size(labelImage,1);
w = size(labelImage,2);

workDir = '';
if isfield(sceneMetadata,'workDir')
    workDir = sceneMetadata(1).workDir;
end


modelPlacement = loadjson(fullfile(workDir,sceneMetadata.objPosFile));
if iscell(modelPlacement) == false
    modelPlacement = {modelPlacement};
end

modelPrefixes = cell(1,length(modelPlacement));
for i=1:length(modelPlacement)
    modelPrefixes{i} = modelPlacement{i}.prefix;
end

camPos = sceneMetadata.position;

% Get instance id's, we assume that 0 is the background class,
% which we ignore.
instanceIDs = unique(instanceImage);
instanceIDs = instanceIDs(instanceIDs > 0);

classIDs = unique(labelImage);
classIDs = classIDs(classIDs > 0);

objectId = 1;
for j=1:length(classIDs);
for i=1:length(instanceIDs)
   indicator = (instanceImage == instanceIDs(i)) & (labelImage == classIDs(j));
   if sum(indicator(:)) == 0,
       continue;
   end
   
   xSpread = sum(indicator);
   xIndices = find(xSpread > 0);
   
   ySpread = sum(indicator,2);
   yIndices = find(ySpread > 0);
   
   classId = classIDs(j);
   
   cond = [labelMap(:).id] == classId;
   
   if sum(cond) == 0
       % We're not interested in labeling this particular object.
       continue; 
   end
   
   instancePrefix = sprintf('%s_inst_%i_',labelMap(cond).name,instanceIDs(i));
   
   % Find a model with a given prefix
   instanceID = strcmp(modelPrefixes,instancePrefix);
   
   objPos = modelPlacement{instanceID}.position;
   cam2ObjDist =  sqrt(sum((camPos(:) - objPos(:)).^2));
   
   objects{objectId}.name = labelMap(cond).name;
   objects{objectId}.distance = cam2ObjDist;
   objects{objectId}.bndbox.xmin = min(xIndices);
   objects{objectId}.bndbox.xmax = max(xIndices);
   objects{objectId}.bndbox.ymin = min(yIndices);
   objects{objectId}.bndbox.ymax = max(yIndices);
   objects{objectId}.labelColor = labelMap(cond).color;
   
   % Occlusions   
   ccomp = bwconncomp(indicator);
   if ccomp.NumObjects > 1
       occluded = 1;
   else
       occluded = 0;
   end
   
   % Truncations
   if (objects{objectId}.bndbox.xmin == 0 || objects{objectId}.bndbox.ymin == 0 || ...
           objects{objectId}.bndbox.xmax == w || objects{objectId}.bndbox.ymax == h)
       truncated = 1;
   else
       truncated = 0;
   end
   
   objects{objectId}.difficult = 0;
   objects{objectId}.occluded = occluded;
   objects{objectId}.pose = 'Unspecified';
   objects{objectId}.truncated = truncated;
   
   objectId = objectId + 1; 
end




end