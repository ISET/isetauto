% Test script to see if we can read and render the Ford recipes
% that we have on Acorn:

% Pick an arbitrary scene/recipe from those in isetauto/data
sceneID = '1112194628';

%% Read in the @recipe object
% We can't read back the piWrite() version of a recipe, so
% we need to read the @recipe object from a .mat file
recipeFile = [sceneID '.mat'];
recipeWrapper = load(recipeFile);

% The .mat file includes an @recipe object called thisR
ourRecipe = recipeWrapper.thisR;

%% Fix up our recipe in lieu of piRead()
% Since we aren't/can't use piRead() the normal path fixes for input and
% output have not been applied, so we need to do that manually...

% So the next idea is to set the inputfile to the original base recipe
% file (in the Ford case that is always 1 of 12 road recipes).

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
% We're going to assume they are on our rendering server

% Write our recipe to a file tree, so that pbrt can process it
piWrite(ourRecipe, 'useremoteresources', true);

% Render our recipe into an ISET scene object
scene = piRender(ourRecipe);

% Show the result
sceneWindow(scene);






