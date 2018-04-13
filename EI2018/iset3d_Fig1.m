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

%% Replace a single camera with a camera array.

cameraArray = nnReplaceCameraWithArray({camera},4,4,0.1,0.1);

for i=1:length(cameraArray{1})
    cameraArray{1}(i).filmResolution = camera.filmResolution/4;
    cityScene = nnPlaceCameraInIset3d(cityScene,cameraArray{1}(i));

    workDir = fullfile('/','scratch','hblasins','render_toolbox','testScene',sprintf('array-%i.pbrt',i));
    cityScene.set('outputFile',workDir);
    piWrite(cityScene);
    sc = piRender(cityScene,'renderType','radiance');
        
    ieAddObject(sc);
    sceneWindow();
end



%% Replace the pihole camera with a fish-eye lens

camera.type = 'lens';
camera.lens = fullfile(parentPath,'Parameters','LensFiles','fisheye.87deg.6.0mm.dat');

cityScene = nnPlaceCameraInIset3d(cityScene,camera);

workDir = fullfile('/','scratch','hblasins','render_toolbox','testScene','fisheye.pbrt');
cityScene.set('outputFile',workDir);
piWrite(cityScene,'overwriteresources',false);
sc = piRender(cityScene,'renderType','radiance');
        
ieAddObject(sc);
oiWindow();









