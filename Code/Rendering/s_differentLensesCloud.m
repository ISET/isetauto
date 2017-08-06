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

cameraType = {'lens'};
lensType = {'fisheye.87deg.6.0mm','wide.40deg.6.0mm','dgauss.22deg.6.0mm','wide.56deg.6.0mm','tessar.22deg.6.0mm','2el.XXdeg.6.0mm'};
mode = {'radiance','mesh'};

% Negative z is up.
% Scene is about 200x200m, units are mm.
% However we should specify meters, as they are automatically converted to
% mm in remodellers.

pixelSamples = 1024;

shadowDirection = [-0.5 -1 1;];
nCarPositions = 1;
carOrientation = [310];


cameraDistance = [20];
cameraOrientation = [0];
cameraHeight = [-1.5];
cameraDefocus = [0];

cameraPan = 0;
cameraTilt = 0;
cameraRoll = 0;

diffAndCA = {'true','true'};

fNumber = 4.0;
filmDiag = [(1/3.2)*25.4];
microlensDim = [0, 0];


%% Choose renderer options.
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.recipeName = 'Car-Lenses-V3-CloudTest'; % Name of the render
hints.renderer = 'PBRTCloud'; % We're only using PBRT right now
hints.copyResources = 1;
hints.tokenPath = fullfile('/','home','hblasins','docker','StorageAdmin.json');

hints.batchRenderStrategy = RtbAssimpStrategy(hints);

% Change the docker container
hints.batchRenderStrategy.remodelPerConditionAfterFunction = @MexximpRemodellerMoveCar;
hints.batchRenderStrategy.converter = RtbAssimpPBRTConverter(hints);
hints.batchRenderStrategy.converter.remodelAfterMappingsFunction = @PBRTRemodeller;
hints.batchRenderStrategy.converter.rewriteMeshData = false;
hints.batchRenderStrategy.renderer = RtbPBRTCloudRenderer(hints);
hints.batchRenderStrategy.renderer.pbrt.dockerImage = 'gcr.io/primal-surfer-140120/syncandrender';
hints.batchRenderStrategy.renderer.cloudFolder = fullfile('gs://primal-surfer-140120.appspot.com',hints.recipeName);

rtbCloudInit(hints);

resourceFolder = rtbWorkingFolder('folderName','resources',...
    'rendererSpecific',false,...
    'hints',hints);


% Copy resources
for i=1:length(lensType)
    lensFiles = fullfile(lensDir,sprintf('%s.dat',lensType{i}));
    copyfile(lensFiles,resourceFolder);
end

% Copy sky map
skyFile = fullfile(assetDir,'City','*.exr');
copyfile(skyFile,resourceFolder);

% Copy D65 spectrum
[wave, d65] = rtbReadSpectrum(fullfile(rtbRoot,'RenderData','D65.spd'));
d65 = 100*d65;
rtbWriteSpectrumFile(wave,d65,fullfile(resourceFolder,'D65.spd'));


