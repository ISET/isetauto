
% Henryk Blasinski
close all;
clear all;
clc;

ieInit;
constants;

%% Simulation parameters

cameras = nnGenCameras('type',{'pinhole'},...
    'lens',{'dgauss.22deg.3.0mm'},...
    'mode',{'radiance','mesh'},...
    'diffraction',{'false'},...
    'chromaticAberration',{'false'},...
    'distance',[10, 20, 30],...
    'filmDiagonal',2.42,... %3um pixel
    'lookAtObject',randi(20,1,20),...
    'PTRrange',[20, 10, 5; -20, -10, -5],...
    'orientation',1:4,...
    'orientationRange',[0 360],...
    'pixelSamples',1024);

%% Choose renderer options.
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.recipeName = 'MultiObject-Pinhole'; % Name of the render
hints.renderer = 'PBRTCloud'; % We're only using PBRT right now
hints.copyResources = 1;
hints.tokenPath = fullfile('/','home','hblasins','docker','StorageAdmin.json');
hints.batchRenderStrategy = RtbAssimpStrategy(hints);

% Change the docker container
hints.batchRenderStrategy.remodelPerConditionAfterFunction = @MexximpRemodellerMultipleObjV2;
hints.batchRenderStrategy.converter = RtbAssimpPBRTConverter(hints);
hints.batchRenderStrategy.converter.remodelAfterMappingsFunction = @PBRTRemodellerV2;
hints.batchRenderStrategy.converter.rewriteMeshData = false;
hints.batchRenderStrategy.renderer = RtbPBRTCloudRenderer(hints);
hints.batchRenderStrategy.renderer.pbrt.dockerImage = 'gcr.io/primal-surfer-140120/pbrt-v2-spectral-gcloud';
hints.batchRenderStrategy.renderer.cloudFolder = fullfile('gs://primal-surfer-140120.appspot.com',hints.recipeName);

rtbCloudInit(hints);

%%

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

uniqueId = 1;
nPlacements = 5;

condFiles = {};
for cityId=1:4
    
    cityScene = mexximpCleanImport(assets.city(cityId).modelPath,...
        'ignoreRootTransform',true,...
        'flipUVs',true,...
        'imagemagicImage','hblasins/imagemagic-docker',...
        'toReplace',{'jpg','png','tga'},...
        'targetFormat','exr',...
        'makeLeftHanded',true,...
        'flipWindingOrder',true,...
        'workingFolder',resourceFolder);
    
    
    for p=1:nPlacements
        
        scene = cityScene;
        
        objects = placeObjects('cityId',cityId,...
            'nCars',8,...
            'nTrucks',1,...
            'nPeople',20,...
            'nBuses',1);
        
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
        
        
        objectArrangements = {objects};
        placedCameras = nnPlaceCameras(cameras,objectArrangements);
        
        
        
        %% Create a list of render conditions
        conditionsFile = fullfile(resourceFolder,sprintf('Conditions_city_%i_placement_%i.txt',cityId,p));
        condFiles = cat(1,condFiles, {conditionsFile});
        names = cat(1,'imageName','objPosFile',fieldnames(placedCameras{1}));
        
        values = cell(1,length(names));
        cntr = 1;
        
        objectArrangementFile = fullfile(resourceFolder,sprintf('City_%i_placement_%i.json',cityId,p));
        savejson('',objectArrangements{1},objectArrangementFile);
        
        currentCameras = placedCameras{1};
        
        for c=1:length(placedCameras{1});
            
            fName = sprintf('%03i_city_%i_placement_%i_%s',uniqueId,cityId,p,currentCameras(c).mode);
            
            values(cntr,1) = {fName};
            values(cntr,2) = {objectArrangementFile};
            for i=3:(length(names))
                values(cntr,i) = {currentCameras(c).(names{i})};
            end
            
            cntr = cntr + 1;
            uniqueId = uniqueId + 1;
        end
        
        
        rtbWriteConditionsFile(conditionsFile,names,values);
        
        % Generate files and render
        % We parallelize scene generation, not the rendering because PBRT
        % automatically scales the number of processes to equal the nubmer of
        % cores.
        %%
        
        hints.isParallel = true;
        nativeSceneFiles = rtbMakeSceneFiles(scene, 'hints', hints,...
            'conditionsFile',conditionsFile);
        hints.isParallel = false;
        
        %%
        rtbCloudUpload(hints,nativeSceneFiles);
        
        
        %%
        radianceDataFiles = rtbBatchRender(nativeSceneFiles, 'hints', hints);
    end
