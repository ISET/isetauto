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
% D. Cardinal, Stanford University, 2023

useArgs = [];
useArgs = [useArgs, 'experimentname', sprintf('%s',datetime('now','Format','yy-MM-dd-HH-mm'))];

% Set mean illuminance
useArgs = [useArgs, 'meanluminance', 5]; % Default is currently night time

% Set lighting weights

useArgs = [useArgs, 'skyl_wt', 10];
useArgs = [useArgs, 'headl_wt', 1];
useArgs = [useArgs, 'otherl_wt', 1];
useArgs = [useArgs, 'streetl_wt',0.5];

% We can also add flare simulation via the Optics
% Although currently this doesn't get used
useArgs = [useArgs, 'flare', 1];

% Choose folder of rendered files to turn into scenes

% Now execute the conversion. This can take a long time.
result = makeScenesFromRenders(renderFolder, useArgs);