%% Choose files to render
sceneID = 1;
batchID = 1;
for cityId=1:2
    sceneFile = sprintf('City_%i.obj',cityId);
    parentSceneFile = fullfile(assetDir,'City',sceneFile);
    
    
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
    %carPosition = [0, -15, 0];
    %{
    for i=1:nCarPositions
        carPosition(i,1:2) = drawCarPosition(cityId)/1000;
    end
    %}
    
    for carId=1:1
        carFile = sprintf('Car_%i.obj',carId);
        parentSceneFile = fullfile(assetDir,car2directory{carId},carFile);
        
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
        
        
        
        conditionsFile = fullfile(resourceFolder,sprintf('Conditions_%i.txt',batchID));
        
        
        
        
        %% Create a list of render conditions
        names = {'imageName','cameraType','lensType','mode','pixelSamples','filmDist','filmDiag','cameraPosition','shadowDirection','microlensDim','cameraLookAt','fNumber','carPosition','carOrientation'...
            'fog','diffraction','chromaticAberration','cameraPan','cameraTilt','cameraRoll'};
        
        values = cell(1,numel(names));
        cntr = 1;
        
        for ap=1:size(carPosition,1);
            for lt=1:length(lensType)
                lensFile = fullfile(rtbsRootPath,'SharedData',sprintf('%s.dat',lensType{lt}));
                
                sz = [length(cameraDefocus) length(cameraHeight) length(cameraDistance) length(cameraOrientation)];
                
                cameraPosition = zeros(prod(sz),3);
                filmDistanceVec = zeros(prod(sz),1);
                cameraDistanceVec = zeros(prod(sz),1);
                
                
                for cdef=1:length(cameraDefocus)
                    for ch=1:length(cameraHeight)
                        for cd=1:length(cameraDistance)
                            for co=1:length(cameraOrientation)
                                
                                loc = sub2ind(sz,cdef,ch,cd,co);
                                
                                cx = cameraDistance(cd)*sind(cameraOrientation(co));
                                cy = cameraDistance(cd)*cosd(cameraOrientation(co));
                                
                                cameraPosition(loc,1) = cx + carPosition(ap,1);
                                cameraPosition(loc,2) = cy + carPosition(ap,2);
                                cameraPosition(loc,3) = cameraHeight(ch);
                                
                                filmDistanceVec(loc) = focusLens(lensFile,(cameraDistance(cd)+cameraDefocus(cdef))*1000);
                                cameraDistanceVec(loc) = cameraDistance(cd);
                                
                            end
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
                                                for df=1:size(diffAndCA,1)
                                                    for mo=1:length(mode)
                                                        
                                                        
                                                        fog=0;
                                                        
                                                        if strcmp(cameraType{ct},'pinhole')
                                                            currentFilmDistance = effectiveFocalLength(lensFile);
                                                        else
                                                            currentFilmDistance = filmDistanceVec(p);
                                                        end
                                                        
                                                        cameraLookAt = [carPosition(ap,1:2) cameraHeight];
                                                        % cameraLookAt = [0 0 0];
                                                        
                                                        fName = sprintf('%03i_city_%i_car_%i_%s_%s_%s_fN_%.2f_dist_%i_diff_%s_ca_%s',sceneID,cityId,carId,cameraType{ct},lensType{lt},mode{mo},fNumber(fn),cameraDistanceVec(p),...
                                                            diffAndCA{df,1},diffAndCA{df,2});
                                                        
                                                        values(cntr,1) = {fName};
                                                        values(cntr,2) = cameraType(ct);
                                                        values(cntr,3) = lensType(lt);
                                                        values(cntr,4) = mode(mo);
                                                        values(cntr,5) = num2cell(pixelSamples,1);
                                                        values(cntr,6) = num2cell(currentFilmDistance,1);
                                                        values(cntr,7) = num2cell(filmDiag,1);
                                                        values(cntr,8) = {mat2str(cameraPosition(p,:))};
                                                        values(cntr,9) = {mat2str(shadowDirection(s,:))};
                                                        values(cntr,10) = {mat2str(microlensDim)};
                                                        
                                                        values(cntr,11) = {mat2str(cameraLookAt)};
                                                        
                                                        values(cntr,12) = num2cell(fNumber(fn),1);
                                                        values(cntr,13) = {mat2str(carPosition(ap,:))};
                                                        values(cntr,14) = num2cell(carOrientation(ao));
                                                        values(cntr,15) = num2cell(fog);
                                                        values(cntr,16) = diffAndCA(df,1);
                                                        values(cntr,17) = diffAndCA(df,2);
                                                        values(cntr,18) = num2cell(cameraPan(cpan),1);
                                                        values(cntr,19) = num2cell(cameraTilt(ctilt),1);
                                                        values(cntr,20) = num2cell(cameraRoll(croll),1);
                                                        
                                                        cntr = cntr+1;
                                                    end
                                                    sceneID = sceneID+1;
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
        hints.batchRenderStrategy.renderer.dataFileName = sprintf('data_%05i.zip',batchID);
        rtbCloudUpload(hints, nativeSceneFiles);
        
        
        %%
        rtbBatchRender(nativeSceneFiles, 'hints', hints);
        
        batchID = batchID+1;
    end
end
%%

radianceDataFiles = rtbCloudDownload(hints);


for i=1:length(radianceDataFiles)
    radianceData = load(radianceDataFiles{i});
    
    if strfind(radianceDataFiles{i},'mesh'),
        figure;
        map = mergeMetadata(radianceDataFiles{i},{'City','Car'});
        imagesc(map);
        
        drawnow;
        continue;
    end;
    
    %% Create an oi
    oiParams.lensType = lensType{lt};
    oiParams.filmDistance = 10;
    oiParams.filmDiag = 20;
    
    [path, condname] = fileparts(radianceDataFiles{i});
    
    label = condname;
    
    if sum(size(radianceData.multispectralImage)) == 0, continue; end;
    
    oi = BuildOI(radianceData.multispectralImage, [], oiParams);
    oi = oiSet(oi,'name',label);
    
    
    ieAddObject(oi);
    oiWindow;
    
end