%{




%% Camera definitions
%  Here we define two cameras
%  (a) A pinhole camera with a field of view matched to that of a 50mm
%  Double Gaussian lens/
%  (b) A camera with a realistic model of a 6mm fish-eye lens

%  Camera positions are defined relative to a reference object (i.e. the
%  lookAtObject.

cameras = nnGenCameras('type',{'pinhole','lens'},...
    'lens',{'dgauss.22deg.50.0mm','fisheye.87deg.6.0mm'},...
    'mode',{'radiance'},...
    'diffraction',{'false',},...
    'chromaticAberration',{'false'},...
    'distance',10,...
    'filmDiagonal',30,... 
    'lookAtObject',2,...
    'PTR',{[0, 0, 0]},...
    'orientation',0,...
    'fNumber',2.8,...
    'pixelSamples',32,...
    'height',-1.5,...
    'upDir',-[0 0 1]);


%% Choose renderer options.
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.recipeName = 'CityScene'; % Name of the render
hints.renderer = 'PBRT'; % We're only using PBRT right now
hints.copyResources = 1;
hints.batchRenderStrategy = RtbAssimpStrategy(hints);

% Change the docker container
hints.batchRenderStrategy.renderer.pbrt.dockerImage = 'vistalab/pbrt-v2-spectral';
hints.batchRenderStrategy.remodelPerConditionAfterFunction = @MexximpRemodellerMultipleObjV2;
hints.batchRenderStrategy.converter.remodelAfterMappingsFunction = @PBRTRemodellerV2;
hints.batchRenderStrategy.converter.rewriteMeshData = false;

resourceFolder = rtbWorkingFolder('folderName','resources',...
    'rendererSpecific',false,...
    'hints',hints);

% Copy resources
lensTypes = unique({cameras(:).lens});
lensFiles = fullfile(lensDir,strcat(lensTypes,'.dat'));
for i=1:length(lensFiles)
    copyfile(lensFiles{i},resourceFolder);
end


% Copy sky map
skyFile = fullfile(assetDir,'City','*.exr');
copyfile(skyFile,resourceFolder);


%% Assemble the scene
%  We read in a model of a city, and three different models of cars, that
%  are placed along the 'main' road. 

scene = mexximpCleanImport(assets.city(1).modelPath,...
    'options','-gamma 0.45',...
    'flipUVs',true,...
    'makeLeftHanded',true,...
    'toReplace',{'jpg','png','tga'},...
    'targetFormat','exr',...
    'workingFolder',resourceFolder);

% Define the positions and arrangements of cars
objects(1).class = 'car';
objects(1).id = 3;
objects(1).modelPath = assets.car(objects(1).id).modelPath;
objects(1).position = [1.5, -30, 0];
objects(1).orientation = 90;
objects(1).prefix = 'car_inst_1';

objects(2).class = 'car';
objects(2).id = 1;
objects(2).modelPath = assets.car(objects(2).id).modelPath;
objects(2).position = [0, 20, 0];
objects(2).orientation = 90;
objects(2).prefix = 'car_inst_2';

objects(3).class = 'car';
objects(3).id = 2;
objects(3).modelPath = assets.car(objects(3).id).modelPath;
objects(3).position = [-0.5, 40, 0];
objects(3).orientation = 90;
objects(3).prefix = 'car_inst_3';

% Add cars into the city scene. All car models are initially placed at the
% origin. They are moved to their desired locations inside remodeller
% functions.
for i=1:length(objects)
    
    carScene = mexximpCleanImport(objects(i).modelPath,...
        'options','-gamma 0.45',...
        'toReplace',{'jpg','png','tga'},...
        'targetFormat','exr',...
        'flipUVs',true,...
        'makeLeftHanded',true,...
        'workingFolder',resourceFolder);
    
    scene = mexximpCombineScenes(scene,carScene,...
        'insertTransform',mexximpTranslate([0 0 0]),...
        'cleanupTransform',mexximpTranslate([0 0 0]),...
        'insertPrefix',objects(i).prefix);
end

% We placed objects in the scene, now we need to convert relative camera
% placement into absolute placement in the scene. We can also now apply the
% desired amount of defocus. 
objectArrangements = {objects};
placedCameras = nnPlaceCameras(cameras,objectArrangements);

%% Create a list of render conditions
conditionsFile = fullfile(resourceFolder,'Conditions.txt');
names = cat(1,'imageName','objPosFile',fieldnames(placedCameras{1}));
values = cell(1,length(names));

cntr = 1;
for m=1:length(objectArrangements)
    objectArrangementFile = fullfile(resourceFolder,sprintf('Arrangement_%i.json',m));
    savejson('',objectArrangements{m},objectArrangementFile);
    
    currentCameras = placedCameras{m};
    for c=1:length(placedCameras{m})
        
        fName = sprintf('%03i_%s',cntr,currentCameras(c).description);
        
        values(cntr,1) = {fName};
        values(cntr,2) = {objectArrangementFile};
        for i=3:(length(names))
            values(cntr,i) = {currentCameras(c).(names{i})};
        end
        
        cntr = cntr + 1;
    end
end

rtbWriteConditionsFile(conditionsFile,names,values);

%% Render scenes

nativeSceneFiles = rtbMakeSceneFiles(scene, 'hints', hints,...
    'conditionsFile',conditionsFile);

rtbBatchRender(nativeSceneFiles, 'hints', hints);

%% Build oi

sceneMetadata = assembleSceneFiles(hints,names,values);

%}
%{
for i=1:length(sceneMetadata)
    
    radianceData = piReadDAT(sceneMetadata(i).radiance, 'maxPlanes', 31);
    
    oiParams.lensType = values{i,strcmp(names,'lens')};
    oiParams.filmDistance = values{i,strcmp(names,'filmDistance')};
    oiParams.filmDiag = values{i,strcmp(names,'filmDiagonal')};
    
    [~, label] = fileparts(sceneMetadata(i).radiance);
        
    oi(i) = buildOi(radianceData, [], oiParams);
    oi(i) = oiSet(oi(i),'name',label);
end
    
% Simulate RGB sensor
sensor = sensorCreate('bayer (rggb)');
sensor = sensorSet(sensor,'size',[hints.imageHeight hints.imageWidth]);
sensor = sensorSet(sensor,'pixel widthandheight',[oiGet(oi(1),'hres'), oiGet(oi(1),'wres')]);

for i=1:length(sceneMetadata)
    sensor = sensorCompute(sensor,oi(i));
    
    ip = ipCompute(ipCreate,sensor);
    
    ieAddObject(oi(i));
    ieAddObject(sensor);
    ieAddObject(ip);
    
end

% Simulate RCCC automotive sensor
sensor = sensorCreate('mt9v024',[],'rccc');
sensor = sensorSet(sensor,'size',[hints.imageHeight hints.imageWidth]);
sensor = sensorSet(sensor,'pixel widthandheight',[oiGet(oi(1),'hres'), oiGet(oi(1),'wres')]);

for i=1:length(sceneMetadata)
    sensor = sensorCompute(sensor,oi(i));
    ieAddObject(sensor);
end

oiWindow;
sensorWindow;
ipWindow;
%}