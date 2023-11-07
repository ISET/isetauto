%% scene calibration
skymap = piEXR2ISET('/acorn/data/iset/isetauto/Ford/SceneEXRs/1114093606_skymap.exr');
headlight = piEXR2ISET('/acorn/data/iset/isetauto/Ford/SceneEXRs/1114093606_headlights.exr','meanluminance',0);
streetlight = piEXR2ISET('/acorn/data/iset/isetauto/Ford/SceneEXRs/1114093606_streetlights.exr','meanluminance',0);
otherlight = piEXR2ISET('/acorn/data/iset/isetauto/Ford/SceneEXRs/1114093606_otherlights.exr','meanluminance',0);
sceneList{1} = skymap;
sceneList{2} = headlight;
sceneList{3} = streetlight;
sceneList{4} = otherlight;
wgts = [0.05/100, 0.01, 0.005*2,0.05];
scene = sceneAdd(sceneList,wgts,'add');
scene = piAIdenoise(scene);
% sceneWindow(scene);

% scene = sceneAdjustLuminance(scene, 100);

sceneSampleSize = sceneGet(scene,'sample size','microns');

[oi, pupil_mask,psf]= piFlareApply(scene,'fnumber',1.7,'focal length',4.38e-3,'psfsamplespacing',0.7e-6,'dirtylevel',0.1);

oi.wAngular = 34.2;

pixelSize = oiGet(oi,'width spatial resolution','microns');
%%
sensor = sensorCreate('IMX363', [], 'isospeed', 437);
sensor = sensorSet(sensor,'black level',64);

sensor = sensorSet(sensor,'pixel size same fill factor',1.4*1e-6);
% 0.0143
% 0.0405
% 0.1146
% 0.3242
sensor = sensorSet(sensor, 'exposure time',0.005);
oiSize = oiGet(oi,'size');
sensor = sensorSet(sensor, 'size', oiSize);

sensor = sensorCompute(sensor, oi);

% sensorWindow(sensor);
%
ip = ipCreate;

% Choose the likely set of signals the sensor will encounter
ip = ipSet(ip,'conversion method sensor','MCC Optimized');
ip = ipSet(ip,'illuminant correction method','gray world');

% demosaics = [{'Adaptive Laplacian'},{'Bilinear'}];
ip = ipSet(ip,'demosaic method','Adaptive Laplacian'); 
ip = ipCompute(ip, sensor);
ip = ipCompute(ip, sensor);
rgb = ipGet(ip,'srgb');
figure;imshow(rgb); axis off


