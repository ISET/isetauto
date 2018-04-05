% This script demonstrates the use of ised3d to produce scenes with camera
% locations defined in the Cameras_City_x_Placement_x.txt files.
%
% Copyright, Henryk Blasinski 2018.


close all;
clear all;
clc;

ieInit;
[rootPath, parentPath] = nnGenRootPath();

cameraDir = fullfile(parentPath,'Parameters','SceneArrangements');
inputSceneDir = fullfile('/','share','wandell','data','NN_Camera_Generalization','Renderings');
targetDir = fullfile('/','scratch','hblasins','iset3d');


for cityID=1:4
    for placementID=1:5
        
        sceneFile = fullfile(inputSceneDir,sprintf('MultiObject-City-%i-Placement-%i',cityID,placementID),sprintf('City_%i_placement_%i_radiance.pbrt',cityID,placementID));
        scene = piRead(sceneFile);
        
        cameraFile = fullfile(cameraDir,sprintf('Cameras_City_%i_Placement_%i.txt',cityID,placementID));
        [names, values] = rtbParseConditions(cameraFile);
        cameras = cell2struct(values,names,2);
        
        % For simplicity we will render just one viewpoint
        cameras = cameras(1);
        
        % Update the camera in the scene
        scene = nnPlaceCameraInIsetScene(scene,cameras);
        
        % Render the scene
        scene.set('outputFile',fullfile(targetDir,sprintf('%s.pbrt',cameras.imageName)));
        piWrite(scene,'overwriteresources',true);
        sc = piRender(scene,'renderType','radiance');
        
        ieAddObject(sc);
        sceneWindow();
    end
    
end
%%

