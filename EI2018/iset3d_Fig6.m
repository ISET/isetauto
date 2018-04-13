% This script produces a car scene and simulates a capture with varying
% degrees of under and over exposure.
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
camera.lookAt = [0 0 -1.5];
camera.upDir = [0 0 -1];
camera.PTR = [0 0 0];
camera.objectDistance = 10;
camera.filmDiagonal = 30;
camera.pixelSamples = 32;
camera.filmResolution = [640 480];


cityScene = nnPlaceCameraInIset3d(cityScene,camera);

workDir = fullfile('/','scratch','hblasins','render_toolbox','testScene','pinhole.pbrt');
cityScene.set('outputFile',workDir);
piWrite(cityScene,'overwriteresources',true);
sc = piRender(cityScene,'renderType','radiance');
        

%% Simulate camera capture

sc = sceneAdjustLuminance(sc,100);

ieAddObject(sc);
sceneWindow();

oi = oiCompute(oiCreate,sc);

sensor = sensorCreate('bayer (rggb)');
sensor = sensorSet(sensor,'size',[camera.filmResolution(2) camera.filmResolution(1)]);
sensor = sensorSet(sensor,'pixel widthandheight',[oiGet(oi(1),'hres'), oiGet(oi(1),'wres')]);

% Compute the base EV0 exposure, and render images with EV bias.
expTime = autoExposure(oi,sensor,0.4,'mean');
for ev=-4:2:4
            
   intTime = expTime*2^(ev);
   
   sensor = sensorSet(sensor,'exposure time',intTime);
   sensor = sensorSet(sensor,'quantizationmethod','8 bit');
   sensor = sensorCompute(sensor,oi);
   
   ip = ipCreate();
   ip = ipSet(ip,'conversion method sensor','mcc optimized');
   ip = ipSet(ip,'correction method illuminant','gray world');
   ip = ipCompute(ip,sensor);
    
    lrgb = ipGet(ip,'result');
    lrgb = ieClip(lrgb,0,1);                
    img = lrgb2srgb(lrgb);
   
    figure; imshow(img);
    imwrite(img,sprintf('ev%i.png',ev));
end




