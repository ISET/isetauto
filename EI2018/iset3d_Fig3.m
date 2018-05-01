% This script produces scene images that are used in Fig. 3, specifically
% images of a scene from different view points and orientations
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

workDir = fullfile('/','scratch','hblasins','render_toolbox','testScene','scene1.pbrt');
cityScene.set('outputFile',workDir);
piWrite(cityScene,'overwriteresources',true);
sc = piRender(cityScene,'renderType','radiance');
        
ieAddObject(sc);
sceneWindow();
imwrite(sceneGet(sc,'rgb image'),'scene1.png');

%% Scene 2

camera.position = [0 40 -1.5];
camera.PTR = [-4 -4 -4];
cityScene = nnPlaceCameraInIset3d(cityScene,camera);

workDir = fullfile('/','scratch','hblasins','render_toolbox','testScene','scene2.pbrt');
cityScene.set('outputFile',workDir);
piWrite(cityScene);
sc = piRender(cityScene,'renderType','radiance');
        
ieAddObject(sc);
sceneWindow();
imwrite(sceneGet(sc,'rgb image'),'scene2.png');


%% Scene 3

camera.position = [0 0 -1.5];
camera.PTR = [0 0 0];
camera.lookAt = [0 50 -1.5];
cityScene = nnPlaceCameraInIset3d(cityScene,camera);

workDir = fullfile('/','scratch','hblasins','render_toolbox','testScene','scene3.pbrt');
cityScene.set('outputFile',workDir);
piWrite(cityScene);
sc = piRender(cityScene,'renderType','radiance');
        
ieAddObject(sc);
sceneWindow();
imwrite(sceneGet(sc,'rgb image'),'scene3.png');


%% Scene 4

camera.position = [10 0 -1.5];
camera.PTR = [2 0 -2];
camera.lookAt = [0 20 -1.5];
cityScene = nnPlaceCameraInIset3d(cityScene,camera);

workDir = fullfile('/','scratch','hblasins','render_toolbox','testScene','scene4.pbrt');
cityScene.set('outputFile',workDir);
piWrite(cityScene);
sc = piRender(cityScene,'renderType','radiance');
        
ieAddObject(sc);
sceneWindow();
imwrite(sceneGet(sc,'rgb image'),'scene4.png');


%% Scene 5

camera.position = [5 0 -1.5];
camera.PTR = [2 5 -2];
camera.lookAt = [0 -40 -1.5];
cityScene = nnPlaceCameraInIset3d(cityScene,camera);

workDir = fullfile('/','scratch','hblasins','render_toolbox','testScene','scene5.pbrt');
cityScene.set('outputFile',workDir);
piWrite(cityScene);
sc = piRender(cityScene,'renderType','radiance');
        
ieAddObject(sc);
sceneWindow();
imwrite(sceneGet(sc,'rgb image'),'scene5.png');

%% Scene 6

camera.position = [-5 -5 -1.5];
camera.PTR = [2 5 -2];
camera.lookAt = [0 -40 -1.5];
cityScene = nnPlaceCameraInIset3d(cityScene,camera);

workDir = fullfile('/','scratch','hblasins','render_toolbox','testScene','scene6.pbrt');
cityScene.set('outputFile',workDir);
piWrite(cityScene);
sc = piRender(cityScene,'renderType','radiance');
        
ieAddObject(sc);
sceneWindow();
imwrite(sceneGet(sc,'rgb image'),'scene6.png');

