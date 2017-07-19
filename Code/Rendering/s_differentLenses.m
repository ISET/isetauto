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

%% Set-up RenderToolbox4

hints.imageWidth = 640;
hints.imageHeight = 480;
hints.recipeName = 'Car-Different-Lenses'; % Name of the render
hints.renderer = 'PBRT'; % We're only using PBRT right now
hints.copyResources = 1;
hints.isParallel = false;

% Change the docker container
hints.batchRenderStrategy = RtbAssimpStrategy(hints);

hints.batchRenderStrategy.remodelPerConditionAfterFunction = @MexximpRemodellerMoveCar;
hints.batchRenderStrategy.converter = RtbAssimpPBRTConverter(hints);
hints.batchRenderStrategy.converter.remodelAfterMappingsFunction = @PBRTRemodeller;
hints.batchRenderStrategy.converter.rewriteMeshData = false;
hints.batchRenderStrategy.renderer = RtbPBRTRenderer(hints);
hints.batchRenderStrategy.renderer.pbrt.dockerImage = 'vistalab/pbrt-v2-spectral';



%% Simulation parameters

cameraType = {'pinhole','lens','lens'}; 
lensType = {'tessar.22deg.6.0mm','tessar.22deg.6.0mm','2el.XXdeg.6.0mm'};
microlens = {[0,0],[0,0],[0,0]};

mode = {'radiance'};

fNumber = 2.8;
filmDiag = (1/3.6)*25.4;

diffraction = {'false','true'};
chrAber = {'false','true'};

% diffraction = {'false','true'};
% chrAber = {'false','true'};

% Negative z is up.
% Scene is about 200x200m, units are mm.
% However we should specify meters, as they are automatically converted to
% mm in remodellers.

pixelSamples = 128;
shadowDirection = [-0.5 -1 1;];

cameraDistance = [10 20];
cameraOrientation = [0];
cameraPan = [0];
cameraTilt = [0];
cameraRoll = [0];

cameraHeight = -1.5;
cameraDefocus = 0;

nCarPositions = 1;
carOrientation = [30];

maxCars = 1;
maxCities = 1;

names = {'imageName','cameraType','lensType','mode','pixelSamples','filmDist','filmDiag','cameraPosition',...
    'shadowDirection','microlensDim','cameraLookAt','fNumber','carPosition','carOrientation','fog',...
    'diffraction','chromaticAberration','cameraPan','cameraTilt','cameraRoll'};

%% Check
assert(length(cameraType) == length(lensType));
assert(length(cameraType) == length(microlens));
assert(length(diffraction) == length(chrAber));


%% Choose renderer options.


resourceFolder = rtbWorkingFolder('folderName','resources',...
    'rendererSpecific',false,...
    'hints',hints);


% Copy resources
lensFiles = fullfile(lensDir,strcat(lensType,'.dat'));
for i=1:length(lensFiles)
    copyfile(lensFiles{i},resourceFolder);
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
for cityId=1:maxCities
    sceneFile = sprintf('City_%i.obj',cityId);
    parentSceneFile = fullfile(assetDir,'City',sceneFile);
    
    
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
    for i=2:nCarPositions
        carPosition(i,:) = drawCarPosition(cityId);
    end
        
    for carId=1:maxCars
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
        
        for ap=1:nCarPositions;
            
            for lt=1:length(lensType)
                conditionsFile = fullfile(resourceFolder,'Conditions.txt');

                values = cell(1,numel(names));
                cntr = 1;
                
                lensFile = fullfile(lensDir,sprintf('%s.dat',lensType{lt}));
                
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
                                
                                filmDistanceVec(loc) = focusLens(lensFile,(max(cameraDistance(cd)+cameraDefocus(cdef),0.1))*1000);
                                cameraDistanceVec(loc) = cameraDistance(cd);
                                
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
                                                    
                                                    fName = sprintf('%05i_city_%02i_car_%02i_%s_%s_%s_fN_%.2f_diff_%s_chr_%s',...
                                                        sceneID,cityId,carId,cameraType{lt},lensType{lt},mode{mo},fNumber(fn),diffraction{df},chrAber{df});
                                                    
                                                    values(cntr,1) = {fName};
                                                    values(cntr,2) = cameraType(lt);
                                                    values(cntr,3) = lensType(lt);
                                                    values(cntr,4) = mode(mo);
                                                    values(cntr,5) = num2cell(pixelSamples,1);
                                                    values(cntr,6) = num2cell(currentFilmDistance,1);
                                                    values(cntr,7) = num2cell(filmDiag,1);
                                                    values(cntr,8) = {mat2str(cameraPosition(p,:))};
                                                    values(cntr,9) = {mat2str(shadowDirection(s,:))};
                                                    values(cntr,10) = {mat2str(microlens{lt})};
                                                    
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
                
                
                
                rtbWriteConditionsFile(conditionsFile,names,values);
                
                % Generate files and render
                % We parallelize scene generation, not the rendering because PBRT
                % automatically scales the number of processes to equal the nubmer of
                % cores.
                %%
                
                
                nativeSceneFiles = rtbMakeSceneFiles(scene, 'hints', hints,...
                    'conditionsFile',conditionsFile);
                               
                radianceDataFiles = rtbBatchRender(nativeSceneFiles, 'hints', hints);
                
                
                
                for i=1:length(radianceDataFiles)
                    radianceData = load(radianceDataFiles{i});
                    
                    %% Create an oi
                    oiParams.lensType = lensType{lt};
                    oiParams.filmDistance = 10;
                    oiParams.filmDiag = 20;
                    
                    [path, label] = fileparts(radianceDataFiles{i});
                                                            
                    oi = buildOi(radianceData.multispectralImage, [], oiParams);
                    oi = oiSet(oi,'name',label);
                    
                    ieAddObject(oi);
                    oiWindow;
                    
                end
            end
        end
    end
end

