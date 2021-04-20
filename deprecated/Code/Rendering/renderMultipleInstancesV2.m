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

cameras = nnGenCameras('type',{'lens'},...
    'lens',{'dgauss.22deg.3.0mm'},...
    'mode',{'radiance','mesh'},...
    'diffraction',{'false'},...
    'chromaticAberration',{'false'},...
    'distance',10,...
    'filmDiagonal',2.42,... %3um pixel
    'lookAtObject',1,...
    'orientation',0,...
    'orientationRange',[],...
    'pixelSamples',128);

%% Choose renderer options.
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.recipeName = 'MultiInstance-Tests'; % Name of the render
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


%% Choose files to render
for cityId=1:1
    
    cityScene = mexximpCleanImport(assets.city(cityId).path,...
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
        
    i = 1;
    while i <= length(objects)
        
        if isempty(assets.(objects(i).class)(objects(i).id).model)
            
            asset = mexximpCleanImport(objects(i).modelPath,...
                'ignoreRootTransform',true,...
                'flipUVs',true,...
                'imagemagicImage','hblasins/imagemagic-docker',...
                'toReplace',{'jpg','png','tga'},...
                'targetFormat','exr',...
                'makeLeftHanded',true,...
                'flipWindingOrder',true,...
                'workingFolder',resourceFolder);
            
            assets.(objects(i).class)(objects(i).id).model = asset;
        else
            asset = assets.(objects(i).class)(objects(i).id).model;
        end
        
        objects(i).bndbox = mexximpSceneBox(asset);
        
        intersect = nnObjectsIntersect(objects(i),objects(1:i-1));
        
        if intersect == false
            % If objects don't intersect, insert into the scene
            scene = mexximpCombineScenes(scene,asset,...
                'insertTransform',mexximpTranslate([0 0 0]),...
                'cleanupTransform',mexximpTranslate([0 0 0]),...
                'insertPrefix',objects(i).prefix);
            i = i+1;
        else
            % If the new object intersects with the ones already present,
            % remove
            objects(i) = [];
        end
    end
    
    objects(1).position  = [0 0 0];
    
    objectArrangements = {objects};
    placedCameras = nnPlaceCameras(cameras,objectArrangements);
    
    
    
    %% Create a list of render conditions
    conditionsFile = fullfile(resourceFolder,sprintf('Conditions_%i.txt',cityId));
    names = cat(1,'imageName',fieldnames(placedCameras{1}),'objPosFile');
    values = cell(1,length(names));
    
    cntr = 1;
    
    sceneId=1;
    for m=1:length(objectArrangements)
        objectArrangementFile = fullfile(resourceFolder,sprintf('City_%i_Arrangement_%i.json',cityId,m));
        savejson('',objectArrangements{m},objectArrangementFile);
        
        currentCameras = placedCameras{m};
        
        for c=1:length(placedCameras{m});
            
            fName = sprintf('%03i_city_%i_%s',sceneId,cityId,currentCameras(c).mode);
            
            values(cntr,1) = {fName};
            for i=2:(length(names)-1)
                values(cntr,i) = {currentCameras(c).(names{i})};
            end
            values(cntr,length(names)) = {objectArrangementFile};
            
            if strcmp(currentCameras(c).mode,'radiance')
                sceneId = sceneId+1;
            end
            cntr = cntr + 1;
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
    labelMap(2).name='person';
    labelMap(2).id = 8;
    labelMap(3).name='truck';
    labelMap(3).id = 9;
    labelMap(4).name='bus';
    labelMap(4).id = 1;
    
    for i=1:2:length(radianceDataFiles)
        radianceData = load(radianceDataFiles{i});
        
        
        %% Create an oi
        oiParams.lensType = values{i,strcmp(names,'lens')};
        oiParams.filmDistance = values{i,strcmp(names,'filmDistance')};
        oiParams.filmDiag = values{i,strcmp(names,'filmDiagonal')};
        
        [~, label] = fileparts(radianceDataFiles{i});
        
        oi = buildOi(radianceData.multispectralImage, [], oiParams);
        oi = oiSet(oi,'name',label);
        
        
        ieAddObject(oi);
        oiWindow;
        
        
        [classMap, instanceMap] = mergeMetadataMultiInstance(radianceDataFiles{i+1},labelMap);
        
        detections = getBndBox(classMap,instanceMap,labelMap);
        
        figure;
        imshow(oiGet(oi,'rgb image'));
        for j=1:length(detections)
            pos = [detections{j}.bndbox.xmin detections{j}.bndbox.ymin ...
                detections{j}.bndbox.xmax-detections{j}.bndbox.xmin ...
                detections{j}.bndbox.ymax-detections{j}.bndbox.ymin];
            rectangle('Position',pos,'EdgeColor','red');
        end
        
        % imwrite(oiGet(oi,'rgb image'),sprintf('%i_%s.png',cityId,label));
    end
    
    
    
    
end


