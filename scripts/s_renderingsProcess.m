% This script reads rendered EXR files from PBRT, returns ISET scenes/OIs,
% then save them in outputFolder in .mat format.
% use t_COCOdatasetGeneration.m for annotation generation.

% Runtime is dominated by the Intel AI Denoiser, plus exrread & save

% Set initial locations -- Hard-coded for now!
if ispc
    % a WebDAV mount
    datasetRootPath = 'V:\data\iset\isetauto';
    % pick a folder that's downloaded
    renderFolders = [6];
    maxScenes = 2; % for testing

else
    % assume Mux or similar
    datasetRootPath = '/acorn/data/iset/isetauto';
    % Zhenyi's current test set
    renderFolders = [9];
    maxScenes = -1;
end

%% Set dataset parameters for this run
% These appear constant so define them at the top
params.meanluminance = 5;
% Lights
params.skyL_wt    = 10;
params.headL_wt   = 1;
params.otherL_wt  = 1;
params.streetL_wt = 0.5;
% Optics
params.flare = 1;

% Sensor
% I think sensor is only used in the code currently commented out
% at the bottom for flare testing, and we are typically creating "raw" scenes.
% Maybe put that code in a sub-function as an option?
params.sensor.name = 'ar0132atSensorRGB';
params.sensor.analoggain = 1;

% Process one or more of the rendered directories
for rr = renderFolders(1):renderFolders(end)
    processFolder = sprintf('ISETScene_%03d_renderings', rr);
    datasetFolder = fullfile(datasetRootPath,'Deveshs_assets',processFolder);

    sceneNames = dir(fullfile(datasetFolder,'*_instanceID.exr'));

    % For testing allow limiting number of scenes
    if maxScenes > 0
        sceneNames = sceneNames(28:29);
    end

    % Select a folder to contain all processed scenes
    % using these parameters
    experimentFolderName = 'skymap_scale10';

    % Then group by the ##
    sceneOutputFolder = sprintf('nighttime_%03d',rr);
    outputFolder = fullfile(datasetRootPath,...
        'dataset',experimentFolderName,sceneOutputFolder);

    if ~exist(outputFolder, 'dir'), mkdir(outputFolder);end


    scene = []; % initialize to keep parfor happy
    photons = []; % keep parfor happy

    %% Generate dataset
    % USE PARFOR for performance, for for debugging...
    parfor ii = 1:numel(sceneNames)
        %for ii = 1:numel(sceneNames)

        thisSName = erase(sceneNames(ii).name,'_instanceID.exr');
        scenePath = fullfile(outputFolder, [thisSName '.mat']);

        % by default we don't regenerate output files
        if exist(scenePath,'file'),continue;end

        % Combine pre-rendered .exr files (which each have one type of
        % light source) into the desired combination.
        if params.skyL_wt > 0
            %         scene_lg{1} = piEXR2ISET(fullfile(DatasetFolder, 'renderings',[thisSName, '_skymap.exr']),'meanluminance',0);

            sky_energy = piReadEXR(fullfile(datasetFolder, [thisSName, '_skymap.exr']), 'data type','radiance');

            %         sky_energy = sky_energy/thisSkyLevel * skyMLum;
            %         weights(1) = params.skyL_wt;
        else
            sky_energy = zeros(1080, 1920, 31);
        end

        % Auto Headlights
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

        % Street Lamps
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

        wavelengths = 400:10:700;

        %{ 
        % try doing the scene create ourselves, maybe to
        % save some overhead?
        %scene = sceneCreate('empty');
        %scene = sceneSet(scene, 'wavelength', wavelengths);
        % set wavelengths but clear surfaceFile
        scene = sceneCreate('dark',[],wavelengths, '');
        scene = sceneClearData(scene);
        scene = sceneSet(scene,'photons',photons);
        patchSize = 8;
        % [r,c] = size(photons(:,:,1));
        %}

        photons  = Energy2Quanta(wavelengths,energy);
        scene    = piSceneCreate(photons);

        % Give the scene a better name than the default
        scene = sceneSet(scene,'scene name', thisSName);

        % Keep the lighting params with the scene, making it easier
        % to read them into a db later on
        scene.metadata.lightingParams = params;

        %     scene = sceneAdd(scene_lg,weights,'add');
        %     scene = piAIdenoiseParallel(scene);
        if ispc
            useNvidia = false; % see if Intel also allows single channel
            scene = piAIdenoise(scene, 'quiet', true, 'useNvidia', useNvidia);
        else
            scene = piAIdenoise(scene, 'quiet', true, 'useNvidia', false);
        end
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
save('-mat',fname, 'scene','params');
end
