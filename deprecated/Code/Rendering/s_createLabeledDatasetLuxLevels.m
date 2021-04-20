% This script reads in the sensor irradiance data generated with RTB4+PBRT,
% simulates the images some camera would produce and arranges images and labels
% in a format that matches that of PASCAL VOC datasets.
%
% Copytight, Henryk Blasinski 2017.

close all;
clear all;
clc;

ieInit;

testFraction = 0.3;

recipe = 'MultiObject-Pinhole';
dataDir = fullfile('/','share','wandell','data','NN_Camera_Generalization','Renderings',recipe);
renderDir = fullfile('renderings','PBRTCloud');
destDir = fullfile('/','scratch','Datasets',recipe);

lightLevels = [0.01 0.1 1 10 100 1000 10000];
expTime = [0.002, 0.015];
subMode = 'rawRGB';

numSaturated = zeros(793,length(lightLevels));
numUnderexposed = zeros(793,length(lightLevels));



cmap = jet(3);
%These class ids correspond to the ones from PASCAL VOC
labelMap(1).name = 'car';
labelMap(1).id = 7;
labelMap(1).color = cmap(1,:);
labelMap(2).name = 'person';
labelMap(2).id = 15;
labelMap(2).color = cmap(2,:);
labelMap(3).name = 'bus';
labelMap(3).id = 6;
labelMap(3).color = cmap(3,:);

