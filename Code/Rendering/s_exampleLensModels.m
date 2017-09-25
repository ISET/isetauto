% This script renders an image through a lens with different imperfections
% (diffraciton and chromatic aberration) switched on/off.

% Henryk Blasinski
close all;
clear all;
clc;

ieInit;
constants;

%% Simulation parameters

cameras = nnGenCameras('type',{'pinhole','lens','lens','lens'},...
    'lens',{'dgauss.22deg.3.0mm'},...
    'mode',{'radiance'},...
    'diffraction',{'false','false','true','true'},...
    'chromaticAberration',{'false','false','false','true'},...
    'distance',20,...
    'filmDiagonal',2.42,... %3um pixel
    'lookAtObject',1,...
    'PTR',{[0, 0, 0]},...
    'orientation',0,...
    'pixelSamples',1024);


%% Choose renderer options.
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.recipeName = 'LensModels'; % Name of the render
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
cityId = 1;


scene = mexximpCleanImport(assets.city(cityId).modelPath,...
    'ignoreRootTransform',true,...
    'flipUVs',true,...
    'imagemagicImage','hblasins/imagemagic-docker',...
    'toReplace',{'jpg','png','tga'},...
    'targetFormat','exr',...
    'makeLeftHanded',true,...
    'flipWindingOrder',true,...
    'workingFolder',resourceFolder);


objects(1).class = 'car';
objects(1).id = 9;
objects(1).modelPath = assets.car(objects(1).id).modelPath;
objects(1).position = [0, 0, 0];
objects(1).area = 2;
objects(1).orientation = 105;
objects(1).prefix = 'car_inst_1';

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
names = cat(1,'imageName','objPosFile',fieldnames(placedCameras{1}));
values = cell(1,length(names));

cntr = 1;
for m=1:length(objectArrangements)
    objectArrangementFile = fullfile(resourceFolder,sprintf('Arrangement_%i.json',m));
    savejson('',objectArrangements{m},objectArrangementFile);
    
    currentCameras = placedCameras{m};
    
    for c=1:length(placedCameras{m});
        
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

% Generate files and render
% We parallelize scene generation, not the rendering because PBRT
% automatically scales the number of processes to equal the nubmer of
% cores.
%%


nativeSceneFiles = rtbMakeSceneFiles(scene, 'hints', hints,...
    'conditionsFile',conditionsFile);


%%
dataFiles = rtbBatchRender(nativeSceneFiles, 'hints', hints);

%% Show results

resultFiles = assembleSceneFiles(dataFiles);

labelMap(1).name = 'car';
labelMap(1).id = 7;
labelMap(2).name='person';
labelMap(2).id = 8;
labelMap(3).name='truck';
labelMap(3).id = 9;
labelMap(4).name='bus';
labelMap(4).id = 1;

images = cell(1,length(resultFiles));

for i=1:length(resultFiles)
    
    radianceData = load(resultFiles(i).radiance);
    
    
    %% Create an oi
    oiParams.lensType = values{i,strcmp(names,'lens')};
    oiParams.filmDistance = values{i,strcmp(names,'filmDistance')};
    oiParams.filmDiag = values{i,strcmp(names,'filmDiagonal')};
    
    [~, label] = fileparts(resultFiles(i).radiance);
        
    oi = buildOi(radianceData.multispectralImage, [], oiParams);
    oi = oiSet(oi,'name',label);
    
    
    ieAddObject(oi);
    oiWindow;
    
    fName = fullfile(rtbWorkingFolder('hints',hints),sprintf('%s.png',resultFiles(i).description));
    images{i} = oiGet(oi,'rgb image');
    imwrite(images{i},fName);
   
    
    if ~isempty(resultFiles(i).mesh)
        
        [classMap, instanceMap] = mergeMetadataMultiInstance(resultFiles(i).mesh,labelMap);
        detections = getBndBox(classMap,instanceMap,labelMap);
        
        figure;
        imshow(oiGet(oi,'rgb image'),'Border','tight');
        for j=1:length(detections)
            pos = [detections{j}.bndbox.xmin detections{j}.bndbox.ymin ...
                detections{j}.bndbox.xmax-detections{j}.bndbox.xmin ...
                detections{j}.bndbox.ymax-detections{j}.bndbox.ymin];
            switch (detections{j}.name)
                case 'car'
                    rectangle('Position',pos,'EdgeColor','red');
                case 'person'
                    rectangle('Position',pos,'EdgeColor','green');
            end
            
        end
        drawnow;
    end
    
end


