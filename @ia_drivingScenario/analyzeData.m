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
simulationTime = [];
pedestrianDistance = [];

% Calculate distance (per frame?)
for ii = 1:numel(ourData)
    %pedDistanceVector = abs(pedLocation - carLocation);
    %ourData(ii).pedDistance = pedDistanceVector; % FIND DISTANCE
    vehicleForwardVelocity(ii) = ourData(ii).vehicleVelocity(1);
    % Go for x only now, stop at 0
    pedestrianDistance(ii) = max(0, ourData(ii).targetLocation(1) - ourData(ii).vehicleLocation(1));
    simulationTime(ii) = ourData(ii).simulationTime;
end

figure; 
yyaxis left;
ylabel('Speed');
plot(simulationTime, vehicleForwardVelocity);
yyaxis right;
ylabel('Distance');
plot(simulationTime, pedestrianDistance);

title('Vehicle Speed & Distance to Pedestrian over Time');
xlabel('time (s)');
legend('Vehicle Speed','Distance to Pedestrian');

end

