% This script produces scene images that are used in Fig. 1, specifically
% images of a scene as seen through a pihole camera, a camera with a
% realistic model of a fisheye lens, and a camera with an RCCC sensor.
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
camera.pixelSamples = 128;
camera.filmResolution = [640 480];


cityScene = nnPlaceCameraInIset3d(cityScene,camera);

workDir = fullfile('/','scratch','hblasins','render_toolbox','testScene','pinhole.pbrt');
cityScene.set('outputFile',workDir);
piWrite(cityScene,'overwriteresources',true);
sc = piRender(cityScene,'renderType','radiance');
        
ieAddObject(sc);
sceneWindow();

img = sceneGet(sc,'rgb image');
imwrite(img,sprintf('pinhole.png'));
figure; imshow(img);

%% Simulate an RCCC sensor

sc = sceneAdjustLuminance(sc,100);
oi = oiCompute(oiCreate,sc);

% Simulate RCCC automotive sensor
sensor = sensorCreate('mt9v024',[],'rccc');
sensor = sensorSet(sensor,'size',[camera.filmResolution(2) camera.filmResolution(1)]);
sensor = sensorSet(sensor,'pixel widthandheight',[oiGet(oi(1),'hres'), oiGet(oi(1),'wres')]);
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor);

img = sensorData2Image(sensor,'volts');
imwrite(img,sprintf('rccc.png'));
figure; imshow(img);


%% Replace a single camera with a camera array.

cameraArray = nnReplaceCameraWithArray({camera},2,2,1,1);

for i=1:length(cameraArray{1})
    cameraArray{1}(i).filmResolution = camera.filmResolution/2;
    cityScene = nnPlaceCameraInIset3d(cityScene,cameraArray{1}(i));

    workDir = fullfile('/','scratch','hblasins','render_toolbox','testScene',sprintf('array-%i.pbrt',i));
    cityScene.set('outputFile',workDir);
    piWrite(cityScene);
    sc = piRender(cityScene,'renderType','radiance');
        
    ieAddObject(sc);
    sceneWindow();
    
    img = sceneGet(sc,'rgb image');
    imwrite(img,sprintf('array-%i.png',i));
    figure; imshow(img);
end



%% Replace the pihole camera with a fish-eye lens

camera.pixelSamples = 1024;
camera.type = 'lens';
camera.lens = fullfile(parentPath,'Parameters','LensFiles','fisheye.87deg.6.0mm.dat');

cityScene = nnPlaceCameraInIset3d(cityScene,camera);

workDir = fullfile('/','scratch','hblasins','render_toolbox','testScene','fisheye.pbrt');
cityScene.set('outputFile',workDir);
piWrite(cityScene,'overwriteresources',false);
sc = piRender(cityScene,'renderType','radiance');
        
ieAddObject(sc);
oiWindow();

img = oiGet(sc,'rgb image');
imwrite(img,sprintf('fisheye.png'));
figure; imshow(img);




