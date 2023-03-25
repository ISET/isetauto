% Test script to see if we can read and render the Ford recipes
% that we have on Acorn:

% Pick an arbitrary scene/recipe
sceneID = '1112154540';

%% Read in the @recipe object
% We can't read back the piWrite() version of a recipe, so
% we need to read the @recipe object from a .mat file

% NOTE: iaFileDataRoot needs to point to the root of where
%       you have access to the scenes and assets. It tries
%       to guess, but you can also:
%           setpref('isetauto', 'filedataroot', '<location>')
%
recipeFolder = fullfile(iaFileDataRoot(), 'Ford','SceneRecipes');
recipeFileName = [sceneID '.mat'];

% We may have checked this in to the repo
if which(recipeFileName)
    recipeFile = recipeFileName;
else
    recipeFile = fullfile(recipeFolder,recipeFileName);
end

recipeFolder = '/Volumes/acorn.stanford.edu/Vistalab/data/iset/isetauto/Ford/SceneRecipes';
recipeFile = fullfile(recipeFolder,[sceneID '.mat']);
recipeWrapper = load(recipeFile);

% The .mat file includes an @recipe object called thisR
initialRecipe = recipeWrapper.thisR;

%% Fix up our recipe in lieu of piRead()
% Since we aren't/can't use piRead() the normal path fixes for input and
% output have not been applied, so we need to do that manually...
[rPath, rName, rExtension] = fileparts(initialRecipe.inputFile);

% Hack for the road recipe folder structure
assetFolder = iaFileDataRoot('type','PBRT_assets');
recipePBRT = fullfile(assetFolder, 'road', rName, rName, [rName rExtension]);

% These fixups are normally done by piRead()
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
rightGrillRecipe.outputFile = fullfile(piDirGet('local'), [sceneID '-rgrill'], [sceneID '-rgrill.pbrt']);

% Write our recipe to a file tree, so that pbrt can process it
% setpref('docker','remoteResources', false);
piWrite(initialRecipe);
piWrite(rightGrillRecipe);

initialScene = piRender(initialRecipe);
% Show the result
sceneWindow(initialScene);

rightGrillScene = piRender(rightGrillRecipe);
sceneWindow(rightGrillScene);








