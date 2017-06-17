%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

%% Scene description

% Create a cluster
% gcloud container clusters create rtb4 --num-nodes=1 --max-nodes-per-pool=100 --machine-type=n1-highcpu-32 --preemptible --zone=us-central1-a --enable-autoscaling --min-nodes=1 --max-nodes=10

% Create a cleanup job
% kubectl run cleanup --restart=OnFailure --image=google/cloud-sdk -- /bin/bash -c 'while true; do echo "Starting"; kubectl delete jobs $(kubectl get jobs | awk '"'"'$3=="1" {print $1}'"'"'); echo "Deleted jobs"; sleep 600; done'

% Henryk Blasinski
close all;
clear all;
clc;

ieInit;

sceneDir = fullfile('/','share','wandell','data','3DScenes','City');

%% Simulation parameters

cameraType = {'pinhole','lens','lens'}; %'dgauss.22deg.12.5mm'
lensType = {'tessar.22deg.6.0mm','tessar.22deg.6.0mm','2el.XXdeg.6.0mm'};
assert(length(cameraType) == length(lensType));

mode = {'radiance','mesh'};

% Negative z is up.
% Scene is about 200x200m, units are mm.
% However we should specify meters, as they are automatically converted to
% mm in remodellers.

pixelSamples = 1024;

shadowDirection = [-0.5 -1 1;];

nCameraDistances = 1;
minCameraDistance = 5;
maxCameraDistance = 15;
distanceRange = maxCameraDistance - minCameraDistance;


nCameraOrientations = 1;
cameraHeight = [-1.5];
cameraDefocus = [-5, 0];


nCameraPan = 2;
nCameraTilt = 1;
cameraRoll = 0;
maxPan = 20;
maxTilt = 20;

nCarPositions = 2;
nCarOrientations = 1;

maxCars = 1;
maxCities = 2;

diffraction = {'false','true'};
chrAber = {'false','true'};
assert(length(diffraction) == length(chrAber));

fNumber = 2.8;
filmDiag = (1/3.2)*25.4;
microlensDim = [0, 0];


%% Choose renderer options.
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.recipeName = 'Car-diffAndCA-Test'; % Name of the render
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

resourceFolder = rtbWorkingFolder('folderName','resources',...
    'rendererSpecific',false,...
    'hints',hints);


% Copy resources
lensFiles = fullfile(rtbsRootPath,'SharedData','*.dat');
copyfile(lensFiles,resourceFolder);

% Copy sky map
skyFile = fullfile('/','share','wandell','data','3DScenes','City','*.exr');
copyfile(skyFile,resourceFolder);

% Copy D65 spectrum
[wave, d65] = rtbReadSpectrum(fullfile(rtbRoot,'RenderData','D65.spd'));
d65 = 100*d65;
rtbWriteSpectrumFile(wave,d65,fullfile(resourceFolder,'D65.spd'));


