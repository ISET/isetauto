% Generate metric scenes
ieInit;
piDockerConfig;
assetlibList = assetlib();
assetLibNames = keys(assetlibList);
assetDir = '/Volumes/SSDZhenyi/Ford Project/PBRT_assets';
%%
for ii = 1:20
    OBJDistance = 5*ii; % meters

    roadName = 'road_001';
    roadDir  = sprintf('%s/road/%s', assetDir, roadName);
    % The road data
    roadData = roadgen('road directory',roadDir, 'asset directory',assetDir);
    thisR = roadData.recipe;

    [lookAt, placeInfo] = roadData.assetAdd('distance', OBJDistance);
    lookAt.from = [lookAt.from(1) lookAt.from(2) 1.5];
    lookAt.to = [lookAt.to(1) lookAt.to(2) 1.499];
    lookAt.up = [0 0 1];

    thisR.set('film render type',{'radiance','depth'});
    thisR.set('look at', lookAt);
    thisR.set('fov',40);
    thisR.set('skymap','/Volumes/SSDZhenyi/skymap/oberer_kuhberg_4k.exr');
    thisR.set('asset','oberer_kuhberg_4k_B','rotation', [0 0 45]);
    thisR.set('film resolution', round([1280 720]/1.5));
    thisR.set('rays per pixel', 128);
    %
    type = 'car';
    objNames = assetLibNames(contains(assetLibNames,type));
    OBJName = objNames{1};
    fileName = sprintf('%s/%s/%s/%s.pbrt',assetDir, type, OBJName, OBJName);

    assetR = piRead(fileName);
    thisR = piRecipeMerge(thisR, assetR,'objectinstance',true);

    position = [placeInfo.position(1) placeInfo.position(2) 0];
    rMatrix  = piRotationMatrix('z', rad2deg(placeInfo.rotation));

    if contains(OBJName, 'biker')
        personName = [OBJName,'_person'];
        vehicleName = [OBJName, '_', assetlibList(OBJName).label];

        thisR   = piObjectInstanceCreate(thisR, [personName,'_m_B'], ...
            'rotation',rMatrix, 'position',position);

        thisR   = piObjectInstanceCreate(thisR, [vehicleName,'_m_B'], ...
            'rotation',rMatrix, 'position',position);
    else
        thisR   = piObjectInstanceCreate(thisR, [OBJName,'_m_B'], ...
            'rotation',rMatrix, ...
            'position',position);
    end
    thisR.assets = thisR.assets.uniqueNames;
    %
    piWrite(thisR);
    scene = piRenderZhenyi(thisR);
    % sceneWindow(scene);
    oi = piOICreate(scene.data.photons,'meanilluminance',5);
    % millum = oiGet(oi, 'meanilluminance');
    ip = piRadiance2RGB(oi,'etime',1/30,'sensor', 'ar0132atSensorRGB', 'analoggain', 1);
    img = ipGet(ip,'srgb');
    figure;imshow(img);
end