%% generate flare dataset 
sceneDir = '/acorn/data/iset/isetauto/Ford/Flare_paper/SceneMats_003';
sceneNames = load(fullfile(iaRootPath, 'papers/ICCV2023','scenenames_cleanup'));
sceneNames = sceneNames.sceneNameList;
outputDir_flare = '/acorn/data/iset/isetauto/Ford/Flare_paper/Flare_corrupted_compare_001/WVF_exp1p5x';
if ~exist(outputDir_flare, 'dir'), mkdir(outputDir_flare);end
parfor ii = 1:numel(sceneNames)
    t = tic;
    thisLoad = load(fullfile(sceneDir, strrep(sceneNames{ii},'.png','.mat')));
    scene    = thisLoad.scene;
    imgPath = fullfile(outputDir_flare,sprintf('%s', sceneNames{ii}));
    if exist(imgPath,'file'), continue;end
    % Add flare
    fnumber = 1.7;
    flengthM = 4.38e-3;
    nsides = 20;
    
    wvf = wvfCreate('spatial samples',ceil(sqrt(1920^2+1080^2)),'calc wavelengths', [400:10:700]);
    pupilMM = flengthM/fnumber * 1e3;
    wvf = wvfSet(wvf,'calc pupil diameter',pupilMM);
    wvf = wvfSet(wvf,'focal length',flengthM);

    [aperture,params] = wvfAperture(wvf,'nsides',nsides,...
        'dot mean',50, 'dot sd',10, 'dot opacity',0.5, 'dot radius',30,...
        'line mean',100, 'line sd', 10, 'line opacity',0.5, 'line width',10);
    wvf = wvfCompute(wvf,'aperture',aperture);
    oi = oiCompute(wvf, scene);
    oi = oiSet(oi,'name','wvf');
    oi = oiCrop(oi,'border');
    
    oi.wAngular = 34.2;
    sensor = sensorCreate('IMX363');
    sensor = sensorSet(sensor,'pixel size same fill factor',1.4*1e-6);

%     exposureTime = autoExposure(oi,sensor,0.90,'weighted','center rect',round([429 351.0000 993 471.0000]));
    sensor = sensorSet(sensor, 'exposure time',1/10);
    oiSize = oiGet(oi,'size');
    sensor = sensorSet(sensor, 'size', oiSize);
    sensor = sensorCompute(sensor, oi);
    ip = ipCreate;
    ip = ipSet(ip,'conversion method sensor','MCC Optimized');
    ip = ipSet(ip,'illuminant correction method','gray world');
    ip = ipSet(ip,'demosaic method','Adaptive Laplacian');
    ip = ipCompute(ip,sensor);
    rgb= ipGet(ip, 'srgb');
    toc(t)
%     figure(1); tiledlayout(2,1);
%     nexttile; imshow(rgb);
    imwrite(rgb, imgPath);
    % Use piFlareApply with PSF calculated from WVF
%     [oiFA] = piFlareApply(scene,'num sides aperture',nsides, ...
%         'focal length',wvfGet(wvf,'focal length','m'), ...
%         'fnumber',wvfGet(wvf,'fnumber'), 'aperture', aperture);
%     oiFA.wAngular = 34.2;
%     
%     sensorFA = sensorCompute(sensor, oiFA);
%    
%     ipFA = ipCompute(ip,sensorFA);
%     rgbFA= ipGet(ipFA, 'srgb');
%     imgPathFA = fullfile(outputDir_flare,sprintf('piFA/%s', sceneNames{ii}));
%     imwrite(rgbFA, imgPathFA);
%     nexttile; imshow(rgbFA);
end