for ll=1:length(lightLevels)
    
    mode = sprintf('%s',subMode);
    
    for jj=1:length(expTime)
        mode = sprintf('%s_%i',mode,expTime(jj)*1000);
    end
    mode = sprintf('%s_luxLevel_%.1f',mode,lightLevels(ll));
    
        
    % Prepare the directory structure
    xVal = {'trainval','test'};
    for i=1:length(xVal)
        dirName = fullfile(destDir,xVal{i},mode,'Annotations');
        if exist(dirName,'dir') == false, mkdir(dirName); end;
        dirName = fullfile(destDir,xVal{i},mode,'JPEGImages');
        if exist(dirName,'dir') == false, mkdir(dirName); end;
        dirName = fullfile(destDir,xVal{i},mode,'ImageSets','Main');
        if exist(dirName,'dir') == false, mkdir(dirName); end;
    end
    
    % Prepare files listing which image contains which class
    fids = cell(length(xVal),length(labelMap));
    for x=1:length(xVal)
        for v=1:length(labelMap)
            
            fName = fullfile(destDir,xVal{x},mode,'ImageSets','Main',sprintf('%s_%s.txt',lower(labelMap(v).name),xVal{x}));
            fids{x,v} = fopen(fName,'w');
            
        end
    end
    
    % Create a label map file
    fName = fullfile(destDir,sprintf('%s_label_map.pbtxt',recipe));
    fid = fopen(fName,'w');
    fprintf(fid,'item {\n   id: 0\n   name: ''none_of_the_above''\n}\n\n');
    
    for i=1:length(labelMap)
        fprintf(fid,'item {\n   id: %i\n   name: ''%s''\n}\n\n',labelMap(i).id,lower(labelMap(i).name));
    end
    fclose(fid);
    
    %%
    
    scenesFile = fullfile(dataDir,'scenes.mat');
    
    if exist(scenesFile,'file')
        load(scenesFile);
    else
        
        condFiles = dir(fullfile(dataDir,'resources','*.txt'));
        conditionFiles = cell(length(condFiles),1);
        for i=1:length(condFiles)
            conditionFiles{i} = fullfile(dataDir,'resources',condFiles(i).name);
        end
        
        scenes = assembleSceneFiles(fullfile(dataDir,renderDir),[],[],'conditionFiles',conditionFiles);
        save(scenesFile,'scenes');
    end
    
    nFiles = length(scenes);
    nTestFiles = nFiles * testFraction;

    
    rng(1);
    shuffling = randperm(nFiles);
    
    cntr = 1;
    for f=1:nFiles
        
        outputFileName = sprintf('%06i',cntr);
        outputXmlFileName = sprintf('%s.xml',outputFileName);
        outputJpegFileName = sprintf('%s.png',outputFileName);
        
        

        
        
        %% Load image radiance data
        radianceDataFileName = scenes(shuffling(f)).radiance;
        meshDataFileName = scenes(shuffling(f)).mesh;
        
        if ~exist(radianceDataFileName,'file') || ~exist(meshDataFileName,'file')
            fprintf('Either radiance or mesh info is missing. \n');
            estFiles = nTestFiles/testFraction;
            estFiles = estFiles - 1;
            nTestFiles = estFiles*testFraction;
            continue;
        end
        
        name = scenes(shuffling(f)).description;
        
        
        %% Load image radiance data
        
        radianceData = load(radianceDataFileName);
        
        % Create an oi
        oiParams.lensType = scenes(shuffling(f)).lens;
        oiParams.filmDistance = str2double(scenes(shuffling(f)).filmDistance);
        oiParams.filmDiag = str2double(scenes(shuffling(f)).filmDiagonal);
        
        
        
        oi = BuildOI(radianceData.multispectralImage, [], oiParams);
        oi = oiSet(oi,'name',name);
        oi = oiAdjustIlluminance(oi,lightLevels(ll),'mean');
        
        % ieAddObject(oi);
        % oiWindow();
        switch subMode
            case {'MC', 'rawMC'}
                sensor = sensorCreate('monochrome');
                wave = sensorGet(sensor,'wave');
                fName = fullfile(isetRootPath,'data','sensor','photodetectors','photodetector.mat');
                qe = ieReadSpectra(fName,wave);
                sensor = sensorSet(sensor,'filter spectra',qe);
            otherwise
                sensor = sensorCreate('bayer (rggb)');
        end
        sensor = sensorSet(sensor,'name',name);
        sensor = sensorSet(sensor,'size',oiGet(oi,'size'));
        sensor = sensorSet(sensor,'pixel widthandheight',[oiGet(oi,'hres'), oiGet(oi,'wres')]);
        sensor = sensorSet(sensor,'analog gain',1);
        sensor = sensorSet(sensor,'quantizationmethod','8 bit');
        
        
        for ff=1:length(expTime)
            sensor = sensorSet(sensor,'exposure time',expTime(ff));
            sensors(ff) = sensorCompute(sensor,oi);
        end
        
        
        volts = sensorGet(sensors(1),'volts');
        cfaPattern = sensorGet(sensors(1),'cfa pattern');
        cfaHeight = size(cfaPattern,1);
        for kk=1:length(expTime)
                subPhotons = sensorGet(sensors(kk),'volts');
                for zz=1:cfaHeight
                    volts(kk+zz-1:cfaHeight*length(expTime):end,:) = subPhotons(kk+zz-1:cfaHeight*length(expTime):end,:);
                end
        end
        sensor = sensorSet(sensor,'volts',volts);
        sensor = sensorSet(sensor,'dv',analog2digital(sensor,'linear'));
        
        % ieAddObject(sensor);
        % sensorWindow();
        
        
        
        ip = ipCreate();
        ip = ipSet(ip,'name',name);
        ip = ipCompute(ip,sensor);
        % ieAddObject(ip);
        % ipWindow();
        
        switch subMode
            case {'sRGB', 'MC'}
                img = ipGet(ip,'data srgb');
            case 'fullResRGB'
                img = oiGet(oi,'rgb image');
            case 'linearRGB'
                img = uint8(ipGet(ip,'sensor channels'));
            case {'rawRGB', 'rawMC'}
                img = uint8(ipGet(ip,'sensor mosaic'));
                img = repmat(img,[1 1 3]);
                
                nUnderexp = img < 0.01*255;
                nUnderexp = sum(nUnderexp(:))/3;
                
                nOverexp = img > 0.99*255;
                nOverexp = sum(nOverexp(:))/3;
        end
        
        
        img = uint8(255*double(img)/max(double(img(:))));
        
        
        %% Labels
        [~, inputFileName] = fileparts(meshDataFileName);
        [labels, instances] = mergeMetadataMultiInstance(meshDataFileName,labelMap);
        
        objects = getBndBox(labels, instances, labelMap);
        
        annotation.folder = mode;
        annotation.filename = outputJpegFileName;
        annotation.source.annotation = sprintf('%s.mat',strrep(name,'radiance','mesh'));
        annotation.source.database = recipe;
        annotation.source.image = inputFileName;
        
        annotation.size.depth = size(img,3);
        annotation.size.height = size(img,1);
        annotation.size.width = size(img,2);
        
        annotation.object = objects(:);
        
        
        if isempty(objects)
            fprintf('No Objects in the image, skipping\n');
            estFiles = nTestFiles/testFraction;
            estFiles = estFiles - 1;
            nTestFiles = estFiles*testFraction;
            continue;
        end
 
        if f < nTestFiles
            % Test set
            currentSet = 'test';
            numSaturated(f,ll) = nOverexp;
            numUnderexposed(f,ll) = nUnderexp;
            
            
        else
            currentSet = 'trainval';
        end
        
        
        
        
        outputJpegFullFileName = fullfile(destDir,currentSet,mode,'JPEGImages',outputJpegFileName);
        outputXmlFullFileName = fullfile(destDir,currentSet,mode,'Annotations',outputXmlFileName);
        
        imwrite(img,fullfile(destDir,currentSet,mode,'JPEGImages',outputJpegFileName));
        s.annotation = annotation;
        struct2xml(s,fullfile(destDir,currentSet,mode,'Annotations',outputXmlFileName));
       
        
        sel = cellfun(@(x) strcmp(x,currentSet),xVal);
        
        for c=1:length(labelMap)
            objectPresence = -1;
            for o=1:length(annotation.object)
                if strcmpi(labelMap(c).name,annotation.object{o}.name)
                    objectPresence = 1;
                end
            end
            fprintf(fids{sel,c},'%s %i\n',outputFileName,objectPresence);
        end
        
        cntr = cntr + 1;
    end
    
    % Close files
    for i=1:numel(fids)
        fclose(fids{i});
    end
    
end

save(sprintf('Sat_stat_%s.mat',subMode),'numSaturated','numUnderexposed');


