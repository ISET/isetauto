function assetBranch moveAsset(obj, scenario)
% Place an asset in a driving simulation
% 
%   D.Cardinal, Stanford, May, 2023
%

%% For Matlab scenes, we get a scenario along with our object

assetBranchName = [obj.name '_B'];

ourRecipe = scenario.roadData.recipe;

% Adjust for x-axis being towards the car in Ford scenes
% But not in Matlab SDS Scenes!

%% For vehicles from Matlab's DSD we need to do this differently
if ~isempty(aMove)

    % Time constant and coordinate reversal
    multiplier = scenario.stepTime .* [-1 -1 0];
    aMove = actorDS.Velocity * mutiplier;
    assetBranch = piAssetTranslate(ourRecipe,assetBranchName,aMove);    
end

%% NEED TO ADD SUPPORT FOR TURNING
%if ~isempty(aYaw)
%    assetBranch = piAssetRotate(assetRecipe,assetBranchName,...
%        [0 0 aYaw]);   
%end

scenario.roadData.recipe = piRecipeMerge(scenario.roadData.recipe, assetRecipe);

end
