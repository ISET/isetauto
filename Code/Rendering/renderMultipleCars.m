%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

%% Scene description

% Henryk Blasinski
close all;
clear all;
clc;

ieInit;

sceneDir = fullfile('/','share','wandell','data','3DScenes','City');

%% Simulation parameters

cameraType = {'pinhole'}; %'dgauss.22deg.12.5mm'
lensType = {'tessar.22deg.6.0mm'};
mode = {'radiance','mesh'};

% Negative z is up.
% Scene is about 200x200m, units are mm.
% However we should specify meters, as they are automatically converted to
% mm in remodellers.

pixelSamples = 1024;

shadowDirection = [-0.5 -1 1;];

cameraDistance = [10, 20];
cameraOrientation = [0];
cameraHeight = [-1.5];
% cameraPan = [-20,-10,0,10,20];
% cameraTilt = [-20,-10,0,10,20];
cameraRoll = [0];


nCarPositions = 5;
carOrientation = [0];


fNumber = 2.8;
filmDiag = [(1/3.2)*25.4];
microlensDim = [0, 0];


%% Choose renderer options.
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.recipeName = 'City-Car-Examples-PTR'; % Name of the render
hints.renderer = 'PBRT'; % We're only using PBRT right now
hints.copyResources = 1;
hints.batchRenderStrategy = RtbAssimpStrategy(hints);

% Change the docker container
hints.batchRenderStrategy.renderer.pbrt.dockerImage = 'vistalab/pbrt-v2-spectral';
hints.batchRenderStrategy.remodelPerConditionAfterFunction = @MexximpRemodellerMoveCar;
hints.batchRenderStrategy.converter.remodelAfterMappingsFunction = @PBRTRemodeller;
hints.batchRenderStrategy.converter.rewriteMeshData = false;

resourceFolder = rtbWorkingFolder('folderName','resources',...
    'rendererSpecific',false,...
    'hints',hints);


% Copy resources
lensFiles = fullfile(rtbsRootPath,'SharedData','*.dat');
copyfile(lensFiles,resourceFolder);

% Copy sky map
skyFile = fullfile('/','share','wandell','data','3DScenes','City','*.exr');
copyfile(skyFile,resourceFolder);


%% Choose files to render