%% Choose files to render
sceneID = 1;
batchID = 1;
for cityId=1:maxCities
    sceneFile = sprintf('City_%i.obj',cityId);
    parentSceneFile = fullfile(sceneDir,sceneFile);
    
    
    [cityScene, elements] = mexximpCleanImport(parentSceneFile,...
        'ignoreRootTransform',true,...
        'flipUVs',true,...
        'imagemagicImage','hblasins/imagemagic-docker',...
        'toReplace',{'jpg','png','tga'},...
        'options','-gamma 0.45',...
        'targetFormat','exr',...
        'makeLeftHanded',true,...
        'flipWindingOrder',true,...
        'workingFolder',resourceFolder);
    
    carPosition = zeros(nCarPositions,3);
    
    for i=1:nCarPositions
        carPosition(i,1:2) = drawCarPosition(cityId)/1000;
    end
    
    
    for carId=1:maxCars
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
        
        for ap=1:size(carPosition,1);
            
            conditionsFile = fullfile(resourceFolder,sprintf('Conditions_%04i.txt',batchID));
            
            
            
            
            
            
            %% Create a list of render conditions
            names = {'imageName','cameraType','lensType','mode','pixelSamples','filmDist','filmDiag','cameraPosition',...
                'shadowDirection','microlensDim','cameraLookAt','fNumber','carPosition','carOrientation','fog',...
                'diffraction','chromaticAberration','cameraPan','cameraTilt','cameraRoll'};
            
            values = cell(1,numel(names));
            cntr = 1;
            
            cameraPan = (rand(nCameraPan,1) - 0.5)*maxPan;
            cameraTilt = (rand(nCameraTilt,1) - 0.5)*maxTilt;
            carOrientation = rand(nCarOrientations,1)*360;
            cameraOrientation = rand(nCameraOrientations,1)*360;
            
            if nCameraDistances >= 2
                cameraDistance = [rand(nCameraDistances*0.5,1)*distanceRange*0.5 (rand(nCameraDistances*0.5,1)+1)*distanceRange*0.5] + minCameraDistance;
            else
                cameraDistance = rand(1)*distanceRange + minCameraDistance;
            end
            cameraDistance = round(cameraDistance);
            
            
            for lt=1:length(lensType)
                lensFile = fullfile(rtbsRootPath,'SharedData',sprintf('%s.dat',lensType{lt}));
                
                cameraPosition = zeros(length(cameraDistance)*length(cameraOrientation)*length(cameraHeight)*length(cameraDefocus),3);
                filmDistanceVec = zeros(length(cameraDistance)*length(cameraOrientation)*length(cameraHeight)*length(cameraDefocus),1);
                cameraDistanceVec = zeros(length(cameraDistance)*length(cameraOrientation)*length(cameraHeight)*length(cameraDefocus),1);
                
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
                                
                                filmDistanceVec(loc) = focusLens(lensFile,(max(cameraDistance(cd)+cameraDefocus(cdef),0.1))*1000);
                                cameraDistanceVec(loc) = cameraDistance(cd);
                                
                            end
                        end
                    end
                end
            end
            
            for ao=1:length(carOrientation);
                for p=1:size(cameraPosition,1)
                    for s=1:size(shadowDirection,1)
                        for fn=1:length(fNumber)
                            for cpan=1:length(cameraPan)
                                for ctilt=1:length(cameraTilt)
                                    for croll=1:length(cameraRoll)
                                        for df=1:length(diffraction)
                                            
                                            for mo=1:length(mode)
                                                
                                                
                                                if strcmp(cameraType{lt},'pinhole')
                                                    currentFilmDistance = effectiveFocalLength(lensFile);
                                                else
                                                    currentFilmDistance = filmDistanceVec(p);
                                                end
                                                
                                                cameraLookAt = [carPosition(ap,1:2) cameraHeight];
                                                
                                                fName = sprintf('%05i_city_%i_car_%i_pos_%i_%s_%s_%s_fN_%.2f_dist_%i_diff_%s_chr_%s',...
                                                    sceneID,cityId,carId,ap,cameraType{lt},lensType{lt},mode{mo},fNumber(fn),cameraDistanceVec(p),...
                                                    diffraction{df},chrAber{df});
                                                
                                                values(cntr,1) = {fName};
                                                values(cntr,2) = cameraType(lt);
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
                                                values(cntr,15) = {0};
                                                values(cntr,16) = diffraction(df);
                                                values(cntr,17) = chrAber(df);
                                                values(cntr,18) = num2cell(cameraPan(cpan),1);
                                                values(cntr,19) = num2cell(cameraTilt(ctilt),1);
                                                values(cntr,20) = num2cell(cameraRoll(croll),1);
                                                
                                                cntr = cntr + 1;
                                                
                                                
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
        
        
        rtbWriteConditionsFile(conditionsFile,names,values);
        
        % Generate files and render
        % We parallelize scene generation, not the rendering because PBRT
        % automatically scales the number of processes to equal the nubmer of
        % cores.
        %%
        
        hints.isParallel = true;
        hints.batchRenderStrategy.renderer.dataFileName = sprintf('data_%04i.zip',batchID);
        
        nativeSceneFiles = rtbMakeSceneFiles(scene, 'hints', hints,...
            'conditionsFile',conditionsFile);
        
        
        
        rtbCloudUpload(hints,nativeSceneFiles);
        
        
        %%
        hints.isParallel = false;
        rtbBatchRender(nativeSceneFiles, 'hints', hints);
        
        %%
        batchID = batchID + 1;
    end
end
end


%%
radianceDataFiles = rtbCloudDownload(hints);

%{
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
%}
