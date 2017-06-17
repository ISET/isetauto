close all;
clear all;
clc;

ieInit;
recipe = 'Car-Lenses-V3';

dataDir = fullfile('/','home','hblasins','Documents','MATLAB','render_toolbox',recipe);
renderDir = fullfile('renderings','PBRTCloud');

fileNames = dir(fullfile(dataDir,renderDir,'*.mat'));


destDir = fullfile('/','share','wandell','users','shun',recipe);
if exist(destDir,'dir') == false
    mkdir(destDir);
end



lensImage = 1;
pinholeImage = 1;
for i=1:length(fileNames)
    
    fName = fullfile(dataDir,renderDir,fileNames(i).name);
    
    [a, conditionName ] = fileparts(fName);
    conditionName(conditionName == '.') = '-';
    
    radianceData = load(fName);
    
    
    %% Create an oi
    oiParams.lensType = 'pinhole';
    oiParams.filmDistance = 10;
    oiParams.filmDiag = 20;
    
    label = fileNames(i).name;
    
    oi = BuildOI(radianceData.multispectralImage, [], oiParams);
    oi = oiSet(oi,'name',label);
    oi = oiAdjustIlluminance(oi,100,'mean');
    
    ieAddObject(oi);
    oiWindow;
    
    
    if isempty(strfind(fName,'radiance')) == true
        
        labels = mergeMetadata(fName,{'City','Car'});
        labels = labels/max(labels(:));
        imwrite(uint8(labels*255),fullfile(destDir,sprintf('%s.png',conditionName)));

    else
        
        for ex=0
            
            sensor = sensorCreate('bayer (rggb)');
            sensor = sensorSet(sensor,'size',oiGet(oi,'size'));
            sensor = sensorSet(sensor,'pixel widthandheight',[oiGet(oi,'hres'), oiGet(oi,'wres')]);
            expTime = autoExposure(oi,sensor,1.2);
            expTime = expTime*2^ex;
            sensor = sensorSet(sensor,'exposure time',0.0025);
            
            
            sensor = sensorCompute(sensor,oi);
            ieAddObject(sensor);
            sensorWindow;
            
            
            
            ip = ipCreate();
            ip = ipSet(ip,'name',conditionName);
            ip = ipCompute(ip,sensor);
            ieAddObject(ip);
            ipWindow();
            
            
            image = ipGet(ip,'data srgb');
            imwrite(image,fullfile(destDir,sprintf('%s.png',conditionName)));
            
        end
    end
    
    % vcDeleteSomeObjects('oi',1:length(vcGetObjects('oi')));
    % vcDeleteSomeObjects('sensor',1:length(vcGetObjects('sensor')));
    % vcDeleteSomeObjects('ip',1:length(vcGetObjects('ip')));
    
end