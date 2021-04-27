%% Gets a skymap from Flywheel; also uses special scene materials
%
% We store the automotive Graphics auto in the Flywheel database.
% This script shows how to download a file from Flywheel.  This
% technique is used much more extensively in creating complex driving
% scenes.
%
% This example scene also includes glass and other materials that
% were created for driving scenes.  The script sets up the glass
% material and number of bounces to make the glass appear reasonable.
%
% It also uses piMaterialsGroupAssign() to set a list of materials (in
% this case a mirror) that are part of the scene.
%
% Dependencies:
%
%    ISET3d, (ISETCam or ISETBio), JSONio, SCITRAN
%
%  Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% ZL, BW SCIEN 2018
%
% See also
%   t_piIntroduction01, t_piIntroduction02

%% Problem (11/01/20, DHB): This won't run without a flywheel key,
%                           which most people don't have.


%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end
if ~piScitranExists, error('scitran installation required'); end

%% Read pbrt files
sceneName = 'plane';
% FilePath = fullfile(piRootPath,'data','V3',sceneName);
fname = '/Users/zhenyi/Desktop/plane/plane.pbrt';
sceneR = piRead(fname);
% set output file
outFile = fullfile(piRootPath,'local',sceneName,sprintf('%s.pbrt',sceneName));
sceneR.set('outputFile',outFile);
% render quality
sceneR.set('film resolution',[800 600]);
sceneR.set('pixel samples',32);
% camera properties
sceneR.set('fov',45);
sceneR.set('from', [0 1.5 5]);
sceneR.set('to',[0 0.5 0]);
sceneR.set('up',[0 1 0]);
%% get a random car and a random person from flywheel
% take some time, maybe you dont want to run this everytime when you debug
% assets = piFWAssetCreate('ncars',1, 'nped',1);
st = scitran('stanfordlabs');
object_acq = st.fw.lookup('wandell/Graphics auto/assets/car/Car_085');% 
% acq_tmp  = st.lookup('wandell/Graphics auto/assets/car/Car_085','full');
dstDir = fullfile(iaRootPath, 'local','Car_085');

objectR = piFWAssetCreate(object_acq, 'resources', true, 'dstDir', dstDir);

objectR.set('outputFile', fullfile(dstDir,'Car_085.pbrt'));

%% add downloaded asset information to Render recipe.
sceneR = iaRecipeMerge(sceneR, objectR);

%% Get a sky map from Flywheel, and use it in the scene
thisTime = '16:30';
% We will put a skymap in the local directory so people without
% Flywheel can see the output
if piScitranExists
    [~, skymapInfo] = piSkymapAdd(sceneR,thisTime);
    
    % The skymapInfo is structured according to python rules.  We convert
    % to Matlab format here. The first cell is the acquisition ID
    % and the second cell is the file name of the skymap
    s = split(skymapInfo,' ');
    
    % The destination of the skymap file
    skyMapFile = fullfile(fileparts(sceneR.outputFile),s{2});
    
    % If it exists, move on. Otherwise open up Flywheel and
    % download the skypmap file.
    if ~exist(skyMapFile,'file')
        fprintf('Downloading Skymap from Flywheel ... ');
        st        = scitran('stanfordlabs');
        % Download the file from acq using fileName and Id, same approach
        % is used for rendering jobs on google cloud
        piFwFileDownload(skyMapFile, s{2}, s{1})% (dest, FileName, AcqID)
        fprintf('complete\n');
    end
end

sceneR.set('max depth',10);

%% This adds predefined sceneauto materials to the assets in this scene

piAutoMaterialGroupAssign(sceneR);  

%%
colorkd = piColorPick('yellow');
name = 'HDM_06_002_carbody_black';
sceneR.set('material',name,'kd value',colorkd);
% Assign a nice position.
sceneR.set('asset','0004ID_HDM_06_002_B','world translation',[0.5 0 0]);
sceneR.set('asset','0004ID_HDM_06_002_B','world rotation',[0 -15 0]);
sceneR.set('asset','0004ID_HDM_06_002_B','world rotation',[0 -30 0]);


%% Write out the pbrt scene file, based on scene.
piWrite(sceneR);

%% Render.

% Maybe we should speed this up by only returning radiance.
[scene, result] = piRender(sceneR,'render type','radiance');

scene = sceneSet(scene,'name',sprintf('Time: %s',thisTime));
sceneWindow(scene);
sceneSet(scene,'display mode','hdr');         
%% END
