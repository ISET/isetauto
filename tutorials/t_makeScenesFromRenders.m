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

% Choose folder of rendered files to turn into scenes
renderFolder = fullfile(iaFileDataRoot, 'xxx');

maxImages = 10; % set for debugging, otherwise < 0 means all
useArgs = {'experimentname', sprintf('%s',datetime('now','Format','yy-MM-dd-HH-mm')), ...
    'skyl_wt', 10, 'meanluminance', 5, 'headl_wt', 1, ...
    'otherl_wt', 1, 'streetl_wt', .5, 'maxImages', maxImages};

% Now execute the conversion. This can take a long time.
result = makeScenesFromRenders(renderFolder, useArgs{:});
