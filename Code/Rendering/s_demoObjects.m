% This is a script that demonstrates how to place different objects in a
% city scene.
%
% The scene is assembled and rendered with RTB4.
%
% Copyright, Henryk Blasinski 2018

close all;
clear all;
clc;

ieInit;
constants;

%% Camera parameters
%  At this point we specify absolute camera parameters (film size, lens
%  type etc.) and camera's position in the scene relative to the lookAtObject. 

cameras = nnGenCameras('type',{'pinhole'},...
    'lens',{'dgauss.22deg.3.0mm'},...
    'mode',{'radiance','material','mesh','depth'},...
    'diffraction',{'false'},...
    'chromaticAberration',{'false'},...
    'filmDiagonal',2.42,...     % 3um pixel at 640x480 resolution
    'distance',20,...           % The camera will be placed 20m from the object
    'lookAtObject',1,...        % The camera is looking at the object with id=1
    'orientation',[0 60],...    % Orientation defines the rotation of the cameraLookAt vector on the xy plane (Earth surface). We look at a car from 0 and 60 deg.
    'pixelSamples',128);

%% Choose renderer options.

hints.imageWidth = 640;
hints.imageHeight = 480;
hints.recipeName = 'DemoObjects';   % Name of the render
hints.renderer = 'PBRT';            % We are using local rendering
hints.copyResources = 1;
hints.batchRenderStrategy = RtbAssimpStrategy(hints);

% Change the docker container
hints.batchRenderStrategy.remodelPerConditionAfterFunction = @MexximpRemodellerMultipleObjV2;
hints.batchRenderStrategy.converter = RtbAssimpPBRTConverter(hints);
hints.batchRenderStrategy.converter.remodelAfterMappingsFunction = @PBRTRemodellerV2;
hints.batchRenderStrategy.converter.rewriteMeshData = false;
hints.batchRenderStrategy.renderer.pbrt.dockerImage = 'vistalab/pbrt-v2-spectral';
% hints.batchRenderStrategy.renderer = RtbPBRTCloudRenderer(hints);
% hints.batchRenderStrategy.renderer.pbrt.dockerImage = 'gcr.io/primal-surfer-140120/pbrt-v2-spectral-gcloud';
% hints.batchRenderStrategy.renderer.cloudBucket = 'gs://primal-surfer-140120.appspot.com';

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
skyFile = fullfile(assetDir,'City','sky.exr');
copyfile(skyFile,resourceFolder);


%% Assemble a scene to render
cityId = 1;

scene = mexximpCleanImport(assets.city(cityId).modelPath,...
    'ignoreRootTransform',true,...
    'flipUVs',true,...
    'imagemagicImage','rendertoolbox/imagemagic-docker',...
    'toReplace',{'jpg','png','tga'},...
    'targetFormat','exr',...
    'makeLeftHanded',true,...
    'flipWindingOrder',true,...
    'workingFolder',resourceFolder);
    
    
% Randomly pick objects from our assets and place them at random, but semantically
% correct locations in the specific city scene. We specify the number of objects from each category.
objects = placeObjects('cityId',cityId,...
    'nCars',1,...
    'nTrucks',0,...
    'nPeople',0,...
    'nBuses',0);

% We choose the first object to be placed at the origin beacuse we know it
% is a good location for an object.
objects(1).position = [0 0 0];
        
i = 1;
while i <= length(objects)
    
    % Load the asset mesh 
    asset = mexximpCleanImport(objects(i).modelPath,...
        'ignoreRootTransform',true,...
        'flipUVs',true,...
        'imagemagicImage','hblasins/imagemagic-docker',...
        'toReplace',{'jpg','png','tga'},...
        'targetFormat','exr',...
        'makeLeftHanded',true,...
        'flipWindingOrder',true,...
        'workingFolder',resourceFolder);
        
        
    % Compute the bounding box of the asset
    objects(i).bndbox = mexximpSceneBox(asset);
    
    % Check if the current asset does not overlap with the assets we have
    % already placed in the scene.
    intersect = nnObjectsIntersect(objects(i),objects(1:i-1));
    
    if intersect == false
        % If objects don't intersect, insert into the scene ..
        scene = mexximpCombineScenes(scene,asset,...
            'insertTransform',mexximpTranslate([0 0 0]),...
            'cleanupTransform',mexximpTranslate([0 0 0]),...
            'insertPrefix',objects(i).prefix);
        i = i+1;
    else
        % ... otherwise ignore it.
        objects(i) = [];
    end
end

