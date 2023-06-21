function  logFrameData(scenario, scene, detectionResults)

%peds = ismember(labels,'person'); % Any person?
%foundPed = max(scores(peds)) > detectionThreshhold; % Are we confident?

logFrame = [];
logFrame.egoVehicle = scenario.egoVehicle;
logFrame.targetObject = scenario.targetObject;

% maybe find positions here?
ourRecipe = scenario.roadData.recipe;

% egoVehicle seems to be a DS Vehicle, targetObject is an IA actor
assetBranchName = [convertStringsToChars(scenario.egoVehicle.Name) '_B'];
vehicleLocation = ourRecipe.get('asset',assetBranchName,'world position');

assetBranchName = [convertStringsToChars(scenario.targetObject.name) '_B'];
targetLocation = ourRecipe.get('asset',assetBranchName,'world position');

logFrame.targetLocation = targetLocation;
logFrame.vehicleLocation = vehicleLocation;

scenario.logData = [scenario.logData logFrame];


end
