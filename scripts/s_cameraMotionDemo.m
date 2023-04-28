%  Demonstrate rendering scenes with the camera in multiple positions.
%
%  By default, render scene(s) with the camera behind the mirror, and
%  then move the camera position to the left and right
%  grille of the vehicle and re-render the scene(s).
%

% NOTE: Our Auto scenes consume around 12GB of GPU memory when
%       rendered on a GPU, so make sure you have one with sufficent VRAM

% NOTE: These are HDR scenes, so they will initially appear black
%       in the scene window until you change the render to HDR
%       (it'd be good to use a param to start with HDR)

% NOTE: If you have access to a server that has ISET resources
%       pre-loaded (like the ones in our lab at Stanford)
%       then you can run this script as is, using 'remoteResources', true
%
%       Otherwise it depends on the assets needed to render the scene

% D.Cardinal, Stanford University, 2023

% Pick @recipe objects for scenes
% 
% To run as a demo using the scene that is checked in to the
% isetauto repo, use this:
scenes = {{'1112154540', 'true'}};

% Otherwise we choose some representative scenes demonstrating the impact of camera
% position depending on which people or vehicles are closest
% Some scenes also require reversing x & y
%{
scenes = {
    {'1112163159', true}, ... close motorcycle
    {'1112160522', true}, ... close person
    {'1113025845', true}, ... close deer
    {'1113014552', false}, ... close car
    {'1113112125', false}   ... close truck
    };
%}
%% Read in the @recipe object
% We can't read back the piWrite()->.pbrt version of our Auto recipes, so
% we need to read the initial @recipe object from the the .mat file

% NOTE: For general use iaFileDataRoot needs to point to the root of where
%       you have access to the scenes (and assets if you don't use remote
%       rendering. It tries to guess, but you can also:
%           setpref('isetauto', 'filedataroot', '<location>')
%       or scenes need to be in your Matlab path.

for ii=1:numel(scenes)

    % Our @recipe objects are stored in .mat files by sceneID
    sceneID = scenes{ii}{1};
    recipeFileName = [sceneID '.mat'];
    % if not, look for it where our ISETAuto data is
    % This could also be an isetdb() lookup 
    if which(recipeFileName)
        recipeFile = which(recipeFileName);
    else
        if ispc % use Google shared drive if needed
            % Hack for PC where we don't have a simple UNC that I've found
            [~, hostName] = system('hostname');
            if isequal(hostName, 'synth')
                recipeFolder = 'G:\Shared drives\ISETData\ISET Scenes -- PBRT Files';
            elseif isequal(hostName, 'decimate')
                recipeFolder = 'D:\Shared drives\ISETData\ISET Scenes -- PBRT Files';
            end
        else
            recipeFolder = fullfile(iaFileDataRoot(), 'Ford','SceneRecipes');
        end
        recipeFile = sprintf('%s',fullfile(recipeFolder,recipeFileName));

    end

    % The .mat file contains a thisR @recipe inside
    initialRecipe = load(recipeFile,'thisR').thisR;

    %% Fix up our recipe in lieu of piRead()
    % These fixups are normally done by piRead()
    % But since we are getting @recipe directly from a .mat file we need
    % to handle updating the inputfile and outputfile ourselves.

    [rPath, rName, rExtension] = fileparts(initialRecipe.inputFile);

    %% Fix the inputfile path to the road recipe used -- may not be needed?
    % ALSO: Auto recipes currently all use one of just a few Road scenes
    %       as their inputfile, even though the thousands of scenes are unique.

    % Fix-up for the road recipe folder structure
    assetFolder = iaFileDataRoot('type','PBRT_assets');

    % This Recipe is prior to any edits we make
    % So we'll call it <sceneID>-initial
    initialRecipe.outputFile = fullfile(piDirGet('local'), sceneID, [sceneID '-initial.pbrt']);

    % OPTIONALLY!
    % Scale down the scene resolution & rays per pixel to make it faster to render
    % For testing purposes. Turn these off for full fidelity!
    % (Most of our Auto scenes are 1080p native)
    %{
    recipeSet(initialRecipe,'filmresolution', [480 270]);
    recipeSet(initialRecipe,'rays per pixel', 64);
    recipeSet(initialRecipe, 'nbounces', 3);
    %}
    % High-fidelity (1080p native, 720p for testing)
    %
    recipeSet(initialRecipe,'filmresolution', [1920 1080]);
    recipeSet(initialRecipe,'rays per pixel', 1024);
    recipeSet(initialRecipe, 'nbounces', 5);
    %

    %% NOTE on higher-performance alternative
    %  If we are okay over-writing the output .pbrt we can use the
    %  mainfileonly flag to piWrite() to save the time spent regenerating
    %  the geometry and texture files -- since we are only moving the camera
    %  We'd then need to render each version in turn, as they will write over
    %  each other

    %% Currently we make a full copy of the recipe for our modified camera position
    % Make a copy before we make changes 
    rGrilleRecipe = piRecipeCopy(initialRecipe);
    lGrilleRecipe = piRecipeCopy(initialRecipe);

    % Move the camera to the front-right of the car
    % (initial position is behind windshield)
    % x is vertical, y is right, and z is backward
    % unless reversed, then x & y are opposite
    if scenes{ii}{2}
        reverse = -1;
    else
        reverse = 1;
    end
    grillShift = [-.5 1 -1.5];
    rGrilleRecipe = piCameraTranslate(rGrilleRecipe, ...
        'x shift', grillShift(1) * reverse, ...
        'y shift', grillShift(2) * reverse, ...
        'z shift', grillShift(3));
    lGrilleRecipe = piCameraTranslate(lGrilleRecipe, ...
        'x shift', grillShift(1) * reverse, ...
        'y shift', grillShift(2) * -1 * reverse, ... % go left
        'z shift', grillShift(3));

    % Give our modified recipe its own output pbrt filename
    rGrilleRecipe.outputFile = fullfile(piDirGet('local'), ...
        [sceneID '-rgrill'], [sceneID '-rgrill.pbrt']);
    lGrilleRecipe.outputFile = fullfile(piDirGet('local'), ...
        [sceneID '-lgrill'], [sceneID '-lgrill.pbrt']);


    % set output folder for our rendered images
    imageFolder = fullfile(iaRootPath, 'local', 'sceneAuto_demo');
    if ~isfolder(imageFolder)
        mkdir(imageFolder);
    end

    moveCamera = false;

    initialScene = renderRecipe(initialRecipe);
    if moveCamera
        rGrilleScene = renderRecipe(rGrilleRecipe);
        lGrilleScene = renderRecipe(lGrilleRecipe);
    end
    imType = '.png'; % Use JPEG for smaller output

    % turn off camera motion to speed up prototyping
    hdr = true;
    if hdr
        exposureTimes = [15 60 120];
    else
        exposureTimes = 20;
    end
        for jj=1:numel(exposureTimes)
            exValue = sprintf('-%s', num2str(exposureTimes(jj)));
            initialImage = createImage(initialScene, exposureTimes(jj));
            imwrite(initialImage,fullfile(imageFolder, [scenes{ii}{1} '-initial-' exValue imType]));
            if moveCamera
                rgrilleImage = createImage(rGrilleScene, exposureTimes(jj));
                lgrilleImage = createImage(lGrilleScene, exposureTimes(jj));
                imwrite(rGrilleImage,fullfile(imageFolder,[scenes{ii}{1} '-rgrill-' exValue imType]));
                imwrite(lGrilleImage,fullfile(imageFolder,[scenes{ii}{1} '-lgrill-' exValue imType]));
            end


        end

    
end

function ourScene = renderRecipe(recipeObject)

    piWrite(recipeObject);
    ourScene = piRender(recipeObject, 'remoteResources',true);
    % Nvidia only works on Windows with GPU
    [ourScene, ~, hdrFile] = piAIdenoise(ourScene,'useNvidia',true, 'keepHDR', true);
    fprintf('HDR file is: %s\n',hdrFile);
end

% Render our scene to a displayable RGB
    function ourImage = createImage(ourScene, exposureFraction)

    % Use one of our automotive sensors
    useSensor = 'ar0132atSensorRGB';

    setMeanIlluminace = 20; % was 5
    ourOI = piOICreate(ourScene.data.photons,'meanilluminance',setMeanIlluminace);

    % meanIllumination = oiGet(oi, 'meanilluminance');
    % fix shutter to 1/30s or HDR
    useExposure = 1/exposureFraction;
    ip = piRadiance2RGB(ourOI,'etime',useExposure,'sensor', useSensor, 'analoggain', 1);
    ourImage = ipGet(ip,'srgb');

    % alternative pipeline
    %ourImage = oiShowImage(ourOI,-5);
    %ourSensor = sensorCompute(useSensor, ourOI);
    %ourImage = sensorSaveImage(ourSensor, savedImageName);

end
