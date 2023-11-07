%% Generate ois from renderings
sceneNames = load(fullfile(iaRootPath, 'papers/ICCV2023','scenenames_cleanup'));
sceneNames = sceneNames.sceneNameList;
renderings_dir = '/acorn/data/iset/isetauto/Ford/SceneEXRs';
outputDir = '/acorn/data/iset/isetauto/Ford/Flare_paper/SceneMats_003';mkdir(outputDir);
outputDir_flare = '/acorn/data/iset/isetauto/Ford/Flare_paper/Flare_corrupted_002';mkdir(outputDir_flare);
outputDir_gt = '/acorn/data/iset/isetauto/Ford/Flare_paper/Flare_free_002';mkdir(outputDir_gt);
%%

parfor ii = 1:numel(sceneNames)
    thisName = erase(sceneNames{ii},'.png');
    oiName = fullfile(outputDir, [thisName,'.mat']);
    
    if exist(oiName,'file'), continue; end

    skymap = piEXR2ISET([renderings_dir,'/',thisName,'_skymap.exr']);
    headlight = piEXR2ISET([renderings_dir,'/',thisName,'_headlights.exr'],'meanluminance',0);
    streetlight = piEXR2ISET([renderings_dir,'/',thisName,'_streetlights.exr'],'meanluminance',0);
    otherlight = piEXR2ISET([renderings_dir,'/',thisName,'_otherlights.exr'],'meanluminance',0);

%     wgts = [0.05, 0.01, 0.005,0.01];
    wgts = [0.05/50, 0.01*0.1, 0.005*0.01, 0.05*0.1];
    
    photons = wgts(1)*skymap.data.photons + wgts(2)*headlight.data.photons + ... 
        wgts(3)*streetlight.data.photons + wgts(4)*otherlight.data.photons;
    scene = piSceneCreate(photons);
%     scene = sceneAdd(sceneList,wgts,'add');
    disp('DEBUG!');
    scene = piAIdenoise(scene,'quiet',true);
%     [oi_flare, pupil_mask,psf]= piFlareApply(scene,'fnumber',1.7,'focal length',4.38e-3,'psfsamplespacing',0.25e-6,'dirtylevel',1);
    
    parsave(oiName, scene);
    %{
    dirtyLevel = [0.1, 1, 10];
    for dd = 1:3
%         pixelSize = 1.4;

        [oi_p4a, ~,~]= piFlareApply(scene,'fnumber',1.7,'focal length',4.38e-3,...
            'psfsamplespacing',0.7e-6,'dirtylevel',dirtyLevel(dd)); % pixel4a
        oi_p4a.wAngular = 34.2;

        sensor = sensorCreate('IMX363');
        sensor = sensorSet(sensor,'pixel size same fill factor',1.4*1e-6);
%         exposureTime = autoExposure(oi,sensor, 0.01,'mean');
        sensor = sensorSet(sensor, 'exposure time', 1/60);
        oiSize = oiGet(oi_p4a,'size');
        sensor = sensorSet(sensor, 'size', oiSize);
        sensor = sensorCompute(sensor, oi_p4a);

        ip = ipCreate;
        ip = ipSet(ip,'conversion method sensor','MCC Optimized');
        ip = ipSet(ip,'illuminant correction method','gray world');
        ip = ipSet(ip,'demosaic method','Adaptive Laplacian');

        ip = ipCompute(ip,sensor);
        rgb= ipGet(ip, 'srgb');
        imgPath = fullfile(outputDir_flare,sprintf('pixel4a/drityLevel_%d/%s',dd,sceneNames{ii}));
        try
        mkdir(fullfile(outputDir_flare,sprintf('pixel4a/drityLevel_%d',dd)));
        catch
            % do nothing;
        end
        imwrite(rgb, imgPath);

    end
    % there are two types of GT, one is through the lens, the other is
    % pinhole only
    [oi_gt, ~,~]= piFlareApply(scene,'fnumber',1.7,'focal length',4.38e-3,...
        'psfsamplespacing',0.25e-6,'dirtylevel',0); % pixel4a
   
    oi_gt.wAngular = 34.2;
%     sensor = sensorCreate('IMX363');
%     sensor = sensorSet(sensor,'pixel size same fill factor',1.4*1e-6);
% 
% %     exposureTime = autoExposure(oi,sensor,0.90,'weighted','center rect',round([429 351.0000 993 471.0000]));
%     sensor = sensorSet(sensor, 'exposure time', 1/60);
%     oiSize = oiGet(oi_gt,'size');
%     sensor = sensorSet(sensor, 'size', oiSize);
    sensor = sensorCompute(sensor, oi_gt);

    ip = ipCompute(ip,sensor);
    rgb= ipGet(ip, 'srgb');
    imgPath = fullfile(outputDir_gt,sprintf('pixel4a/%s', sceneNames{ii}));
    imwrite(rgb, imgPath);
    
    meanilluminance = oiGet(oi_gt, 'mean illuminance');

    % pinhole gt
    oi_pinhole = oi_gt;
    oi_pinhole.data.photons = scene.data.photons;
    oi_pinhole = oiAdjustIlluminance(oi_pinhole, meanilluminance);
    sensor = sensorCompute(sensor, oi_pinhole);
    ip = ipCompute(ip,sensor);
    rgb= ipGet(ip, 'srgb');
    imgPath = fullfile(outputDir_gt,sprintf('pinhole/%s', sceneNames{ii}));
    imwrite(rgb, imgPath);
    %}
end

