function [oi,sensor,ip] = ISETFlareGen(scene,parameters)
    fnumber = parameters.fnumber;
    focallength = parameters.focallength;
    nsides = parameters.nsides;

    imgSize = sceneGet(scene,'size');
    wvf = wvfCreate('spatial samples',ceil(sqrt(imgSize(1)^2+imgSize(2)^2)),'calc wavelengths', [400:10:700]);
    pupilMM = focallength/fnumber * 1e3;
    wvf = wvfSet(wvf,'calc pupil diameter',pupilMM);
    wvf = wvfSet(wvf,'focal length',focallength);

    [aperture] = wvfAperture(wvf,'nsides',nsides,...
        'dot mean',50, 'dot sd',10, 'dot opacity',0.5, 'dot radius',30,...
        'line mean',100, 'line sd', 10, 'line opacity',0.5, 'line width',10);
    wvf = wvfCompute(wvf,'aperture',aperture);
    oi = oiCompute(wvf, scene);
    oi = oiSet(oi,'name','wvf');
    oi = oiCrop(oi,'border');
    
    pixelsize = parameters.pixelsize; % in meters
    
    oi.wAngular = 34.2;
    sensor = sensorCreate('IMX363');
    sensor = sensorSet(sensor,'pixel size same fill factor',pixelsize);

%     exposureTime = autoExposure(oi,sensor,0.90,'weighted','center rect',round([429 351.0000 993 471.0000]));
    sensor = sensorSet(sensor, 'exposure time',parameters.exposuretime);
    oiSize = oiGet(oi,'size');
    sensor = sensorSet(sensor, 'size', oiSize);
    sensor = sensorCompute(sensor, oi);
    ip = ipCreate;
    ip = ipSet(ip,'conversion method sensor','MCC Optimized');
    ip = ipSet(ip,'illuminant correction method','gray world');
    ip = ipSet(ip,'demosaic method','Adaptive Laplacian');
    ip = ipCompute(ip,sensor);
end

