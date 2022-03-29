%% Gets a skymap from Flywheel; also uses special scene materials
%
% This script shows how to create a simple scene using assets that are
% stored in the Flywheel stanfordlabs site.  To run this script you must
% have permission (a key) to login and download assets from Flywheel.
%
% This technique is used at a much larger scale in creating complex driving
% scenes.
%
% Dependencies:
%
%    ISET3d, (ISETCam or ISETBio), ISETAuto(zhenyi branch), JSONio, SCITRAN
%
% Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% ZL, BW SCIEN 2018
%
% See also
%   t_piIntroduction01, t_piIntroduction02

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% We are going place some cars on a plane
% Initialize a planar surface with a checkerboard texture pattern
sceneName = 'simpleCarScene';
sceneR = piRecipeDefault('scene name','checkerboard');
sceneR.set('outputFile',fullfile(piRootPath, 'local', sceneName,[sceneName,'.pbrt']));
% render quality
sceneR.set('film resolution',[800 600]);
sceneR.set('pixel samples',64);
sceneR.set('max depth',10);

% camera properties
sceneR.set('fov',45);
sceneR.set('from', [2 -12 2]);   % from was 5
sceneR.set('to',[0 0 0.5]);
sceneR.set('up',[0 0 1]);

% scale and rotate checkerboard
sceneR.set('assets','0006ID_Checkerboard_B','scale',[10 10 1]);
% sceneR.set('asset','Checkerboard_B','world rotation',[90 30 0]);
%% Get a car
assetName = 'car_003';
thisCar = piRead(fullfile('/Volumes/SSDZhenyi/Ford Project/PBRT_assets/cars',assetName,[assetName,'.pbrt']));

%% add downloaded asset information to Render recipe.
sceneR = piRecipeMerge(sceneR, thisCar);
rotationMatrix = piRotationMatrix();
sceneR   = piObjectInstanceCreate(sceneR, [assetName,'_m_B'], ...
                'position', [0 0 0],...
                'rotation',rotationMatrix);
%% Add a light to the merged scene

% Delete any lights that happened to be there
skymap = piLightCreate('new skymap', ...
    'type', 'infinite',...
    'string mapname', 'noon_009.exr');

sceneR.set('light', skymap,'add');

%% This adds predefined sceneauto materials to the assets in this scene

iaAutoMaterialGroupAssign(sceneR);

%% Write out the pbrt scene file, based on scene.
piWrite(sceneR);  

%% Render.
% Maybe we should speed this up by only returning radiance.
[scene, result] = piRenderZhenyi(sceneR);

%%  Show the scene in a window
scene = sceneSet(scene,'name', 'normal');
sceneWindow(scene);
% sceneSet(scene,'display mode','hdr'); 
% denoise
%{
sceneDenoise = piAIdenoise(scene);
scene = sceneSet(scene,'name', 'denoised');
sceneWindow(sceneDenoise);
% sceneSet(scene,'display mode','hdr');   
%}





