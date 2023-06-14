function assetBranch = moveAsset(obj, scenario, actorDS)
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
% Time constant and coordinate reversal
multiplier = scenario.coordinateMapping * scenario.SampleTime;
aMove = actorDS.Velocity .* multiplier;
assetBranch = piAssetTranslate(ourRecipe,assetBranchName,aMove);

% We may not need this anymore
%if actorDS.Velocity(1) < 0 % Cheat for DS being backwards
%    assetBranch = piAssetRotate(ourRecipe,assetBranchName,...
%        [0 0 180]);
%end


%% NEED TO ADD SUPPORT FOR TURNING
%if ~isempty(aYaw)
%    assetBranch = piAssetRotate(assetRecipe,assetBranchName,...
%        [0 0 aYaw]);
%end

end
