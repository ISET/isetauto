% Test script to see if we can read and render the Ford recipes
% that we have on Acorn:

% Pick an arbitrary scene/recipe -- default is the one that we've added
% to data/scenes in the ISETAuto repo
sceneID = '1112154540';

%% Read in the @recipe object
% We can't read back the piWrite() version of our Auto recipes, so
% we need to read the @recipe object from the initial .mat file

% NOTE: For general use iaFileDataRoot needs to point to the root of where
%       you have access to the scenes (and assets if you don't use remote
%       rendering. It tries to guess, but you can also:
%           setpref('isetauto', 'filedataroot', '<location>')
%       or scenes need to be in your Matlab path.

% We have checked one sample scene into the ISETAuto repo, so you can
% run this script as a tutorial using it without any other setup

% Our @recipe objects are stored in .mat files by sceneID
recipeFileName = [sceneID '.mat'];

% We may have checked this in to the repo or put it in our path
if which(recipeFileName)
    recipeFile = recipeFileName;
else
    % if not, look for it where our ISETAuto data is
    % This could also be an isetdb() lookup 
    recipeFolder = fullfile(iaFileDataRoot(), 'Ford','SceneRecipes');
    recipeFile = fullfile(recipeFolder,recipeFileName);
end

recipeWrapper = load(recipeFile);

% The .mat file includes an @recipe object called thisR
initialRecipe = recipeWrapper.thisR;

%% Fix up our recipe in lieu of piRead()

% Since we aren't/can't use piRead() the normal path fixes for input and
% output have not been applied, so we need to do that manually...
[rPath, rName, rExtension] = fileparts(initialRecipe.inputFile);

% Hack for the road recipe folder structure
assetFolder = iaFileDataRoot('type','PBRT_assets');

% ?? Does the inputfile / original pbrt matter when we do piWrite?
recipePBRT = fullfile(assetFolder, 'road', rName, rName, [rName rExtension]);

% These fixups are normally done by piRead()
% But since we are getting @recipe directly from a .mat file we need
% to handle updating the inputfile and outputfile ourselves.
% ALSO: Auto recipes currently all use one of just a few Road scenes
%       as their inputfile, even though the thousands of scenes are
%       unique.

% Initial Recipe is prior to any edits we make
initialRecipe.inputFile = recipePBRT;
initialRecipe.outputFile = fullfile(piDirGet('local'), sceneID, [sceneID '-initial.pbrt']);

% Scale down the scene resolution to make it faster to render
% (Auto scenes are 1080p native)
recipeSet(initialRecipe,'filmresolution', [480 270])

% Move the camera to the front-right of the car
% initial position is behind windshield
% x is vertical, y is left, and z is forward
rightGrillRecipe = piRecipeCopy(initialRecipe);
rightGrillRecipe = piCameraTranslate(rightGrillRecipe, 'x shift', -.5, ...
    'y shift', -.5, 'z shift', 2);

% Give it its own output pbrt filename
rightGrillRecipe.outputFile = fullfile(piDirGet('local'), [sceneID '-rgrill'], [sceneID '-rgrill.pbrt']);

% Write our recipe to a file tree, so that pbrt can process it
piWrite(initialRecipe);
piWrite(rightGrillRecipe);

% Render our initial scene using the resources already on our server
initialScene = piRender(initialRecipe, 'remoteResources',true);

% Show the result
sceneWindow(initialScene);

% Now render and show our scene with the camera on the right side of the grill
rightGrillScene = piRender(rightGrillRecipe, 'remoteResources', true);
sceneWindow(rightGrillScene);

%% Other experiments
% Experiment with moving the camera above the car
%ourRecipe.lookAt.from(2) = ourRecipe.lookAt.from(2) + 3;
