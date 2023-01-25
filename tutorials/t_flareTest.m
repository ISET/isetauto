% Demonstrate the effect of flare on a night time scene
%

% Requires access to scene data
% Open our database to get a scene (requires isetonline & access to our
% database. Otherwise get a scene by hand from: 
%   /acorn/data/iset/isetauto/Ford/SceneISET/nighttime


useDB = true;

if useDB
    ourDB = isetdb();

    % retrieve our ISET-format auto scenes
    autoScenes = ourDB.docFind('autoScenesISET', []);
    useScene = autoScenes(1); % pick a desired scene from our collection
    
    % Make this more elegant
    sceneFile = fullfile(useScene.sceneFileFolder,[useScene.sceneID '.mat']);

    ourSceneData = load(sceneFile);
    ourScene = ourSceneData.scene;

    % No actual optics yet
    oi = oiCreate();
    oiScene = oiCompute(ourScene, oi);
    oiFlare = piFlareApply(ourScene); 

    oiWindow(oiScene);
    oiWindow(oiFlare);

    opticsWeight = .96;
    flareWeight = .04;
    oiCombinedData = oiScene.data.photons * opticsWeight + ...
        flareScene.data.photons * flareWeight;

    oiCombined = oiScene;
    oiCombined.data.photons = oiCombinedData;

    oiWindow(oiCombined);
    
end