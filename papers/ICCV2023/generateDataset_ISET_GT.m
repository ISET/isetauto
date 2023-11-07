%% generate flare dataset 
sceneDir = '/acorn/data/iset/isetauto/Ford/Flare_paper/SceneMats_002';
sceneNames = load(fullfile(iaRootPath, 'papers/ICCV2023','scenenames_cleanup'));
sceneNames = sceneNames.sceneNameList;
outputDir_flare = '/acorn/data/iset/isetauto/Ford/Flare_paper/Flare_corrupted_wvf';
outputDir_gt = '/acorn/data/iset/isetauto/Ford/Flare_paper/Flare_free_002';

parfor ii = 1:numel(sceneNames)
    thisLoad = load(fullfile(sceneDir, strrep(sceneNames{ii},'.png','.mat')));
    scene    = thisLoad.scene;
    % there are two types of GT, one is through the lens, the other is
    % pinhole only
    imgPath = fullfile(outputDir_gt,sprintf('pixel4a/%s', sceneNames{ii}));
%     if ~exist(imgPath,'file')
    [oi_gt, ~,~]= piFlareApply(scene,'fnumber',1.7,'focal length',4.38e-3,...
        'psfsamplespacing',0.7e-6,'dirtylevel',0); % pixel4a
   
    oi_gt.wAngular = 34.2;
    sensor = sensorCreate('IMX363');
    sensor = sensorSet(sensor,'pixel size same fill factor',1.4*1e-6);

%     exposureTime = autoExposure(oi,sensor,0.90,'weighted','center rect',round([429 351.0000 993 471.0000]));
    sensor = sensorSet(sensor, 'exposure time',1/60);
    oiSize = oiGet(oi_gt,'size');
    sensor = sensorSet(sensor, 'size', oiSize);
%     sensor = sensorCompute(sensor, oi_gt);

    ip = ipCreate;
    ip = ipSet(ip,'conversion method sensor','MCC Optimized');
    ip = ipSet(ip,'illuminant correction method','gray world');
    ip = ipSet(ip,'demosaic method','Adaptive Laplacian');
    ip = ipCompute(ip,sensor);
    rgb= ipGet(ip, 'srgb');
    
    imwrite(rgb, imgPath);
    meanilluminance = oiGet(oi_gt, 'mean illuminance');    
    % pinhole gt
    oi_pinhole = oi_gt;
    oi_pinhole = oiSet(oi_pinhole,'photons',oiCalculateIrradiance(scene,oi_gt));
    oi_pinhole = oiAdjustIlluminance(oi_pinhole, meanilluminance);
    sensor = sensorCompute(sensor, oi_pinhole);
    ip = ipCompute(ip, sensor);
    rgb= ipGet(ip, 'srgb');
    imgPath = fullfile(outputDir_gt, sprintf('pinhole/%s', sceneNames{ii}));
    imwrite(rgb, imgPath);
%     end
end
