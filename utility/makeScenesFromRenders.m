function foo = makeScenesFromRenders(renders, varargin)
%MAKESCENESFROMRENDERS Create ISET Scene Objects from PBRT .exr files

% This function reads rendered EXR files from PBRT, returns ISET scenes/OIs,
% then saves them in outputFolder in .mat format.

% Runtime is dominated by the Intel AI Denoiser, plus exrread & save
% We've added the option to use the Nvidia Denoiser, for those with a GPU

% The overall intent is to render 3d (pbrt) scenes using various lights
% (for example, natural light, headlights, street lamps, etc.). Those
% renders are stored in hyperspectral .exr format files.
%
% This function combines the various light sources, using the provided
% weights, into an ISET scene object. It represents the radiance from the
% scene and a depth map of objects in the scene. It is not a true 3d
% representation.

% Heavily based on sceneRender script by Zhenyi Liu
% D. Cardinal, Stanford University, 2023
%

p = inputparser();

%% Set dataset parameters for this run
% These appear constant so define them at the top
addParameter(p, 'meanluminance', 5) ; % Default is currently night time

% Light source weightings, Defaults are what was used for Ford Project
addParameter(p, 'skyL_wt', 10);
addParameter(p, 'headL_wt', 1);
addParameter(p,'otherL_wt', 1);
addParameter(p,'streetL_wt',0.5);

% We can also add flare simulation via the Optics
addParameter(p, 'flare', 1);

% convert our args to ieStandard and parse
varargin = ieParamFormat(varargin);
p.parse(varargin{:});

% Set initial locations -- Hard-coded for now!
if ispc
    % a WebDAV mount
    datasetRootPath = 'V:\data\iset\isetauto';
    % for speed of saving use a local SSD
    datasetCachePath = 'B:\data\iset\isetauto';
    % pick a folder that's downloaded
    renderFolders = [6];
    maxScenes = -2; % for testing

else
    % assume Mux or similar
    datasetRootPath = '/acorn/data/iset/isetauto';
    % Zhenyi's current test set
    renderFolders = [9];
    maxScenes = -1;
end

% current location, based on the way Ford has named them
assetFolder = 'Deveshs_assets';

% Note: A Sensor object isn't used by default, we just create a scene
% so those parameters have been moved to the example code for them

% Process one or more of the rendered directories
% That live under the assetFolder. This assumes that the full set of
% original scenes has been rendered into a set of sub-folders of a parent
% render folder:
for rr = renderFolders(1):renderFolders(end)
    processFolder = sprintf('ISETScene_%03d_renderings', rr);
    datasetFolder = fullfile(datasetRootPath,assetFolder,processFolder);

    sceneNames = dir(fullfile(datasetFolder,'*_instanceID.exr'));

    % For testing allow limiting number of scenes
    if maxScenes > 0
        sceneNames = sceneNames(30:34);
    end

    % Select a folder to contain all processed scenes
    % using these parameters
    experimentFolderName = 'skymap_scale10';

    % Then group by the ##
    sceneOutputFolder = sprintf('nighttime_%03d',rr);
    outputFolder = fullfile(datasetCachePath,...
        'dataset',experimentFolderName,sceneOutputFolder);

    if ~exist(outputFolder, 'dir'), mkdir(outputFolder);end


    scene = []; % initialize to keep parfor happy
    photons = []; % keep parfor happy

    %% Generate dataset
    % USE PARFOR for performance, for for debugging...
    % Except we get an error call save for parsave from this loop?
    for ii = 1:numel(sceneNames)
        %for ii = 1:numel(sceneNames)

        thisSName = erase(sceneNames(ii).name,'_instanceID.exr');
        scenePath = fullfile(outputFolder, [thisSName '.mat']);

        % by default we don't regenerate output files
        if exist(scenePath,'file'),continue;end

        % Combine pre-rendered .exr files (which each have one type of
        % light source) into the desired combination.
        if p.Results.skyL_wt > 0
            %         scene_lg{1} = piEXR2ISET(fullfile(DatasetFolder, 'renderings',[thisSName, '_skymap.exr']),'meanluminance',0);

            sky_energy = piReadEXR(fullfile(datasetFolder, [thisSName, '_skymap.exr']), 'data type','radiance');

            %         sky_energy = sky_energy/thisSkyLevel * skyMLum;
            %         weights(1) = params.skyL_wt;
        else
            sky_energy = zeros(1080, 1920, 31);
        end

        % Auto Headlights
        if p.Results.headL_wt > 0
            %         scene_lg{2} = piEXR2ISET(fullfile(DatasetFolder, 'renderings',[thisSName, '_headlights.exr']),'meanluminance',0);
            headlight_energy = piReadEXR(fullfile(datasetFolder, [thisSName, '_headlights.exr']), 'data type','radiance');
            %         weights(2) = params.headL_wt;
        else
            headlight_energy = zeros(1080, 1920, 31);
        end

        if p.Results.otherL_wt > 0
            %         scene_lg{3} = piEXR2ISET(fullfile(DatasetFolder, 'renderings',[thisSName, '_otherlights.exr']),'meanluminance',0);
            otherlight_energy = piReadEXR(fullfile(datasetFolder, [thisSName, '_otherlights.exr']), 'data type','radiance');
            %         weights(3) = params.otherL_wt;
        else
            otherlight_energy = zeros(1080, 1920, 31);
        end

        % Street Lamps
        if p.Results.streetL_wt > 0
            %         scene_lg{4} = piEXR2ISET(fullfile(DatasetFolder, 'renderings',[thisSName, '_streetlights.exr']));
            streetlight_energy = piReadEXR(fullfile(datasetFolder, [thisSName, '_streetlights.exr']), 'data type','radiance');
            %         weights(4) = params.streetL_wt;
        else
            streetlight_energy = zeros(1080, 1920, 31);
        end

        % Compose the scene with light groups radiance.
        energy = sky_energy*params.skyL_wt + headlight_energy*params.headL_wt +...
            otherlight_energy*params.otherL_wt + streetlight_energy*params.streetL_wt;

        % Visual wavelengths by default
        wavelengths = 400:10:700;

        % Create an ISETCam scene based on the combination of light sources
        photons  = Energy2Quanta(wavelengths,energy);
        scene    = piSceneCreate(photons);

        % Give the scene a better name than the default
        scene = sceneSet(scene,'scene name', thisSName);

        % Keep the lighting params with the scene, making it easier
        % to read them into a db later on
        scene.metadata.lightingParams = params;

        % We also need to load a depth map
        scene.depthMap = piReadEXR(fullfile(datasetFolder, [thisSName, '_otherlights.exr']), 'data type','depth');

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
    % this example code actually uses a sensor
    params.sensor.name = 'ar0132atSensorRGB';
    params.sensor.analoggain = 1;

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

end

%% Save Scene so that we can process and/or run a neural net on dataset
function parsave(fname, scene, params)
    save('-mat',fname, 'scene','params');
end
