function analyzeData(scenario)
%ANALYZEDATA Show results of run
%
% So far we have velocities, but we don't have distance
%

ourData = scenario.logData;

% Calculate distance (per frame?)
%pedLocation = ourData(ii).targetPosition;
%carLocation = ourData(ii).vehiclePosition;

%pedDistance = <vector distance>;

figure;
plot(1:numel(ourData), ourData(:).egoVehicle.Velocity, ourData(:).targetObject.Velocity);

end

