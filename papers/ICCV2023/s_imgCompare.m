% check about whether the color is okay

sceneDir = '/acorn/data/iset/isetauto/Ford/Flare_paper/SceneMats_003';
sceneNames = load(fullfile(iaRootPath, 'papers/ICCV2023','scenenames_cleanup'));
sceneNames = sceneNames.sceneNamesList;

imgID = 5;
% thisLoad = load(fullfile(sceneDir, strrep(sceneNames{imgID},'.png','.mat')));
thisLoad = load(fullfile(sceneDir, '1112162206.mat'));
scene    = thisLoad.scene;
meanluminance = sceneGet(scene, 'mean luminance');
scene = oiAdjustIlluminance(scene, meanluminance*10);

%% setting parameters
parameters.fnumber = 1.7;
parameters.focallength = 4.38e-3;
parameters.nsides = 20;

parameters.pixelsize = 1.4e-6;
parameters.exposuretime = 1/60;

% ISET Flare
tic
[oi,sensor,ip] = ISETFlareGen(scene,parameters);
ipWindow(ip);

% ISET Ground Truth with same oi, sensor, ip
[~,~,ip_gt] = GroundTruthGen(scene,oi,sensor,ip,parameters,'pinhole');
ipWindow(ip_gt);
imwrite()

toc
% Flare 7K with same scene, sensor, ip
