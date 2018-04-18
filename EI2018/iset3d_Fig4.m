% This script produces scene images that are used in Fig. 4, specifically
% images of a scene at different stages of the image processing pipeline.
%
% Copyright, Henryk Blasinski 2018

close all;
clear all;
clc;

ieInit;

[rootPath, parentPath] = nnGenRootPath();


sceneFile = fullfile('/','scratch','hblasins','render_toolbox','CityScene','CityScene.pbrt');
cityScene = piRead(sceneFile);

camera.type = 'pinhole';
camera.lens = fullfile(parentPath,'Parameters','LensFiles','dgauss.22deg.50.0mm.dat'); 
camera.diffraction = 'false';
camera.chromaticAberration = 'false';
camera.microlens= [0 0];
camera.position = [0 30 -1.5];
camera.lookAt = [0 50 -1.5];
camera.upDir = [0 0 -1];
camera.PTR = [0 0 0];
camera.objectDistance = 10;
camera.filmDiagonal = 30;
camera.pixelSamples = 128;
camera.filmResolution = [640 480];

cityScene = nnPlaceCameraInIset3d(cityScene,camera);

workDir = fullfile('/','scratch','hblasins','render_toolbox','testScene','scene1.pbrt');
cityScene.set('outputFile',workDir);
piWrite(cityScene,'overwriteresources',true);
sc = piRender(cityScene,'renderType','radiance');
sc = sceneAdjustLuminance(sc,100);

ieAddObject(sc);
sceneWindow();

img = sceneGet(sc,'rgb image');
imwrite(img,sprintf('irradiance.png'));
figure; imshow(img);

oi = oiCompute(oiCreate,sc);

sensor = sensorCreate('bayer (rggb)');
sensor = sensorSet(sensor,'size',[camera.filmResolution(2) camera.filmResolution(1)]);
sensor = sensorSet(sensor,'pixel widthandheight',[oiGet(oi(1),'hres'), oiGet(oi(1),'wres')]);
intTime = autoExposure(oi,sensor,0.4,'mean');
sensor = sensorSet(sensor,'exposure time',intTime);
sensor = sensorSet(sensor,'quantizationmethod','8 bit');
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor);

img = sensorData2Image(sensor,'volts');
imwrite(img,sprintf('raw.png'));
figure; imshow(img);


ip = ipCreate();
ip = ipSet(ip,'conversion method sensor','mcc optimized');
ip = ipSet(ip,'correction method illuminant','gray world');
ip = ipCompute(ip,sensor);

img = uint8(ipGet(ip,'sensor channels'));
imwrite(img,sprintf('linear.png'));
figure; imshow(img);

img = ipGet(ip,'data srgb');
imwrite(img,sprintf('srgb.png'));
figure; imshow(img);



