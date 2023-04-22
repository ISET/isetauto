% Demonstrate moving the camera position in the vehicle

%  Demonstrate how to move the camera position to the right
%  grille of the vehicle and re-render the scene.
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

% Pick an arbitrary scene/recipe -- default is the one that we've added
% to data/scenes in the ISETAuto repo

% Choose some representative scenes demonstrating the impact of camera
% position depending on which people or vehicles are closest
% Some scenes also require reversing x & y
scenes = {
    {'1112163159', true}, ... close motorcycle
    {'1112160522', true}, ... close person
    {'1113025845', true}, ... close deer
    {'1113014552', false}, ... close car
    {'1113112125', false}   ... close truck
    };

%% Read in the @recipe object
% We can't read back the piWrite()->.pbrt version of our Auto recipes, so
% we need to read the initial @recipe object from the the .mat file

% NOTE: For general use iaFileDataRoot needs to point to the root of where
%       you have access to the scenes (and assets if you don't use remote
%       rendering. It tries to guess, but you can also:
%           setpref('isetauto', 'filedataroot', '<location>')
%       or scenes need to be in your Matlab path.

% We have checked one sample scene into the ISETAuto repo, so you can
% run this script as a tutorial using it without any other setup

for ii=1:numel(scenes)

    % Our @recipe objects are stored in .mat files by sceneID
    recipeFileName = [scenes{ii}{1} '.mat'];

    % if not, look for it where our ISETAuto data is
    % This could also be an isetdb() lookup 
    recipeFolder = fullfile(iaFileDataRoot(), 'Ford','SceneRecipes');
    recipeFile = fullfile(recipeFolder,recipeFileName);

    % The .mat file contains a thisR @recipe inside
    recipeWrapper = load(recipeFile);
    initialRecipe = recipeWrapper.thisR;

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
    recipeSet(initialRecipe,'filmresolution', [480 270]);
    recipeSet(initialRecipe,'rays per pixel', 64);
    recipeSet(initialRecipe, 'nbounces', 3);

    %% NOTE on higher-performance alternative
    %  If we are okay over-writing the output .pbrt we can use the
    %  mainfileonly flag to piWrite() to save the time spent regenerating
    %  the geometry and texture files -- since we are only moving the camera
    %  We'd then need to render each version in turn, as they will write over
    %  each other

    %% Currently we make a full copy of the recipe for our modified camera position
    % Make a copy before we make changes 
    rightGrillRecipe = piRecipeCopy(initialRecipe);

    % Move the camera to the front-right of the car
    % (initial position is behind windshield)
    % x is vertical, y is right, and z is backward
    % unless reversed, then x & y are opposite
    if scenes{ii}{2}
        reverse = -1;
    else
        reverse = 1;
    end
    rightGrillRecipe = piCameraTranslate(rightGrillRecipe, 'x shift', -.5 * reverse, ...
        'y shift', 1 * reverse, 'z shift', -1.5);

    % Give our modified recipe its own output pbrt filename
    rightGrillRecipe.outputFile = fullfile(piDirGet('local'), [sceneID '-rgrill'], [sceneID '-rgrill.pbrt']);

    % Write our recipes to file trees in 'local', so that pbrt can process it
    piWrite(initialRecipe);
    piWrite(rightGrillRecipe);

    % Render our initial scene using the resources already on our server
    initialScene = piRender(initialRecipe, 'remoteResources',true);
    initialImage = sceneShowImage(initialScene,-3);

    % set output folder
    imageFolder = fullfile(iaRootPath, 'local', 'sceneAuto_demo');
    if ~isfolder(imageFolder)
        mkdir(imageFolder);
    end

    imwrite(initialImage,fullfile(imageFolder, [scenes{ii}{1} '-initial.jpg']));
    % Show the result
    %sceneWindow(initialScene);

    % Now render and show our scene with the camera on the right side of the grill
    rightGrillScene = piRender(rightGrillRecipe, 'remoteResources', true);
    rightGrilllImage = sceneShowImage(rightGrillScene,-3);
    imwrite(rightGrilllImage,fullfile(imageFolder,[scenes{ii}{1} '-rgrill.jpg']));
    %sceneWindow(rightGrillScene);
end
