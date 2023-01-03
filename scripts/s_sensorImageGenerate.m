% Process metric scene data and plot performance curve
for ss = 1:12
    
datasetFolder = sprintf('/acorn/data/iset/isetauto/dataset/skymap_scale10/nighttime_%03d',ss);

sceneNames = dir([datasetFolder,'/*.mat']);

outputFolder = sprintf('/acorn/data/iset/isetauto/dataset/eval/skymap_scale10/nighttime_processed_noiseFree');

if ~exist(outputFolder, 'dir'), mkdir(outputFolder);end

%% Set dataset parameters
params.meanilluminance = 1;
% Lights
% params.skyL_wt    = 1;
% params.headL_wt   = 1;
% params.otherL_wt  = 0.1;
% params.streetL_wt = 0;
% Optics
params.flare = 1;

% Sensor
params.sensor.name = 'ar0132atSensorRGB';
params.sensor.analoggain = 1/2;
% IP

%% Generate dataset
parfor ii = 1:numel(sceneNames)
    %     if ~any(distance_list(:)==datasetInfo(ii).distance)
    %         continue;
    %     end
    %     thisSName = num2str(datasetInfo(ii).name);
    thisSName = erase(sceneNames(ii).name,'.mat');


    %
    scene = load(sprintf('%s/%s.mat',datasetFolder, thisSName));
    scene = scene.scene;

    if params.flare > 0
        scene = sceneSet(scene, 'distance',0.005);
        sceneSampleSize = sceneGet(scene,'sample size','m');
        [oi,pupilmask, psf] = piFlareApply(scene,...
            'psf sample spacing', sceneSampleSize, ...
            'numsidesaperture', 100,'pupilimagewidth',1920,...
            'psfsize', 1920, 'dirtylevel',0.5,'fnumber',2.5, ...
            'focal length', 6e-3);
    else
        oi = piOICreate(scene.data.photons);
    end
    for ll = [0.1 0.5 1 10]
    outputPath = sprintf('%s/millum%02d/%s.png',outputFolder, ll, thisSName);
    
    if exist(outputPath,'file')
        continue;
    end
    if ~exist(sprintf('%s/millum%02d',outputFolder, ll),'dir')
        mkdir(sprintf('%s/millum%02d',outputFolder, ll));
    end
    oi = oiAdjustIlluminance(oi, ll);

    ip = piRadiance2RGB(oi,'etime',1/60,'sensor', params.sensor.name,...
        'analoggain', params.sensor.analoggain,'noisefree', true);% FOr noise free
    rgb = ipGet(ip,'srgb');
    imwrite(rgb, outputPath);
    end
end
end
% params.dataset = dataset;
% write dataset parameters out in a json file
% jsonwrite(fullfile(outputFolder,'datasetParams.json'), params);

%% Run NN on dataset

