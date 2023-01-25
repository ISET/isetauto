% Demonstrate the effect of flare on a night time scene
%

% Requires access to scene data
% Open our database to get a scene (requires isetonline & access to our
% database. Otherwise gets a scene by hand from: 
%   /acorn/data/iset/isetauto/Ford/SceneISET/nighttime


useDB = true;

if useDB
    ourDB = isetdb();

    % retrieve our ISET-format auto scenes
    autoScenes = ourDB.docFind('autoScenesISET', []);
    useScene = autoScenes(1); % pick a desired scene from our collection
    
    % Make this more elegant
    sceneFile = fullfile(useScene.sceneFolder,[useScene.sceneID '.mat']);
else
    sceneFile = '/acorn/data/iset/isetauto/Ford/SceneISET/nighttime/1112153442.mat';
end

    ourSceneData = load(sceneFile);
    ourScene = ourSceneData.scene;

    % No actual optics yet
    oi = oiCreate();
    oiScene = oiCompute(ourScene, oi);
    % need to crop back to scene size
    % using 'border' is often off by 1, which makes combining data hard
    sceneSize = size(ourScene.data.photons);
    % These indices seem to need to be backwards from what I'd think?
    oiScene = oiCrop(oiScene, [sceneSize(2)/8 sceneSize(1)/8 sceneSize(2)-1 sceneSize(1)-1]); 
    oiFlare = piFlareApply(ourScene); 

    oiWindow(oiScene);
    oiWindow(oiFlare);

    opticsWeight = .96;
    flareWeight = .04;
    oiCombinedData = oiScene.data.photons * opticsWeight + ...
        oiFlare.data.photons * flareWeight;

    oiCombined = oiScene;
    oiCombined.data.photons = oiCombinedData;

    oiWindow(oiCombined);

end