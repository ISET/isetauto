% Test script to see if we can read and render the Ford recipes
% that we have on Acorn:

% Pick an arbitrary scene/recipe
sceneID = '1112154540';

%% Read in the @recipe object
% We can't read back the piWrite() version of a recipe, so
% we need to read the @recipe object from a .mat file
recipeFolder = fullfile(iaFileDataRoot(), 'Ford','SceneRecipes');
recipeFile = fullfile(recipeFolder,[sceneID '.mat']);
recipeWrapper = load(recipeFile);

% The .mat file includes an @recipe object called thisR
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

% These fixups are normally done by piRead()
ourRecipe.inputFile = recipePBRT; 
ourRecipe.outputFile = fullfile(piDirGet('local'), sceneID, [sceneID '.pbrt']);

% Other 'assets' need to be in a place where they can be found
% For now add them to our path. In reality they are already on the
% rendering server, but piWrite/piWriteCopy doesn't know that and complains
% if it can't find them on the local machine.
pbrtAssets = iaFileDataRoot('type', 'PBRT_assets');
addpath(fullfile(pbrtAssets, 'textures'));
addpath(fullfile(pbrtAssets, 'geometry'));
addpath(fullfile(pbrtAssets, 'skymap'));

% Write our recipe to a file tree, so that pbrt can process it
piWrite(ourRecipe);

% Render our recipe into an ISET scene object
scene = piRender(ourRecipe);

% Show the result
sceneWindow(scene);






