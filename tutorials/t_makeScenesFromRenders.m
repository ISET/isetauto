% Combine rendered .exr files into an ISET scene using weights
%
% This allows us to use a single (expensive-to-render) set of output EXR
% data for multiple scenarios, by changing the weighting on
% the individual light sources.
%
% Currently it assumes the set of light sources we are using now, but
% could easily be modified to support any combination of individual
% radiance files in .exr format.
%
% D. Cardinal, Stanford University, 2023

% Choose folder of rendered files to turn into scenes
% based on our project and scenario
project = 'Ford';
% Original was night time
%scenarioName = sprintf('nighttime_%s',datetime('now','Format','yy-MM-dd-HH-mm'));

% let's try one with more day-like params
scenarioName = sprintf('daytime_20_500');

% Can pass one or more folders to render
% And an output folder name if desired
% 'local' flag is a convenience that allows using a local
% copy of the data files when working remotely
renderFolder = fullfile(iaFileDataRoot('local', true), project, 'SceneEXRs');
outputFolder = fullfile(iaFileDataRoot('local', true), project, 'SceneISET', scenarioName); 

maxImages = 3; % set for debugging, otherwise < 0 means all

% Original nighttime params
%useArgs = {'scenarioname', scenarioName, ...
%    'skyl_wt', 10, 'meanluminance', 5, 'headl_wt', 1, ...
%    'otherl_wt', 1, 'streetl_wt', .5, 'maxImages', maxImages, ...
%    'outputFolder', outputFolder};

% Bump daylight, mean luminance, remove street & headlights
useArgs = {'scenarioname', scenarioName, ...
    'skyl_wt', 20, 'meanluminance', 500, 'headl_wt', 0, ...
    'otherl_wt', 1, 'streetl_wt', 0, 'flare', 0, 'maxImages', maxImages, ...
    'outputFolder', outputFolder, 'useNvidia', false};

% Experiment with creating a scenario object
useScenario = scenario();
useScenario.scenarioName = scenarioName;
useScenario.scenarioProject = project;
useScenario.scenarioType = 'isetscene';
useScenario.scenarioInput = renderFolder;
useScenario.scenarioParameters = useArgs;

% for debugging
%useScenario.print;

% Now execute the conversion. This can take a long time.
result = useScenario.run();
fprintf('Processed %d scenes\n', result);

if result > 0 % it worked so store the scenario
    try
        isetdb().store(useScenario, 'scenarios');
    catch
        % Probably just a duplicate
        % possibly we should do an 'upsert" once we have
        % support for it
    end
end