% Now that we know the position of objects in the scene, we can convert
% relative camera placement to absolute camera placement.
objectArrangements = {objects};
placedCameras = nnPlaceCameras(cameras,objectArrangements);
        
%% Create a list of render conditions
conditionsFile = fullfile(resourceFolder,'Conditions.txt');
names = cat(1,'imageName','objPosFile',fieldnames(placedCameras{1}));

objectArrangementFile = fullfile(resourceFolder,'City.json');
savejson('',objectArrangements,'FileName',objectArrangementFile);

currentCameras = placedCameras{1};

values = cell(1,length(names));
cntr = 1;
for c=1:length(currentCameras);
    
    fName = sprintf('%03i_%s',cntr,currentCameras(c).description);
    
    values(cntr,1) = {fName};
    values(cntr,2) = {objectArrangementFile};
    for i=3:(length(names))
        values(cntr,i) = {currentCameras(c).(names{i})};
    end
    
    cntr = cntr + 1;
end
        
rtbWriteConditionsFile(conditionsFile,names,values);


%% Generate scene files
% We parallelize scene generation, not the rendering because PBRT
% automatically scales the number of processes to equal the nubmer of
% cores.

hints.isParallel = true;
nativeSceneFiles = rtbMakeSceneFiles(scene, 'hints', hints,...
    'conditionsFile',conditionsFile);
hints.isParallel = false;


% Rendering
rtbBatchRender(nativeSceneFiles, 'hints', hints);
        

%% Show results

% First we parse the contents of the conditions file and try to combine
% radiance, depth, mesh and material renderings.
sceneMetadata = assembleSceneFiles(hints,names,values);

labelMap(1).name = 'car';
labelMap(1).id = 7;
labelMap(1).color = [0 0 1];
labelMap(2).name='person';
labelMap(2).id = 8;
labelMap(2).color = [0 1 0];
labelMap(3).name='truck';
labelMap(3).id = 9;
labelMap(3).color = [1 0 0];
labelMap(4).name='bus';
labelMap(4).id = 1;
labelMap(4).color = [1 0 1];


for i=1:length(sceneMetadata)
    
    radianceData = piReadDAT(sceneMetadata(i).radiance, 'maxPlanes', 31);
    
    
    %% Create an oi
    oiParams.lensType = values{i,strcmp(names,'lens')};
    oiParams.filmDistance = values{i,strcmp(names,'filmDistance')};
    oiParams.filmDiag = values{i,strcmp(names,'filmDiagonal')};
    
    [~, label] = fileparts(sceneMetadata(i).radiance);
        
    oi = buildOi(radianceData, [], oiParams);
    oi = oiSet(oi,'name',label);
    
    if ~isempty(sceneMetadata(i).mesh)
        
        [classMap, instanceMap] = mergeMetadata(sceneMetadata(i).mesh,labelMap);
        detections = getBndBox(classMap,instanceMap,labelMap,sceneMetadata(i));
        
        figure;
        imshow(oiGet(oi,'rgb image'),'Border','tight');
        for j=1:length(detections)
            pos = [detections{j}.bndbox.xmin detections{j}.bndbox.ymin ...
                detections{j}.bndbox.xmax-detections{j}.bndbox.xmin ...
                detections{j}.bndbox.ymax-detections{j}.bndbox.ymin];
            rectangle('Position',pos,'EdgeColor',detections{j}.labelColor);
                
        end
        drawnow;
    end
    
    if ~isempty(sceneMetadata(i).depth)
        depthData = piReadDAT(sceneMetadata(i).depth, 'maxPlanes', 31);
        figure;
        imagesc(depthData(:,:,1),[0 100000]);
        for j=1:length(detections)
            pos = [detections{j}.bndbox.xmin detections{j}.bndbox.ymin ...
                detections{j}.bndbox.xmax-detections{j}.bndbox.xmin ...
                detections{j}.bndbox.ymax-detections{j}.bndbox.ymin];
            rectangle('Position',pos,'EdgeColor',detections{j}.labelColor);
                
        end
        drawnow;
        
    end
    
    if ~isempty(sceneMetadata(i).material)
        materialData = piReadDAT(sceneMetadata(i).material, 'maxPlanes', 31);
        figure;
        imagesc(materialData(:,:,1),[0 1000]);
        for j=1:length(detections)
            pos = [detections{j}.bndbox.xmin detections{j}.bndbox.ymin ...
                detections{j}.bndbox.xmax-detections{j}.bndbox.xmin ...
                detections{j}.bndbox.ymax-detections{j}.bndbox.ymin];
            rectangle('Position',pos,'EdgeColor',detections{j}.labelColor);
                
        end
        drawnow;
    end
end




