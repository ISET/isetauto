%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

%% Scene description

% Henryk Blasinski
close all;
clear all;
clc;

ieInit;
constants;

%% Simulation parameters

cameras = nnGenCameras('type',{'pinhole'},...
    'mode',{'radiance'},...
    'diffraction',{'false'},...
    'chromaticAberration',{'false'},...
    'distance',[20],...
    'filmDiagonal',2.42,... %3um pixel
    'lookAtObject',1,...
    'PTR',{[0, 0, 0]},...
    'orientation',0,...
    'pixelSamples',32);

%% Choose renderer options.
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.recipeName = 'Fog'; % Name of the render
hints.renderer = 'PBRT'; % We're only using PBRT right now
hints.copyResources = 1;
hints.batchRenderStrategy = RtbAssimpStrategy(hints);

% Change the docker container
hints.batchRenderStrategy.renderer.pbrt.dockerImage = 'vistalab/pbrt-v2-spectral';
hints.batchRenderStrategy.remodelPerConditionAfterFunction = @MexximpRemodellerMultipleObjV2;
hints.batchRenderStrategy.converter.remodelAfterMappingsFunction = @PBRTRemodellerFog;
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

% Generate fog properties
% Uniform absorption
wave = 400:10:700;
abs = 0.01*ones(length(wave),1);
rtbWriteSpectrumFile(wave,abs,fullfile(resourceFolder,'abs.spd'));

% Uniform Volume Scattering Function
vsf = ones(180,length(wave));
vsf(1,:) = 1;
vsf = 2*vsf/sum(vsf(1,:))/4/pi;
angles = 0:179;
scat = sum(diag(sind(angles))*vsf)*2*pi*deg2rad(1);
phase = vsf./repmat(scat,[length(angles) 1]);

rtbWriteSpectrumFile(wave,scat,fullfile(resourceFolder,'scat.spd'));
writePhaseFile(wave,phase,fullfile(resourceFolder,'phase.spd'));


%% Choose files to render
cityId = 1;

cityScene = mexximpCleanImport(assets.city(cityId).modelPath,...
    'ignoreRootTransform',true,...
    'flipUVs',true,...
    'imagemagicImage','hblasins/imagemagic-docker',...
    'toReplace',{'jpg','png','tga'},...
    'targetFormat','exr',...
    'makeLeftHanded',true,...
    'flipWindingOrder',true,...
    'workingFolder',resourceFolder);

scene = cityScene;

objects = placeObjects('cityId',cityId,...
            'nCars',1,...
            'nTrucks',0,...
            'nPeople',0,...
            'nBuses',0);
        
objects(1).position = [0, 0, 0];

for i=1:length(objects)
    
    carScene = mexximpCleanImport(objects(i).modelPath,...
        'ignoreRootTransform',true,...
        'flipUVs',true,...
        'imagemagicImage','hblasins/imagemagic-docker',...
        'toReplace',{'jpg','png','tga'},...
        'targetFormat','exr',...
        'makeLeftHanded',true,...
        'flipWindingOrder',true,...
        'workingFolder',resourceFolder);
    objects(i).bndbox = mexximpSceneBox(carScene);
    
    scene = mexximpCombineScenes(scene,carScene,...
        'insertTransform',mexximpTranslate([0 0 0]),...
        'cleanupTransform',mexximpTranslate([0 0 0]),...
        'insertPrefix',objects(i).prefix);
end

objectArrangements = {objects};
placedCameras = nnPlaceCameras(cameras,objectArrangements);



%% Create a list of render conditions
conditionsFile = fullfile(resourceFolder,'Conditions.txt');
names = cat(1,'imageName','objPosFile','fog',fieldnames(placedCameras{1}));
values = cell(1,length(names));

cntr = 1;
for m=1:length(objectArrangements)
    objectArrangementFile = fullfile(resourceFolder,sprintf('Arrangement_%i.json',m));
    savejson('',objectArrangements{m},objectArrangementFile);
    
    currentCameras = placedCameras{m};
    
    for f=0:1
        for c=1:length(placedCameras{m});
            
            fName = sprintf('%03i_%s',cntr,currentCameras(c).mode);
            
            values(cntr,1) = {fName};
            values(cntr,2) = {objectArrangementFile};
            if f==0
                values(cntr,3) = {'false'};
            else
                values(cntr,3) = {'true'};
            end
            for i=(length(names)-length(fieldnames(placedCameras{1})))+1:length(names)
                values(cntr,i) = {currentCameras(c).(names{i})};
            end
            
            cntr = cntr + 1;
        end
    end
end

rtbWriteConditionsFile(conditionsFile,names,values);

% Generate files and render
% We parallelize scene generation, not the rendering because PBRT
% automatically scales the number of processes to equal the nubmer of
% cores.
%%


nativeSceneFiles = rtbMakeSceneFiles(scene, 'hints', hints,...
    'conditionsFile',conditionsFile);


%%
radianceDataFiles = rtbBatchRender(nativeSceneFiles, 'hints', hints);

%%

labelMap(1).name = 'car';
labelMap(1).id = 7;

for i=1:1:length(radianceDataFiles)
    radianceData = load(radianceDataFiles{i});
    
    
    %% Create an oi
    oiParams.lensType = values{i,strcmp(names,'lens')};
    oiParams.filmDistance = values{i,strcmp(names,'filmDistance')};
    oiParams.filmDiag = values{i,strcmp(names,'filmDiagonal')};
    
    [~, label] = fileparts(radianceDataFiles{i});
        
    oi = buildOi(radianceData.multispectralImage, [], oiParams);
    oi = oiAdjustIlluminance(oi,100);
    oi = oiSet(oi,'name',label);
    
    
    ieAddObject(oi);
    oiWindow;
    
    sensor = sensorCreate('bayer (rggb)');
    sensor = sensorSet(sensor,'size',oiGet(oi,'size'));
    sensor = sensorSet(sensor,'pixel widthandheight',[oiGet(oi,'hres'), oiGet(oi,'wres')]);
    sensor = sensorSet(sensor,'analog gain',1);
    sensor = sensorCompute(sensor,oi);
    ieAddObject(sensor);
    sensorWindow();
    
    ip = ipCompute(ipCreate,sensor);
    ieAddObject(ip);
    ipWindow();
    
    %{
    [classMap, instanceMap] = mergeMetadata(radianceDataFiles{i+1},labelMap);

    objects = getBndBox(classMap,instanceMap,labelMap);
    
    figure;
    imshow(oiGet(oi,'rgb image'));
    for j=1:length(objects)
       pos = [objects{j}.bndbox.xmin objects{j}.bndbox.ymin ...
              objects{j}.bndbox.xmax-objects{j}.bndbox.xmin ...
              objects{j}.bndbox.ymax-objects{j}.bndbox.ymin];
       rectangle('Position',pos,'EdgeColor','red'); 
    end
    %}
    
    imwrite(oiGet(oi,'rgb image'),sprintf('%s.png',label));
    
end







