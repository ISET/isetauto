% Break out the task of rendering one or more of the "partial" recipes
% we've built (often one per light source) and rendering them to .EXR
% outputs for further processing.

% D. Cardinal, Stanford University, 2023

% pick a demo recipe
% we should probably get this from isetdb() once we're doing it for real
ourRecipe = fullfile(iaFileDataRoot('local', true),'Ford', 'SceneRecipes','1113191252_skymap.pbrt');

tic
thisR = piRead(ourRecipe);
toc
tic
piWRS(thisR);
toc

