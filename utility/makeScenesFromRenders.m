function result = makeScenesFromRenders(renderFolders, varargin)
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

p = inputParser();

%% Set dataset parameters for this run
% These are constant for each run so define them at the top
addParameter(p, 'experimentname', sprintf('%s',datetime('now','Format','yy-MM-dd-HH-mm')), @ischar);
addParameter(p, 'meanluminance', 5); % Default is currently night time
addParameter(p, 'outputfolder', '', @ischar); % Default is currently night time

% Light source weightings, Defaults are what was used for Ford Project
% If/when we build other scenes the lighting types should be more general
addParameter(p, 'skyl_wt', 10);
addParameter(p, 'headl_wt', 1);
addParameter(p, 'otherl_wt', 1);
addParameter(p, 'streetl_wt',0.5);
addParameter(p, 'maximages', -1); % By Default process all images
addParameter(p, 'quiet', false); % report each image processed

% We can also add flare simulation via the Optics
addParameter(p, 'flare', 1);

% convert our args to ieStandard and parse
varargin = ieParamFormat(varargin);
p.parse(varargin{:});

% Place lighting parameters in the params struct used with Ford
params.meanLuminance = p.Results.meanluminance;
params.skyL_wt = p.Results.skyl_wt;
params.headL_wt = p.Results.headl_wt;
params.otherL_wt = p.Results.otherl_wt;
params.streetL_wt = p.Results.streetl_wt;
params.flare = p.Results.flare;

% Process the rendered directories (1 or more)
% for now we're assuming just one folder
renderFolders = {renderFolders}; % lame...

for rr = 1:numel(renderFolders)

    sceneNames = dir(fullfile(renderFolders{rr},'*_instanceID.exr'));
    datasetFolder = renderFolders(rr);

    % For testing allow limiting number of scenes
    if p.Results.maximages > 0
        sceneNames = sceneNames(1:p.Results.maximages);
    end

    % Select a folder to contain all processed scenes
    % using these parameters
    if isempty(p.Results.outputfolder)
        if ~isfolder(fullfile(renderFolders{rr}))
            % We can probably skip this render folder
            warning('Folder %s does not exist',fullfile(renderFolders{rr}));
            continue;
        else
            % make a folder at the parent of our SceneEXR folder
            experimentFolder = fullfile(renderFolders{rr}, '..', ['ISETScenes-' p.Results.experimentname]);
            if ~exist(experimentFolder, 'dir'), mkdir(experimentFolder);end
        end
        outputFolder = experimentFolder;
    else
        outputFolder = p.Results.outputfolder;
    end
    if ~exist(outputFolder, 'dir'), mkdir(outputFolder);end


    scene = []; % initialize to keep parfor happy
    photons = []; % keep parfor happy

    % Visual wavelengths by default
    wavelengths = 400:10:700;
    numBands = numel(wavelengths);


    %% Generate dataset
    % USE PARFOR for performance, for for debugging...
    % There may also be an issue when using parfor when we are called
    % from the tutorial script. It claims it can't find our source code?
    parfor ii = 1:numel(sceneNames)
        %for ii = 1:numel(sceneNames)

        thisSName = erase(sceneNames(ii).name,'_instanceID.exr');
        scenePath = fullfile(outputFolder, [thisSName '.mat']);

        % by default we don't regenerate output files
        if exist(scenePath,'file'),continue;end

        % For now parameterize scene size, but assume 1080p
        sceneRez = [1080 1920];

        % Combine pre-rendered .exr files (which each have one type of
        % light source) into the desired combination.
        if params.skyL_wt > 0
            sky_energy = piReadEXR(fullfile(datasetFolder, [thisSName, '_skymap.exr']), 'data type','radiance');
        else
            sky_energy = zeros([sceneRez, numBands]);
        end

        % Auto Headlights
        if params.headL_wt > 0
            headlight_energy = piReadEXR(fullfile(datasetFolder, [thisSName, '_headlights.exr']), 'data type','radiance');
        else
            headlight_energy = zeros([sceneRez, numBands]);
        end

        if params.otherL_wt > 0
            otherlight_energy = piReadEXR(fullfile(datasetFolder, [thisSName, '_otherlights.exr']), 'data type','radiance');
        else
            otherlight_energy = zeros([sceneRez, numBands]);
        end

        % Street Lamps
        if params.streetL_wt > 0
            streetlight_energy = piReadEXR(fullfile(datasetFolder, [thisSName, '_streetlights.exr']), 'data type','radiance');
        else
            streetlight_energy = zeros([sceneRez, numBands]);
        end

        % Compose the scene with light groups radiance.
        energy = sky_energy*params.skyL_wt + headlight_energy*params.headL_wt +...
            otherlight_energy*params.otherL_wt + streetlight_energy*params.streetL_wt;

        % Create an ISETCam scene based on the combination of light sources
        photons  = Energy2Quanta(wavelengths,energy);
        scene    = piSceneCreate(photons);

        % Give the scene a better name than the default
        scene = sceneSet(scene,'scene name', thisSName);

        % Keep the lighting params with the scene, making it easier
        % to read them into a db later on
        scene.metadata.lightingParams = []; %params;

        % We also need to load a depth map
        scene.depthMap = piReadEXR(fullfile(datasetFolder, [thisSName, '_otherlights.exr']), 'data type','depth');

        if ispc
            scene = piAIdenoise(scene, 'quiet', true, 'useNvidia', useNvidia);
        else
            scene = piAIdenoise(scene, 'quiet', true, 'useNvidia', false);
        end

        % Save scene and parameters
        parameterSave(scenePath, scene, params);
        if isequal(p.Results.quiet, false)
            fprintf('---%d:Saving %s\n',ii,scenePath);
        end
    end

    % return how many scenes we've written (in theory at least)
    % Can't use ii because it is used by parfor
    result = numel(sceneNames);

    % params.dataset = dataset;
    % write dataset parameters out in a json file
    % jsonwrite(fullfile(outputFolder,'datasetParams.json'), params);
end

end

%% Save Scene so that we can process and/or run a neural net on dataset
function parameterSave(fname, scene, params)
    save('-mat',fname, 'scene','params');
end
