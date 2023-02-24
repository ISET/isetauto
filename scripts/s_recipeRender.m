% Test script to see if we can read and render the Ford recipes
% that we have on Acorn:

recipeWrapper = load('/acorn/data/iset/isetauto/Ford/SceneRecipes/1112154540.mat');

% The .mat file includes an @recipe struct called thisR
ourRecipe = recipeWrapper.thisR;

piWRS(ourRecipe);


