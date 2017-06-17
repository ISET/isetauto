close all;
clear all;
clc;

ieInit;

dataDir = fullfile('/','home','hblasins','Documents','MATLAB','render_toolbox','City-Car-Distance');
renderDir = fullfile('renderings','PBRT');

destDir = fullfile('/','share','wandell','users','hblasins','DifferentCameras');
if exist(destDir,'dir') == false
    mkdir(destDir);
end

cameras = {'AptinaMT9M031','AptinaMT9M131',...
    'Canon1DMarkIII','Canon5DMarkII','Canon20D','Canon40D','Canon50D','Canon60D','Canon300D','Canon500D','Canon600D'...
    'HasselbladH2',...
    'NikonD1','NikonD3','NikonD3X','NikonD40','NikonD50','NikonD70','NikonD80','NikonD90','NikonD100','NikonD200',...
    'NikonD200IR','NikonD300s','NikonD700','NikonD5100',...
    'NokiaN900',...
    'OlympusE-PL2',...
    'PentaxK-5','PentaxQ',...
    'PhaseOne',...
    'PointGreyGrasshopper50S5C','PointGreyGrasshopper214S5C',...
    'SONYNEX-5N'};


   
     fName = fullfile(dataDir,renderDir,'001_city_1_car_1_pinhole_dgauss.22deg.12.5mm_radiance_fN_2.80_dist_10.mat');
     radianceData = load(fName);
    
    
    %% Create an oi
    oiParams.lensType = 'pinhole';
    oiParams.filmDistance = 10;
    oiParams.filmDiag = 20;
    
    label = 'City';
    
    oi = BuildOI(radianceData.multispectralImage, [], oiParams);
    oi = oiSet(oi,'name',label);
    oi = oiAdjustIlluminance(oi,100,'mean');
    
    ieAddObject(oi);
    oiWindow;
    
    for c=1:length(cameras)
        
        ft = ieReadColorFilter(400:10:700,fullfile(isetRootPath,'data','sensor','colorfilters',sprintf('%s.mat',cameras{c})));
        ft(isnan(ft)) = 0;
        
        sensor = sensorCreate('bayer (rggb)');
        sensor = sensorSet(sensor,'filter transmissivities',ft);
        sensor = sensorSet(sensor,'size',oiGet(oi,'size'));
        sensor = sensorSet(sensor,'pixel widthandheight',[oiGet(oi,'hres'), oiGet(oi,'wres')]);
        expTime = autoExposure(oi,sensor,0.95);
        sensor = sensorSet(sensor,'exposure time',expTime);
        
        sensor = sensorCompute(sensor,oi);
        ieAddObject(sensor);
        sensorWindow;
        
        ip = ipCreate();
        ip = ipCompute(ip,sensor);
        ieAddObject(ip);
        ipWindow();
        
        
        image = ipGet(ip,'data srgb');
        % figure;
        % imshow(image);
        imwrite(image,fullfile(destDir,sprintf('%s.png',cameras{c})));
    end
    
