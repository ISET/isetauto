function analyzeData(scenario)
%ANALYZEDATA Show results of run
%
% So far we have velocities, but we don't have distance
%

ourData = scenario.logData;

% Calculate distance (per frame?)
for ii = 1:numel(ourData)
    pedLocation = ourData(ii).targetLocation;
    carLocation = ourData(ii).vehicleLocation;
    pedDistanceVector = abs(pedLocation - carLocation);
    ourData(ii).pedDistance = pedDistanceVector; % FIND DISTANCE
end
%pedDistance = <vector distance>;

figure;
allVehicles = ourData(1,:);
vehicles = allVehicles(1,:).egoVehicle;
allPeds = ourData(:);
plot(1:numel(ourData), allPeds(:).pedDistance(1));

end