for cityId=1:4
    sceneFile = sprintf('City_%i.obj',cityId);
    parentSceneFile = fullfile(sceneDir,sceneFile);
    
    
    [cityScene, elements] = mexximpCleanImport(parentSceneFile,...
        'ignoreRootTransform',true,...
        'flipUVs',true,...
        'imagemagicImage','hblasins/imagemagic-docker',...
        'toReplace',{'jpg','png','tga'},...
        'targetFormat','exr',...
        'makeLeftHanded',true,...
        'flipWindingOrder',true,...
        'workingFolder',resourceFolder);
    
    carPosition = zeros(nCarPositions,3);
    
    for i=1:nCarPositions
        carPosition(i,1:2) = drawCarPosition(cityId)/1000;
    end
    
    
    for carId=1:5
        carFile = sprintf('Car_%i.obj',carId);
        parentSceneFile = fullfile(sceneDir,carFile);
        
        [carScene, elements] = mexximpCleanImport(parentSceneFile,...
            'ignoreRootTransform',true,...
            'flipUVs',true,...
            'imagemagicImage','hblasins/imagemagic-docker',...
            'toReplace',{'jpg','png','tga'},...
            'targetFormat','exr',...
            'makeLeftHanded',true,...
            'flipWindingOrder',true,...
            'workingFolder',resourceFolder);
        
        scene = mexximpCombineScenes(cityScene,carScene,...
            'insertTransform',mexximpTranslate([0 0 0]),...
            'cleanupTransform',mexximpTranslate([0 0 0]));
        
        
        
        conditionsFile = fullfile(resourceFolder,sprintf('Conditions_city_%i_car_%i.txt',cityId,carId));
        
        cameraPan = 
        cameraTilt
        
        
        
        %% Create a list of render conditions
        names = {'imageName','cameraType','lensType','mode','pixelSamples','filmDist','filmDiag','cameraPosition',...
            'shadowDirection','microlensDim','cameraLookAt','fNumber','carPosition','carOrientation','fog',...
            'diffraction','cameraPan','cameraTilt','cameraRoll'};
        
        values = cell(1,numel(names));
        cntr = 1;
        
        for ap=1:size(carPosition,1);
            for lt=1:length(lensType)
                lensFile = fullfile(rtbsRootPath,'SharedData',sprintf('%s.dat',lensType{lt}));
                
                cameraPosition = zeros(length(cameraDistance)*length(cameraOrientation)*length(cameraHeight),3);
                filmDistanceVec = zeros(length(cameraDistance)*length(cameraOrientation)*length(cameraHeight),1);
                cameraDistanceVec = zeros(length(cameraDistance)*length(cameraOrientation)*length(cameraHeight),1);
                
                for ch=1:length(cameraHeight)
                    for cd=1:length(cameraDistance)
                        for co=1:length(cameraOrientation)
                            
                            cx = cameraDistance(cd)*sind(cameraOrientation(co));
                            cy = cameraDistance(cd)*cosd(cameraOrientation(co));
                            
                            cameraPosition(length(cameraOrientation)*(cd-1)+co,1) = cx + carPosition(ap,1);
                            cameraPosition(length(cameraOrientation)*(cd-1)+co,2) = cy + carPosition(ap,2);
                            cameraPosition(length(cameraOrientation)*(cd-1)+co,3) = cameraHeight(ch);
                            
                            filmDistanceVec(length(cameraOrientation)*(cd-1)+co) = focusLens(lensFile,cameraDistance(cd)*1000);
                            cameraDistanceVec(length(cameraOrientation)*(cd-1)+co) = cameraDistance(cd);
                            
                        end
                    end
                end
                
                
                for ao=1:length(carOrientation);
                    for ct=1:length(cameraType)
                        for p=1:size(cameraPosition,1)
                            for s=1:size(shadowDirection,1)
                                for fn=1:length(fNumber)
                                    for cpan=1:length(cameraPan)
                                        for ctilt=1:length(cameraTilt)
                                            for croll=1:length(cameraRoll)
                                                for mo=1:length(mode)
                                                    
                                                    
                                                    if strcmp(cameraType{ct},'pinhole')
                                                        currentFilmDistance = effectiveFocalLength(lensFile);
                                                    else
                                                        currentFilmDistance = filmDistanceVec(p);
                                                    end
                                                    
                                                    cameraLookAt = [carPosition(ap,1:2) cameraHeight];
                                                    
                                                    fName = sprintf('%03i_city_%i_car_%i_%s_%s_%s_fN_%.2f_dist_%i',cntr,cityId,carId,cameraType{ct},lensType{lt},mode{mo},fNumber(fn),cameraDistanceVec(p));
                                                    
                                                    values(cntr,1) = {fName};
                                                    values(cntr,2) = cameraType(ct);
                                                    values(cntr,3) = lensType(lt);
                                                    values(cntr,4) = mode(mo);
                                                    values(cntr,5) = num2cell(pixelSamples(ct),1);
                                                    values(cntr,6) = num2cell(currentFilmDistance,1);
                                                    values(cntr,7) = num2cell(filmDiag,1);
                                                    values(cntr,8) = {mat2str(cameraPosition(p,:))};
                                                    values(cntr,9) = {mat2str(shadowDirection(s,:))};
                                                    values(cntr,10) = {mat2str(microlensDim)};
                                                    
                                                    values(cntr,11) = {mat2str(cameraLookAt)};
                                                    
                                                    values(cntr,12) = num2cell(fNumber(fn),1);
                                                    values(cntr,13) = {mat2str(carPosition(ap,:))};
                                                    values(cntr,14) = num2cell(carOrientation(ao));
                                                    values(cntr,15) = num2cell(0);
                                                    values(cntr,16) = {'false'};
                                                    values(cntr,17) = num2cell(cameraPan(cpan),1);
                                                    values(cntr,18) = num2cell(cameraTilt(ctilt),1);
                                                    values(cntr,19) = num2cell(cameraRoll(croll),1);
                                                    
                                                    cntr = cntr + 1;
                                                    %{
                                                    if isempty(strfind(mode{mo},'pinhole')),
                                                        x
                                                    end
                                                    %}
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
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
        radianceDataFiles = rtbBatchRender(nativeSceneFiles, 'hints', hints);
        
        %%
        
        for i=1:length(radianceDataFiles)
            radianceData = load(radianceDataFiles{i});
            
            
            %% Create an oi
            oiParams.lensType = lensType{lt};
            oiParams.filmDistance = 10;
            oiParams.filmDiag = 20;
            
            [path, condname] = fileparts(radianceDataFiles{i});
            
            label = condname;
            
            oi = BuildOI(radianceData.multispectralImage, [], oiParams);
            oi = oiSet(oi,'name',label);
            
            
            ieAddObject(oi);
            oiWindow;
        end
        
    end
end

