function [occluded, truncated,bbox2d, segmentation, area] = piAnnotationGet(scene_mesh,index,offset)
occluded = 0;
truncated = 0;
bbox2d = [];
if offset==0
    indicator = (scene_mesh==index);
else
    indicator = ((scene_mesh<=(index+offset))&(scene_mesh>=(index-offset)));
end    
segmentation = MaskApi.encode(uint8(indicator));
area = MaskApi.area(segmentation);

xSpread = sum(indicator);
xIndices = find(xSpread > 0);
ySpread = sum(indicator,2);
yIndices = find(ySpread > 0);

if isempty(xIndices) || isempty(yIndices)
    return
end
bbox2d.xmin = min(xIndices);
bbox2d.xmax = max(xIndices);
bbox2d.ymin = min(yIndices);
bbox2d.ymax = max(yIndices);
w = size(scene_mesh,2);
h = size(scene_mesh,1);
% Occlusions
ccomp = bwconncomp(indicator);
if ccomp.NumObjects > 1
    occluded = 1;
else
    occluded = 0;
end

% Truncations
if (bbox2d.xmin == 1 || bbox2d.ymin == 1 || ...
        bbox2d.xmax == w || bbox2d.ymax == h)
    truncated = 1;
else
    truncated = 0;
end
end