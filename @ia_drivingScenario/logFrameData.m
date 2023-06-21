function  logFrameData(scenario, scene)

peds = ismember(labels,'person'); % Any person?
foundPed = max(scores(peds)) > detectionThreshhold; % Are we confident?



% plot time versus distance
%ieNewGraphWin
%plot(runData(:,1),runData(:,2))

% for quick viewing use mmovie
%movie(ourVideo, 10, 1);


end
