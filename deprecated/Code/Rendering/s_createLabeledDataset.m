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

% mode = 'fullResRGB';
% mode = 'linearRGB';
% mode = 'rawRGB';
mode = 'rawRGB';

dataDir = fullfile('/','share','wandell','data','NN_Camera_Generalization','Renderings',recipe);
renderDir = fullfile('renderings','PBRTCloud');

destDir = fullfile('/','scratch','Datasets',sprintf('%s',recipe));

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
nSkippedImages = 0;
%fig = figure;
for f=1:nFiles
    
    outputFileName = sprintf('%06i',cntr);
    outputXmlFileName = sprintf('%s.xml',outputFileName);
    outputJpegFileName = sprintf('%s.png',outputFileName);
    
    %% Load image radiance data
    radianceDataFileName = scenes(shuffling(f)).radiance;  
    meshDataFileName = scenes(shuffling(f)).mesh;

    if ~exist(radianceDataFileName,'file') || ~exist(meshDataFileName,'file')
        fprintf('Either radiance or mesh info is missing. \n');
        nSkippedImages = nSkippedImages + 1;
        estFiles = nTestFiles/testFraction;
        estFiles = estFiles - 1;
        nTestFiles = estFiles*testFraction;
        continue;
    end
    
    
    name = scenes(shuffling(f)).description;
    
    radianceData = load(radianceDataFileName);
    
    % Create an oi
    oiParams.lensType = scenes(shuffling(f)).lens;
    oiParams.filmDistance = str2double(scenes(shuffling(f)).filmDistance);
    oiParams.filmDiag = str2double(scenes(shuffling(f)).filmDiagonal);
    
    
    
    oi = BuildOI(radianceData.multispectralImage, [], oiParams);
    oi = oiSet(oi,'name',name);
    oi = oiAdjustIlluminance(oi,1000,'mean');
    
    %{
    figure(fig);
    title(name);
    imshow(oiGet(oi,'rgb image'));
    drawnow;
    %}
        
    sensor = sensorCreate('bayer (rggb)');
    sensor = sensorSet(sensor,'name',name);
    sensor = sensorSet(sensor,'size',oiGet(oi,'size'));
    sensor = sensorSet(sensor,'pixel widthandheight',[oiGet(oi,'hres'), oiGet(oi,'wres')]);
    sensor = sensorSet(sensor,'analog gain',1);
    expTime = autoExposure(oi,sensor,1);
    sensor = sensorSet(sensor,'exposure time',expTime);
    sensor = sensorSet(sensor,'quantizationmethod','8 bit');
    
    
    sensor = sensorCompute(sensor,oi);
        
    ip = ipCreate();
    ip = ipSet(ip,'name',name);
    ip = ipCompute(ip,sensor);
    
    switch mode
        case 'sRGB'
            img = ipGet(ip,'data srgb');
        case 'fullResRGB'
            img = oiGet(oi,'rgb image');
        case 'linearRGB'
            img = uint8(ipGet(ip,'sensor channels'));
        case 'rawRGB'
            img = uint8(ipGet(ip,'sensor mosaic'));
            img = repmat(img,[1 1 3]);
    end
    
        
    
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

    %{
        figure(fig);
    for j=1:length(objects)
        pos = [objects{j}.bndbox.xmin objects{j}.bndbox.ymin ...
            objects{j}.bndbox.xmax-objects{j}.bndbox.xmin ...
            objects{j}.bndbox.ymax-objects{j}.bndbox.ymin];
        
        id = strcmp({labelMap(:).name},objects{j}.name);
        rectangle('Position',pos,'EdgeColor',labelMap(id).color);
    end
    drawnow;
    %}
    
    if isempty(objects) 
        fprintf('No Objects in the image, skipping\n');
        nSkippedImages = nSkippedImages + 1;
        estFiles = nTestFiles/testFraction;
        estFiles = estFiles - 1;
        nTestFiles = estFiles*testFraction;
        continue;
    end
        
    
    
    
    %% Save data
    if f < nTestFiles
        % Test set
        currentSet = 'test';
    else
        currentSet = 'trainval';
    end
        
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





