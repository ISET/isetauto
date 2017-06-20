close all;
clear all;
clc;

ieInit;

recipe = 'Car-Complete-Pinhole';

dataDir = fullfile('/','share','wandell','data','NN_Camera_Generalization','Renderings',recipe);
renderDir = fullfile('renderings','PBRTCloud');
destDir = fullfile(dataDir,'images');

fileNames = dir(fullfile(dataDir,renderDir,'*.mat'));


quality = 0:25:100;

if exist(destDir,'dir') == false
    
    mkdir(fullfile(destDir));
    mkdir(fullfile(destDir,'rawSensor'));
    mkdir(fullfile(destDir,'sRgb'));
    
    for q=1:length(quality)
        mkdir(fullfile(destDir,sprintf('sRgbJpeg_%i',quality(q))));
    end

    mkdir(fullfile(destDir,'linearRgb'));
    mkdir(fullfile(destDir,'fullRgb'));
    mkdir(fullfile(destDir,'segmentation'));
    
end

cntr = 1;

for f=1:length(fileNames)
    
    % try
        [pth, name] = fileparts(fileNames(f).name);
        
        
        if isempty(strfind(name,'radiance')),
            continue;
        end
        
        % Load image radiance data
        radianceDataFileName = fullfile(dataDir,renderDir,fileNames(f).name);
        
        radianceData = load(radianceDataFileName);
        
        %% Create an oi
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
        
        fullResImage = oiGet(oi,'rgb image');
        demosaicedImage = double(ipGet(ip,'data srgb'));
        linearImage = ipGet(ip,'data display');
        rawImage = uint8(sensorGet(sensor,'dv'));
        
        imwrite(rawImage,fullfile(destDir,'rawSensor',sprintf('%05i.png',cntr)));
        imwrite(demosaicedImage,fullfile(destDir,'sRgb',sprintf('%05i.png',cntr)));
        
        for q=1:length(quality)
            imwrite(demosaicedImage,fullfile(destDir,sprintf('sRgbJpeg_%i',quality(q)),sprintf('%05i.jpg',cntr)),'Quality',quality(q));
        end
        
        imwrite(linearImage,fullfile(destDir,'linearRgb',sprintf('%05i.png',cntr)));
        imwrite(fullResImage,fullfile(destDir,'fullRgb',sprintf('%05i.png',cntr)));
        
        %% Labels
        
        meshDataFileName = fullfile(dataDir,renderDir,sprintf('%s.mat',strrep(name,'radiance','mesh')));
        labels = uint8(mergeMetadata(meshDataFileName,{'City','Car'})*100);
        
        imwrite(labels,fullfile(destDir,'segmentation',sprintf('%05i.png',cntr)));
    % catch
    %    fprintf('Error processing rendering %s\n',name);
    % end
    
    %% Cleanup
    
    cntr = cntr + 1;
    
    vcDeleteSomeObjects('oi',1:length(vcGetObjects('oi')));
    vcDeleteSomeObjects('sensor',1:length(vcGetObjects('sensor')));
    vcDeleteSomeObjects('ip',1:length(vcGetObjects('ip')));
end





