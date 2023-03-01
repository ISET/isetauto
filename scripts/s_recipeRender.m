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





% The .mat file includes an @recipe struct called thisR
ourRecipe = recipeWrapper.thisR;

%% Fix up our recipe in lieu of piRead()
% Since we aren't/can't use piRead() the normal path fixes for input and
% output have not been applied, so we need to do that manually...

% So the next idea is to set the inputfile to the original base recipe
% file (in the Ford case that is always 1 of 12 road recipes).
% Here is an example of what is coded in the @recipe:
% '/Volumes/SSDZhenyi/Ford Project/PBRT_assets/road/road_012/road_012/road_012.pbrt'

[rPath, rName, rExtension] = fileparts(ourRecipe.inputFile);

% Experiment with moving the camera above the car
ourRecipe.lookAt.from(2) = ourRecipe.lookAt.from(2) + 3;


% Hack for the road recipe folder structure
assetFolder = iaFileDataRoot('type','PBRT_assets');
recipePBRT = fullfile(assetFolder, 'road', rName, rName, [rName rExtension]);

% Failed Experiment: What if we use the version created by piWrite as our
% pbrt file -- Oops, piWriteCopy then pulls everything ...
%recipePBRT = fullfile(recipeFolder, [sceneID '.pbrt']);

% These fixups are normally done by piRead()
ourRecipe.inputFile = recipePBRT; 
ourRecipe.outputFile = fullfile(piDirGet('local'), sceneID, [sceneID '.pbrt']);

piWrite(ourRecipe);

%% Try to get the written out recipe to render
% Our first issue is that a lot of the textures get copied to the recipe
% folder, not the textures sub-folder (maybe the ones we found in our
% path?)
% Short term I just brute move them in /local after running piWrite()


% Then we find the same issue with missing textures, so we copy all of 
% those into our scene in local by hand

% Then we get to trickier stuff like this:

%% What we'd like to have work:

scene = piRender(ourRecipe);

% Show the result
sceneWindow(scene);






