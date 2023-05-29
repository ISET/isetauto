function [thisR] = iaPlaceAsset(recipe, assetName, position, rotation)
%IAPLACEASSET Quick way to manually place assets in auto scenes
%   Caveat: There might already be some code for this in ISET3d
%           but I couldn't find it
%   Related: It might actually be general enough to put in ISET3d, but
%            wanted to get the ball rolling for Auto stuff
%
%   D.Cardinal, Stanford, May, 2023
%

assetBranchName = [assetName '_B'];
assetFileName = [assetName '.pbrt'];

assetRecipe = piRead(assetFileName);

% We want to translate to a location relative to the camera
% Our assumption is that the asset is at 0,0,0 in the asset recipe
cameraLocation = recipe.lookAt.from;

% Adjust for x-axis being towards the car in Ford scenes

if ~isempty(position)
    % position is where we want to be relative to car in x and y
    % and relative to ground in z
    assetTranslation(1) = cameraLocation(1) - position(1);
    assetTranslation(2) = cameraLocation(2) + position(2);
    assetTranslation(3) = position(3); 
    assetBranch = piAssetTranslate(assetRecipe,assetBranchName, assetTranslation);
end
if ~isempty(rotation)
    assetBranch = piAssetRotate(assetRecipe,assetBranchName,rotation);
end

thisR = piRecipeMerge(recipe, assetRecipe);

end
