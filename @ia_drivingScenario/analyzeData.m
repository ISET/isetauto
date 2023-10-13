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
logFrame.targetDistance;
logFrame.detectionResults;
%}

% set these as needed when we first find one!
foundPedPlot = [];
warnPedPlot = [];
crashedPlot = [];
textPedPlot = {};

ourData = scenario.logData;
simulationTime = [];
targetDistance = [];
vehicleVelocity = {};

%% Calculate distance to target
for ii = 1:numel(ourData)
    vehicleVelocity{ii} = ourData(ii).vehicleVelocity;

    targetDistance(ii) = ourData(ii).targetDistance;
    simulationTime(ii) = ourData(ii).simulationTime;

    % Calculate vehicle closing speed
    vehicleClosingVelocity{ii} = vehicleVelocity{ii} - ourData(ii).targetVelocity; %#ok<*AGROW>
    vehicleClosingSpeed(ii) = sum(vehicleClosingVelocity{ii} .^ 2) ^.5; %#ok<AGROW>

    % decide what we want to report about detection status...
    % ... ourData(ii).detectionResults has bboxes, labels, and scores

    if ourData(ii).pedLikelihood > 0
        textPedPlot{end+1} = [simulationTime(ii), ourData(ii).pedLikelihood];
    end
    if isempty(foundPedPlot) && ourData(ii).foundPed
        foundPedPlot = [simulationTime(ii), vehicleClosingSpeed(ii)];
    end
    if isempty(warnPedPlot) && ourData(ii).warnPed
        warnPedPlot = [simulationTime(ii), vehicleClosingSpeed(ii)];
    end
    if isempty(crashedPlot) && ourData(ii).crashed
        crashedPlot = [simulationTime(ii), vehicleClosingSpeed(ii)];
    end
end

%% Write out a video of our run if we recorded one
if numel(scenario.ourVideo) > 0
    open(scenario.v);
    writeVideo(scenario.v, scenario.ourVideo);
    close(scenario.v);
end

%% Show basic statistics and plot of speed vs. distance
figure( 'NumberTitle','off','Name',['PAEB with Headlight: ', scenario.headlampType, ', Initial Speed: ', num2str(scenario.initialSpeed), ' m/s']); 

xlabel('Time (s)');
xlim([0,scenario.StopTime]);

yyaxis left;
ylim([0,scenario.initialSpeed]);
plot(simulationTime, vehicleClosingSpeed);
ylabel('Speed (m/s)');

yyaxis right;
ylim([0,max(targetDistance)]);
plot(simulationTime, targetDistance);
ylabel('Distance (m)');

% Ideally we want to show more than one if they overlap
textAnnotation = '';
% add text annotations
if ~isempty(warnPedPlot)
    text(warnPedPlot(1), warnPedPlot(2),"Alert!");
end
if ~isempty(foundPedPlot)
    % offset if we are already warning
    if ~isempty(warnPedPlot) && isequal(warnPedPlot(1),foundPedPlot(1))
        text(foundPedPlot(1), foundPedPlot(2)-2,"Brake!");
    else
        text(foundPedPlot(1), foundPedPlot(2),"Brake!");
    end
end
if ~isempty(crashedPlot)
    text(crashedPlot(1), crashedPlot(2),"Crash!");
end

for ii = 1:numel(textPedPlot)
    try
        % textPedPlot is time, value
        text(textPedPlot{ii}(1), targetDistance(ii), sprintf("%2.2f",textPedPlot{ii}(2)));
    catch
        warning('problem plotting text');
    end
end

grid on;
legend('Vehicle Speed','Distance to Pedestrian');

title('Vehicle Speed & Distance to Pedestrian over Time', ...
    ['Start -- Speed:',num2str(scenario.initialSpeed(),'%.1f'),', Distance: ',num2str(targetDistance(1),'%.1f'), ...
     ', Threshold: ', num2str(scenario.predictionThreshold,'%.2f'), ', Sensor: ',scenario.sensorModel], ... 
     'FontSize',12);

end

