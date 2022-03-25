% RoadRunner exports a scenes with several files:
%       scene.fbx
%       (3D mesh decription file which is used for 3d rendering)
%       scene.geojson
%       (3D coordinates which describes the position of lane boundary and driving lane and terrain)
%       scene.xodr
%       (opendrive file which describes the lane function, e.g. left lane, driving lane)scenePara.rrmappth = '/Volumes/SSDZhenyi/Ford Project/PBRT_assets/road/simple3_21';
% We also saved converted PBRT file in this folder:
%       scene/scene.pbrt
sceneParameter.rrmappath = '/Volumes/SSDZhenyi/Ford Project/PBRT_assets/road/simple3_21';
sceneParameter.lane      = '';

jsonName = fullfile(iaRootPath,'presets','cloudRendering-pbrtv3-central-standard-32cpu-120m-flywheel.json');
jsonwrite(jsonName,gcpconfig);