% Combine rendered .exr files into an ISET scene using weights
%
% This allows us to use a single (expensive-to-render) set of output EXR
% data for multiple different experiments, by changing the weighting on
% the individual light sources.
%
% Currently it assumes the set of light sources we are using now, but
% could easily be modified to support any combination of individual
% radiance files in .exr format.
%
% NEXT: Decide on a database strategy. I don't know if we always/sometimes
%       want to save the information. It's potentially valuable, of course,
%       but could get cluttered. Maybe a separate call?
%
% D. Cardinal, Stanford University, 2023

% Choose folder of rendered files to turn into scenes
% based on our project and experiment
project = 'Ford';
experimentName = sprintf('nighttime_%s',datetime('now','Format','yy-MM-dd-HH-mm'));

% Can pass one or more folders to render
% And an output folder name if desired
% 'local' flag is a convenience that allows using a local
% copy of the data files when working remotely
renderFolder = fullfile(iaFileDataRoot('local', false), project, 'SceneEXRs');
outputFolder = fullfile(iaFileDataRoot('local', false), project, 'ISETScenes', experimentName); 

maxImages = 4; % set for debugging, otherwise < 0 means all
useArgs = {'experimentname', experimentName, ...
    'skyl_wt', 10, 'meanluminance', 5, 'headl_wt', 1, ...
    'otherl_wt', 1, 'streetl_wt', .5, 'maxImages', maxImages, ...
    'outputFolder', outputFolder};

% Now execute the conversion. This can take a long time.
result = makeScenesFromRenders(renderFolder, useArgs{:});
