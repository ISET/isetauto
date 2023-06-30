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

% Calculate distance
for ii = 1:numel(ourData)
    vehicleVelocity(ii) = ourData(ii).vehicleVelocity;

    targetRawDistance(ii) = max(0, ourData(ii).targetLocation - ourData(ii).vehicleLocation(1));
    tartetDistance(ii) = sum(targetRawDistance(ii) .^2) ^.5;

    simulationTime(ii) = ourData(ii).simulationTime;

    % Calculate vehicle closing speed
    vehicleClosingVelocity(ii) = vehicleVelocity(ii) - targetVelocity(ii); %#ok<*AGROW>
    vehicleClosingSpeed(ii) = sum(vehicleClosingVelocity(ii) .^ 2) ^.5; %#ok<AGROW>
end


figure('Name',['Initial Speed: ', num2str(scenario.initialSpeed)]); 
yyaxis left;
ylabel('Speed');
plot(simulationTime, vehicleClosingSpeed);
yyaxis right;
xlabel('time (s)');
ylabel('Distance');
plot(simulationTime, targetDistance);
legend('Vehicle Speed','Distance to Pedestrian');

title('Vehicle Speed & Distance to Pedestrian over Time', ...
    ['Start Speed:',num2str(scenario.initialSpeed),', Start Distance: ',num2str(tartetDistance(1))], ...
    'FontSize',12);

end

