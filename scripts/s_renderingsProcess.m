% This script reads rendered EXR files from PBRT, returns ISET scenes/OIs,
% then save them in outputFolder in .mat format.
% use t_COCOdatasetGeneration.m for annotation generation.
for rr = [9]
datasetFolder = sprintf('/acorn/data/iset/isetauto/Deveshs_assets/ISETScene_%03d_renderings',rr);

sceneNames = dir([datasetFolder,'/*_instanceID.exr']);

outputFolder = sprintf('/acorn/data/iset/isetauto/dataset/skymap_scale10/nighttime_%03d',rr);

if ~exist(outputFolder, 'dir'), mkdir(outputFolder);end

%% Set dataset parameters
params.meanluminance = 5;
% Lights
params.skyL_wt    = 10;
params.headL_wt   = 1;
params.otherL_wt  = 1;
params.streetL_wt = 0.5;
% Optics
params.flare = 1;

% Sensor
params.sensor.name = 'ar0132atSensorRGB';
params.sensor.analoggain = 1;
% IP

%% Generate dataset
parfor ii = 1:numel(sceneNames)

    thisSName = erase(sceneNames(ii).name,'_instanceID.exr');
    scenePath = sprintf('%s/%s.mat',outputFolder, thisSName);

    if exist(scenePath,'file'),continue;end

    if params.skyL_wt>0
%         scene_lg{1} = piEXR2ISET(fullfile(DatasetFolder, 'renderings',[thisSName, '_skymap.exr']),'meanluminance',0);

        sky_energy = piReadEXR(fullfile(datasetFolder, [thisSName, '_skymap.exr']), 'data type','radiance');

%         sky_energy = sky_energy/thisSkyLevel * skyMLum;
%         weights(1) = params.skyL_wt;
    else
        sky_energy = zeros(1080, 1920, 31);
    end
    
    if params.headL_wt>0
%         scene_lg{2} = piEXR2ISET(fullfile(DatasetFolder, 'renderings',[thisSName, '_headlights.exr']),'meanluminance',0);
        headlight_energy = piReadEXR(fullfile(datasetFolder, [thisSName, '_headlights.exr']), 'data type','radiance');
%         weights(2) = params.headL_wt;
    else
        headlight_energy = zeros(1080, 1920, 31);
    end
    
    if params.otherL_wt>0
%         scene_lg{3} = piEXR2ISET(fullfile(DatasetFolder, 'renderings',[thisSName, '_otherlights.exr']),'meanluminance',0);
        otherlight_energy = piReadEXR(fullfile(datasetFolder, [thisSName, '_otherlights.exr']), 'data type','radiance');
%         weights(3) = params.otherL_wt;
    else
        otherlight_energy = zeros(1080, 1920, 31);
    end

    if params.streetL_wt>0
%         scene_lg{4} = piEXR2ISET(fullfile(DatasetFolder, 'renderings',[thisSName, '_streetlights.exr']));
        streetlight_energy = piReadEXR(fullfile(datasetFolder, [thisSName, '_streetlights.exr']), 'data type','radiance');
%         weights(4) = params.streetL_wt;
    else
        streetlight_energy = zeros(1080, 1920, 31);
    end

    % Compose the scene with light groups radiance.
    energy = sky_energy*params.skyL_wt + headlight_energy*params.headL_wt +...
        otherlight_energy*params.otherL_wt + streetlight_energy*params.streetL_wt;
    
    photons  = Energy2Quanta(400:10:700,energy);
    scene    = piSceneCreate(photons);
%     scene = sceneAdd(scene_lg,weights,'add');
%     scene = piAIdenoiseParallel(scene);
    scene = piAIdenoise(scene);
    
%     save(scenePath,'scene','-mat');
    parsave(scenePath, scene, params);
    fprintf('---%d:Saving %s\n',ii,scenePath);
    %{
    scene = sceneAdjustLuminance(scene, params.meanluminance);

    if params.flare>1
        scene = sceneSet(scene, 'distance',0.05);
        sceneSampleSize = sceneGet(scene,'sample size','m');
        [oi,pupilmask, psf] = piFlareApply(scene,...
            'psf sample spacing', sceneSampleSize, ...
            'numsidesaperture', 5, ...
            'psfsize', 1920, 'dirtylevel',0);
        ip = piRadiance2RGB(oi,'etime',1/60,'sensor', params.sensor.name,...
            'analoggain', params.sensor.analoggain);
    else
        oi = piOICreate(scene.data.photons);
        ip = piRadiance2RGB(oi,'etime',1/60,'sensor', params.sensor.name,...
            'analoggain', params.sensor.analoggain);
    end
    radiance = ipGet(ip,'srgb');
    imwrite(radiance, sprintf('%s/%s.png',outputFolder, thisSName));
    %}
%     dataset(ii).name = thisSName;
%     dataset(ii).distance =  ceil(ii/6)*5+5;
    
end

% params.dataset = dataset;
% write dataset parameters out in a json file
% jsonwrite(fullfile(outputFolder,'datasetParams.json'), params);
end
disp('***Scene Processed.***');

%% Run NN on dataset
function parsave(fname, scene, params)
  save('-mat',fname, 'scene','params')
end
