% Test script to see if we can read and render the Ford recipes
% that we have on Acorn:

% Pick an arbitrary scene/recipe
sceneID = '1112154540';
recipeFolder = fullfile(iaFileDataRoot(), 'Ford','SceneRecipes');
recipeFile = fullfile(recipeFolder,[sceneID '.mat']);
recipeWrapper = load(recipeFile);

% The .mat file includes an @recipe struct called thisR
ourRecipe = recipeWrapper.thisR;

% Since we aren't/can't use piRead() the normal path fixes for input and
% output have not been applied (leaving the same as the original authors)


% So the next idea is to set the inputfile to the original base recipe
% file (in the Ford case that is always 1 of 12 road recipes).
% Here is an example of what is coded in the @recipe:
% '/Volumes/SSDZhenyi/Ford Project/PBRT_assets/road/road_012/road_012/road_012.pbrt'

[rPath, rName, rExtension] = fileparts(ourRecipe.inputFile);

% Hack for the road recipe folder structure
assetFolder = iaFileDataRoot('type','PBRT_assets');
recipePBRT = fullfile(assetFolder, 'road', rName, rName, [rName rExtension]);

% Experiment: What if we use the version created by piWrite as our
% pbrt file -- Oops, piWriteCopy then pulls everything ...
%recipePBRT = fullfile(recipeFolder, [sceneID '.pbrt']);

ourRecipe.inputFile = recipePBRT;

ourRecipe.outputFile = fullfile(piDirGet('local'), sceneID, [sceneID '.pbrt']);

piWrite(ourRecipe);

% Our first issue is that a lot of the textures get copied to the recipe
% folder, not the textures sub-folder (maybe the ones we found in our
% path?)
% Short term I just brute move them in /local after running piWrite()

% Next issue is that we don't seem to have all the needed meshes:
% [1m[31mError[0m: Couldn't open PLY file "geometry/car_020_body.001_mat0.ply"
% So we try copying all 18GB of meshes to our geometry folder by hand

% Then we find the same issue with mixing textures, so we copy all of 
% those into our scene in local by hand

% Then we get to trickier stuff like this:
% Error[0m: 1112154540_materials.pbrt:2:74: Couldn't find spectrum texture named "road_012_Concrete1.reflectance.Concrete1_Diff.png" for parameter "reflectance"

% Which I think takes someone with more understanding of pbrt recipes ...


scene = piRender(ourRecipe);

sceneWindow(scene);






