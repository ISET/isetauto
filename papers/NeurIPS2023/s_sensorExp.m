%% sensor experiments
% This script shows how different sensor images can be created by setting
% different camera parameters.


%% load the scene
sceneDir = '/acorn/data/iset/isetauto/Ford/Flare_paper/SceneMats';
sceneNames = load(fullfile(iaRootPath, 'papers/ICCV2023','scenenames_cleanup'));
sceneNames = sceneNames.sceneNameList;
ii = 1;
thisLoad = load(fullfile(sceneDir, strrep(sceneNames{ii},'.png','.mat')));
scene    = thisLoad.scene;
[oi, ~,~]= piFlareApply(scene,'fnumber',1.7,'focal length',4.38e-3,...
    'psfsamplespacing',0.7e-6,'dirtylevel',0); % pixel4a
oi.wAngular = 34.2;
sensor = sensorCreate('IMX363');
sensor = sensorSet(sensor,'pixel size same fill factor',1.4*1e-6);

oiSize = oiGet(oi,'size');
sensor = sensorSet(sensor, 'size', oiSize);
fps = 30;
%% Acquisition policies
% Center Exposure
rect = [776   896   339   176];
eTime  = autoExposure(oi, sensor,0.90,'video','center rect',rect,'video max',1/fps);
sensor     = sensorSet(sensor,'Exp Time',eTime);


% Exposure bracketing

T1 = [1/50*1/fps 1/20*1/fps 1/5*1/fps 0.73*1/fps];  % Times
sensor     = sensorSet(sensor,'Exp Time',T1);
nExposures = length(T1);
exposurePlane = floor(nExposures/2) + 1;
sensor = sensorSet(sensor,'exposure plane',exposurePlane);

%%
sensor = sensorCompute(sensor, oi);
ip = ipCreate;
ip = ipSet(ip,'conversion method sensor','MCC Optimized');
ip = ipSet(ip,'illuminant correction method','gray world');
ip = ipSet(ip,'demosaic method','Adaptive Laplacian');
ip = ipSet(ip,'combinationMethod','hdr');
ip = ipCompute(ip,sensor);
rgb= ipGet(ip, 'srgb');
ipWindow(ip)