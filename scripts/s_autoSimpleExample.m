%% s_autoSimpleExample
%
% Read an existing recipe of an auto scene that was stored as a Matlab
% recipe.  These recipes are part of the ISETAuto database.
%
% See also 
%   s_recipeRender
%

%% Initialize ISETCam and docker path
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Pick an arbitrary scene/recipe 

% This recipe is part of the data/scenes in the ISETAuto repo.  Most of the
% recipes are stored elsewhere.
%sceneID = '1112154540';
sceneID = 'road_001';
%sceneID = 'road_001_textures';
recipeFileName = [sceneID '.mat'];

% The variable with this recipe is thisR.
load(recipeFile,'thisR');

%% Adjust the recipe output directory.

% The person who created that file had different input/output directories.
% We adjust for the current user.
[rPath, rName, rExtension] = fileparts(thisR.get('input file'));

% We'll call it <sceneID>-initial and put it in the user's ISET3d/local/
% directory so it will not be part of the git repository.
thisR.set('output file',fullfile(piDirGet('local'), sceneID, [sceneID '-initial.pbrt']));

% Set the resolution & rays per pixel 
% For testing purposes we make these numbers small.
% (Auto scenes are typically rendered at 1080p (1920,1080).
%thisR.set('filmresolution', [1920 1080]);
%thisR.set('rays per pixel', 2048);
%thisR.set('nbounces', 3);
% 
% for testing
thisR.set('filmresolution', [320 240]);
thisR.set('rays per pixel', 64);
thisR.set('nbounces', 3);
%
% fprintf('This scene has %d objects\n',thisR.get('n objects'));

%% NOTE on higher-performance alternative

%  If we are okay over-writing the output .pbrt we can use the
%  mainfileonly flag to piWrite() to save the time spent regenerating
%  the geometry and texture files -- since we are only moving the camera
%  We'd then need to render each version in turn, as they will write over
%  each other

%% NOTE: SHOULD BE TRUE EXCEPT FOR DEBUGGING!
sceneRaw = piWRS(thisR,'remote resources', false); %,true);
scene = piAIdenoise(sceneRaw);

ieReplaceObject(sceneRaw);
ieReplaceObject(scene);

%%
oi = oiCreate;
oi = oiCompute(oi,scene);
oiWindow(oi);

% Optionally show the not denoised output
oiRaw = oiCreate;
oiRaw = oiCompute(oiRaw, sceneRaw);
oiWindow(oiRaw);
%% END