end

%% Download the data

rtbCloudDownload(hints);

%% Assemble radiance, mesh, depth etc.

resultFiles = assembleSceneFiles(hints, names, {},...
                                'conditionFiles',condFiles);

colorMap = jet(4);

labelMap(1).name = 'car';
labelMap(1).id = 7;
labelMap(1).color = colorMap(1,:);
labelMap(2).name = 'person';
labelMap(2).id = 8;
labelMap(2).color = colorMap(2,:);
labelMap(3).name = 'truck';
labelMap(3).id = 9;
labelMap(3).color = colorMap(3,:);
labelMap(4).name = 'bus';
labelMap(4).id = 1;
labelMap(4).color = colorMap(4,:);


for i=1:length(resultFiles)
    
    radianceData = load(resultFiles(i).radiance);
    
    
    %% Create an oi
    oiParams.lensType = resultFiles(i).lens;
    oiParams.filmDistance = str2double(resultFiles(i).filmDistance);
    oiParams.filmDiag = str2double(resultFiles(i).filmDiagonal);
    
    [~, label] = fileparts(resultFiles(i).radiance);
        
    oi = buildOi(radianceData.multispectralImage, [], oiParams);
    oi = oiSet(oi,'name',label);
    
    
    ieAddObject(oi);
    oiWindow;
    
    if ~isempty(resultFiles(i).mesh)
        
        [classMap, instanceMap] = mergeMetadataMultiInstance(resultFiles(i).mesh,labelMap);
        detections = getBndBox(classMap,instanceMap,labelMap);
        
        figure;
        imshow(oiGet(oi,'rgb image'));
        imwrite(oiGet(oi,'rgb image'),sprintf('%i.png',i));
        title(sprintf('%s-diff-%s-chr-%s-def-%i',resultFiles(i).type,resultFiles(i).diffraction,...
            resultFiles(i).chromaticAberration, resultFiles(i).defocus));
        for j=1:length(detections)
            pos = [detections{j}.bndbox.xmin detections{j}.bndbox.ymin ...
                detections{j}.bndbox.xmax-detections{j}.bndbox.xmin ...
                detections{j}.bndbox.ymax-detections{j}.bndbox.ymin];
            
            id = strcmp({labelMap(:).name},detections{j}.name);
            rectangle('Position',pos,'EdgeColor',labelMap(id).color);
            
        end
        drawnow;
        print('-dpng',sprintf('%i_labeled.png',i));
    end
    
    if ~isempty(resultFiles(i).depth)
        
        depthData = load(resultFiles(i).depth);
        figure;
        imagesc(depthData.multispectralImage(:,:,1),[0, 500]);
        
        if exist('detections','var')
            for j=1:length(detections)
                pos = [detections{j}.bndbox.xmin detections{j}.bndbox.ymin ...
                    detections{j}.bndbox.xmax-detections{j}.bndbox.xmin ...
                    detections{j}.bndbox.ymax-detections{j}.bndbox.ymin];
                
                id = strcmp({labelMap(:).name},detections{j}.name);
                rectangle('Position',pos,'EdgeColor',labelMap(id).color);
            end
        end
        drawnow;
        print('-dpng',sprintf('%i_depth_labeled.png',i));

    end
    
end




