function  logFrameData(scenario, scene, detectionResults)

%peds = ismember(labels,'person'); % Any person?
%foundPed = max(scores(peds)) > detectionThreshhold; % Are we confident?

logFrame = [];
logFrame.egoVehicle = scenario.egoVehicle;
logFrame.targetObject = scenario.targetObject;

% maybe find positions here?
ourRecipe = scenario.roadData.recipe;
assetBranchName = [scenario.egoVehicle.name '_B'];
vehicleLocation = ourRecipe.get('asset',assetBranchName,'world position');

assetBranchName = [scenario.targetObject.name '_B'];
targetLocation = ourRecipe.get('asset',assetBranchName,'world position');

logFrame.targetLocation = targetLocation;
logFrame.vehicleLodation = vehicleLocation;

scenario.logData(end+1) = logFrame;


end
