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

% Hack for the road recipe folder structure
assetFolder = iaFileDataRoot('type','PBRT_assets');
recipePBRT = fullfile(assetFolder, 'road', rName, rName, [rName rExtension]);

% These fixups are normally done by piRead()
ourRecipe.inputFile = recipePBRT; 
ourRecipe.outputFile = fullfile(piDirGet('local'), sceneID, [sceneID '.pbrt']);

% Other 'assets' need to be in a place where they can be found
% For now a semi-hack:
pbrtAssets = iaFileDataRoot('type', 'PBRT_assets');
addpath(fullfile(pbrtAssets, 'textures'));
addpath(fullfile(pbrtAssets, 'geometry'));
addpath(fullfile(pbrtAssets, 'skymap'));

piWrite(ourRecipe);

%% Try to get the written out recipe to render
% Our first issue is that a lot of the textures get copied to the recipe
% folder, not the textures sub-folder (maybe the ones we found in our
% path?)
% Short term I just brute move them in /local after running piWrite()

% Next issue is that we don't seem to have all the needed meshes:
% [1m[31mError[0m: Couldn't open PLY file "geometry/car_020_body.001_mat0.ply"
% So we try copying all 18GB of meshes to our geometry folder by hand

% Then we get to trickier stuff like this:
% Error[0m: 1112154540_materials.pbrt:2:74: Couldn't find spectrum texture named "road_012_Concrete1.reflectance.Concrete1_Diff.png" for parameter "reflectance"

% Which I think takes someone with more understanding of pbrt recipes ...

%% What we'd like to have work:

scene = piRender(ourRecipe);

sceneWindow(scene);






