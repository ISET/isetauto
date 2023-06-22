function analyzeData(scenario)
%ANALYZEDATA Show results of run
%
% So far we have velocities, but we don't have distance
%
%{
% Here is what we get:
logFrame.targetLocation = targetLocation;
logFrame.vehicleLocation = vehicleLocation;
logFrame.vehicleVelocity = vehicleVelocity;
logFrame.targetVelocity = targetVelocity;
logFrame.simulationTime = scenario.SimulationTime;
%}

ourData = scenario.logData;

% Calculate distance (per frame?)
for ii = 1:numel(ourData)
    %pedDistanceVector = abs(pedLocation - carLocation);
    %ourData(ii).pedDistance = pedDistanceVector; % FIND DISTANCE
end

figure;
plot(ourData(:).simulationTime, ourData(:).vehicleVelocity);

end

