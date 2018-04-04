% This script re-creates the basic city scenes with corresponding object
% arrangements. Each of the four city blocks have five different object
% arrangements producing a total of 20 diferent scenes.
%
% Copyright, Henryk Blasinski 2018.

close all;
clear all;
clc;

ieInit;
constants;

[a, placementDataPath] = nnGenRootPath();

%% Camera parameters
%  These are not critical, because the point of this scripts is to create
%  PBRT scenes that can be used in further analyses.

cameras = nnGenCameras('type',{'pinhole'},...
    'lens',{'dgauss.22deg.3.0mm'},...
    'mode',{'radiance'},...
    'diffraction',{'false'},...
    'chromaticAberration',{'false'},...
    'distance',10,...
    'filmDiagonal',2.42,... %3um pixel
    'lookAtObject',1,...
    'pixelSamples',128);


%% Choose renderer options.
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.renderer = 'PBRT'; % We're only using PBRT right now
hints.copyResources = 1;

for cityId = 1:4
    for placementId = 1:5
        
        hints.recipeName = sprintf('MultiObject-City-%i-Placement-%i',cityId,placementId); % Name of the render
        
        hints.batchRenderStrategy = RtbAssimpStrategy(hints);
        hints.batchRenderStrategy.remodelPerConditionAfterFunction = @MexximpRemodellerMultipleObjV2;
        hints.batchRenderStrategy.converter = RtbAssimpPBRTConverter(hints);
        hints.batchRenderStrategy.converter.remodelAfterMappingsFunction = @PBRTRemodellerV2;
        hints.batchRenderStrategy.converter.rewriteMeshData = false;
        
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
        
        scene = mexximpCleanImport(assets.city(cityId).modelPath,...
            'flipUVs',true,...
            'toReplace',{'jpg','png','tga'},...
            'targetFormat','exr',...
            'options','-gamma 0.45',... % This flag specifies the correct rendering of texture. IT WAS NOT USED FOR THE ORIGINAL SCENS.
            'makeLeftHanded',true,...
            'flipWindingOrder',true,...
            'workingFolder',resourceFolder);
        
        placementFileName = fullfile(placementDataPath,'Parameters','SceneArrangements',sprintf('AssetPos_City_%i_Placement_%i.json',cityId,placementId));
        objects = loadjson(placementFileName,'SimplifyCell',1); 
        
        i = 1;
        while i <= length(objects)
            
            asset = mexximpCleanImport(fullfile(assetDir,objects(i).modelPath),...
                'flipUVs',true,...
                'toReplace',{'jpg','png','tga'},...
                'options','-gamma 0.45',... % This flag specifies the correct rendering of texture. IT WAS NOT USED FOR THE ORIGINAL SCENS.
                'targetFormat','exr',...
                'makeLeftHanded',true,...
                'flipWindingOrder',true,...
                'workingFolder',resourceFolder);
            
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
        conditionsFile = fullfile(resourceFolder,sprintf('Conditions_city_%i_placement_%i.txt',cityId,placementId));
        names = cat(1,'imageName','objPosFile',fieldnames(placedCameras{1}));
        
        values = cell(1,length(names));
        cntr = 1;
        
        objectArrangementFile = fullfile(resourceFolder,sprintf('City_%i_placement_%i.json',cityId,placementId));
        savejson('',objectArrangements{1},objectArrangementFile);
        
        currentCameras = placedCameras{1};
        
        for c=1:length(placedCameras{1});
            
            placementFileName = sprintf('City_%i_placement_%i_%s',cityId,placementId,currentCameras(c).mode);
            
            values(cntr,1) = {placementFileName};
            values(cntr,2) = {objectArrangementFile};
            for i=3:(length(names))
                values(cntr,i) = {currentCameras(c).(names{i})};
            end
            
            cntr = cntr + 1;
        end
        
        
        rtbWriteConditionsFile(conditionsFile,names,values);
        
        % Generate files and render
        % We parallelize scene generation, not the rendering because PBRT
        % automatically scales the number of processes to equal the nubmer of
        % cores.
        %%
        
        nativeSceneFiles = rtbMakeSceneFiles(scene, 'hints', hints,...
            'conditionsFile',conditionsFile);
        
        %% Render the scene (sanity check)
        
        rtbBatchRender(nativeSceneFiles, 'hints', hints);
        
        %% Build oi
        
        sceneMetadata = assembleSceneFiles(hints,names,values);
        
        for i=1:length(sceneMetadata)
            
            radianceData = piReadDAT(sceneMetadata(i).radiance, 'maxPlanes', 31);
            
            oiParams.lensType = values{i,strcmp(names,'lens')};
            oiParams.filmDistance = values{i,strcmp(names,'filmDistance')};
            oiParams.filmDiag = values{i,strcmp(names,'filmDiagonal')};
            
            [~, label] = fileparts(sceneMetadata(i).radiance);
            
            oi = buildOi(radianceData, [], oiParams);
            oi = oiSet(oi,'name',label);
            ieAddObject(oi);
        end
        oiWindow();
        drawnow();
        
    end
end
