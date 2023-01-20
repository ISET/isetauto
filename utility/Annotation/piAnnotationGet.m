function [occluded, truncated,bbox2d, segmentation, area] = piAnnotationGet(scene_mesh,index,offset)
% Read the annotation from the COCO data set
%
% NOTE:  Requires the coco api to be installed on your computer
%
% See also
%
%
%{
% To compile the coco code MatlabAPI, do this:

% 1. Download cocoapi from here:
  % https://github.com/cocodataset/cocoapi.git

% 2. Change into the MatlabApi directory and run

  mex('CFLAGS=\$CFLAGS -Wall -std=c99','-largeArrayDims',...
  'private/maskApiMex.c','../common/maskApi.c',...
  '-I../common/','-outdir','private');

%}

%% Check for cocoapi
if ~isa(MaskApi,'MaskApi'), error('cocoapi must be on your path'); end

%% Set up the counters
occluded  = 0;
truncated = 0;
bbox2d    = [];

% Select based on object number. Not sure how to use offset.
% We also need to skip a few lines in the file,
skipObjects = 4;
if offset==0
    indicator = (scene_mesh == (index + skipObjects));
else
    indicator = ((scene_mesh <= (index+offset)) & (scene_mesh>=(index-offset)));
end

% see if we have a visible object
if max(indicator,[],'All') > 0
    fprintf("Found a visible Object # %d \n", index);
end

% Use coco api to find the bounding box?
segmentation = MaskApi.encode(uint8(indicator));
area = MaskApi.area(segmentation);

xSpread  = sum(indicator);
xIndices = find(xSpread > 0);
ySpread  = sum(indicator,2);
yIndices = find(ySpread > 0);

if isempty(xIndices) || isempty(yIndices)
    % No indices found, return
    return;
end

% Set up the bounding box and determine size
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