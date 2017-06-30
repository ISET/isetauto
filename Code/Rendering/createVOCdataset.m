close all;
clear all;
clc;

ieInit;

testFraction = 0.2;

recipe = 'Car-Complete-Pinhole';
mode = 'fullResRGB';

dataDir = fullfile('/','share','wandell','data','NN_Camera_Generalization','Renderings',recipe);
renderDir = fullfile('renderings','PBRTCloud');

destDir = fullfile('/','scratch','Datasets',recipe);

xVal = {'trainval','test'};
if exist(destDir,'dir') == false
    for i=1:length(xVal)
        mkdir(fullfile(destDir,xVal{i},mode,'ImageSets'));
        mkdir(fullfile(destDir,xVal{i},mode,'JPEGImages'));
    end
end


%%

fileNames = dir(fullfile(dataDir,renderDir,'*radiance*.mat'));
nFiles = length(fileNames);

rng(1);
shuffling = randperm(nFiles);


for f=1:nFiles
    
    outputFileName = sprintf('%06i',f);
    outputXmlFileName = sprintf('%s.xml',outputFileName);
    outputJpegFileName = sprintf('%s.jpg',outputFileName);
    
    inputFileName = fileNames(shuffling(f)).name;
    
    [pth, name] = fileparts(inputFileName);
    
    %% Load image radiance data
    radianceDataFileName = fullfile(dataDir,renderDir,inputFileName);
    
    radianceData = load(radianceDataFileName);
    
    % Create an oi
    oiParams.lensType = 'pinhole';
    oiParams.filmDistance = 10;
    oiParams.filmDiag = 20;
    
    
    
    oi = BuildOI(radianceData.multispectralImage, [], oiParams);
    oi = oiSet(oi,'name',name);
    oi = oiAdjustIlluminance(oi,100,'mean');
    
    ieAddObject(oi);
    % oiWindow();
    
    sensor = sensorCreate('bayer (rggb)');
    sensor = sensorSet(sensor,'name',name);
    sensor = sensorSet(sensor,'size',oiGet(oi,'size'));
    sensor = sensorSet(sensor,'pixel widthandheight',[oiGet(oi,'hres'), oiGet(oi,'wres')]);
    expTime = autoExposure(oi,sensor,1);
    sensor = sensorSet(sensor,'exposure time',expTime);
    sensor = sensorSet(sensor,'quantizationmethod','8 bit');
    
    
    sensor = sensorCompute(sensor,oi);
    ieAddObject(sensor);
    % sensorWindow();
    
    
    
    ip = ipCreate();
    ip = ipSet(ip,'name',name);
    ip = ipCompute(ip,sensor);
    ieAddObject(ip);
    % ipWindow();
    
    switch mode
        case 'fullResRGB'
            img = oiGet(oi,'rgb image');
    end
        
    
    %% Labels
    
    meshDataFileName = fullfile(dataDir,renderDir,sprintf('%s.mat',strrep(name,'radiance','mesh')));
    labels = uint8(mergeMetadata(meshDataFileName,{'City','Car'}));
    
    [bbox, occluded, truncated] = getBndBox(labels,2);
    
    
    annotation.filename = inputFileName;
    annotation.source.annotation = inputFileName;
    annotation.source.database = recipe;
    annotation.source.image = outputFileName;
    
    annotation.size.depth = size(img,3);
    annotation.size.height = size(img,2);
    annotation.size.width = size(img,1);
    
    annotation.object{1}.name = 'city';
    annotation.object{1}.bndbox.xmax = size(img,2);
    annotation.object{1}.bndbox.xmin = 1;
    annotation.object{1}.bndbox.ymax = size(img,1);
    annotation.object{1}.bndbox.ymin = 1;
    annotation.object{1}.difficult = 0;
    annotation.object{1}.occluded = 0;
    annotation.object{1}.pose = 'Unspecified';
    annotation.object{1}.truncated = 0;
    
    
    if isempty(bbox) == false
        annotation.object{2}.name = 'car';
        annotation.object{2}.bndbox.xmax = bbox(1);
        annotation.object{2}.bndbox.xmin = bbox(2);
        annotation.object{2}.bndbox.ymax = bbox(3);
        annotation.object{2}.bndbox.ymin = bbox(4);
        annotation.object{2}.difficult = 0;
        annotation.object{2}.occluded = occluded;
        annotation.object{2}.pose = 'Unspecified';
        annotation.object{2}.truncated = truncated;
    end
    
    %% Save data
    if f < nFiles * testFraction
        % Test set
        
        imwrite(img,fullfile(destDir,'test',mode,'JPEGImages',outputJpegFileName));
        s.annotation = annotation;
        struct2xml(s,fullfile(destDir,'test',mode,'ImageSets',outputXmlFileName));
       
    else
        imwrite(img,fullfile(destDir,'trainval',mode,'JPEGImages',outputJpegFileName));
        s.annotation = annotation;
        VOCwritexml(s,fullfile(destDir,'trainval',mode,'ImageSets',outputXmlFileName));
        
        
    end
    
    
    
    
end





