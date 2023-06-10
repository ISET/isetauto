function placeAsset(obj, scenario)
% Place an asset in a driving simulation
% 
%   D.Cardinal, Stanford, May, 2023
%

%% For Matlab scenes, we get a scenario along with our object

assetBranchName = [obj.name '_B'];
assetFileName = [obj.name '.pbrt'];

assetRecipe = piRead(assetFileName);

% Adjust for x-axis being towards the car in Ford scenes
% But not in Matlab SDS Scenes!
aType = obj.assetType;
aPosition = obj.position;
aRotation = obj.rotation;

%% For vehicles from Matlab's DSD we need to do this differently
if ~isempty(aPosition)
    piAssetSet(assetRecipe, assetBranchName, 'world coordinates', ...
        aPosition);
    % old way
    % position is where we want to be relative to car in x and y
    % and relative to ground in z
%    assetTranslation(1) = cameraLocation(1) - position(1);
%    assetTranslation(2) = cameraLocation(2) + position(2);
%    assetTranslation(3) = position(3); 
%    assetBranch = piAssetTranslate(assetRecipe,assetBranchName, assetTranslation);
end
if ~isempty(aRotation)
    assetBranch = piAssetRotate(assetRecipe,assetBranchName,rotation);
end

scenario.roadData.recipe = piRecipeMerge(scenario.roadData.recipe, assetRecipe);

end
