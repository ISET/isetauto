% Parameters controlled experiments
ieInit; piDockerConfig;
%%

assetFolder   = '/data/zhenyi/PBRT_assets';

distance = 10:10:100;
% name for images set
sceneSetName = 'nightdrive';
horizontalOffset = 1.75;
optics = 'pinhole';

car_1_name = 'car_005';

datasetFolder = sprintf('/data/zhenyi/dataset/metricScene/%s_%s_oneCar_%s',optics, sceneSetName, car_1_name);

if ~exist(fullfile(datasetFolder,'additionalInfo'),'dir')
    mkdir(fullfile(datasetFolder,'additionalInfo'));
end


for dd = 1:numel(distance)
%% Get base road
try
%     loadRecipe = load('~/Documents/git_repo/scenes/road_base/road_base.mat');
    loadRecipe = load('/home/zhenyi/Documents/git_repo/isetauto/local/road_001_assembled.mat');
    thisR = loadRecipe.thisR;
catch
    thisR = piRead('~/Documents/git_repo/scenes/road_base/road_base.pbrt');
end
    sceneName = sprintf('distance_%03d_fullscene',distance(dd));
    outputFile = fullfile(piRootPath, 'local', sceneSetName, [sceneName,'.pbrt']);
    thisR.set('outputFile',outputFile);
%% Add one car and a pedestrian

%     ped_1_name = 'pedestrian_001';

car_1 = load(sprintf('%s/car/%s/%s.mat', assetFolder, car_1_name, car_1_name));

thisR = piRecipeMerge(thisR, car_1.recipe, 'objectInstance', true);

iaAutoMaterialGroupAssignV4(thisR);

% nNodes = numel(thisR.assets.Node);
% NodeList = thisR.assets.Node;
% for nn = nNodes:-1:1
%     thisNode =  NodeList{nn};
%     if contains(thisNode.name, {'headlight','headlamp'})
%         thisR.assets = thisR.assets.chop(nn);
%     end
% end
lightNames = thisR.assets.mapLgtFullName2Idx.keys;
for ll = 1:numel(lightNames)
    thisLight  = thisR.get('light', lightNames{ll});
    lightLevel = thisLight.lght{1}.specscale.value;
    spd        = thisLight.lght{1}.spd.value;
    if contains(lower(lightNames{ll}), {'headlight','headlamp'}) % headlight
        thisR.set('asset',lightNames{ll},'delete');
    elseif contains(lower(lightNames{ll}), {'lampbulb'}) % streetlight
        headlightSPD = 'headlight-Halogen';
        lightLevel = 150;
        thisR.set('light', lightNames{ll}, 'specscale', lightLevel*0.1*0.25);
        thisR.set('light', lightNames{ll}, 'spd', headlightSPD);
        thisR.set('light',lightNames{ll}, 'spread', 60);
    else
        thisR.set('light', lightNames{ll}, 'specscale', lightLevel*0.1*0.25);
        %                 disp(lightLevel*0.5);
        if spd == [1 1 1]
            thisR.set('light', lightNames{ll}, 'spd', 'headlight-LED-1');
        elseif spd(1)> spd(2) && spd(1)> spd(3) && spd(2)<0.
            thisR.set('light', lightNames{ll}, 'spd', 'headlight-Halogen-rear');
        end
    end
end
disp('Set light intensity end.');

    %% Add and place trees
%     for tt = 1:9
%         treeName = sprintf('tree_%03d',tt);
%         treeR = load(sprintf('/Volumes/SSDZhenyi/Ford Project/PBRT_assets/trees/%s/%s.mat', treeName, treeName));
%         thisR = piRecipeMerge(thisR, treeR.recipe, 'objectInstance', true);
% 
%         for pp = 1:50
%             pos_tree_left = [10-randi(200), -3-randi(20) 0];
%             thisR = piObjectInstanceCreate(thisR, [treeName,'_m_B'],'position',pos_tree_left);
%             pos_tree_right = [10-randi(200), 3+randi(20) 0];
%             thisR = piObjectInstanceCreate(thisR, [treeName,'_m_B'],'position',pos_tree_right);
%         end
%         
%     end

    % name for current image

    
    %% Place two cars
    % Range 10 to -400 m
%     pos_1 = [distance(dd) horizontalOffset 0];
    pos_1 = [-20 -6 0];
%     pos_2 = [distance(dd)+2 -1.8 0];

    [thisR, instanceBranchName] = piObjectInstanceCreate(thisR, [car_1_name,'_m_B'], 'position', pos_1);
%     thisR = piObjectInstanceCreate(thisR, [ped_1_name,'_m_B'], 'position', pos_2);

    thisR.assets = thisR.assets.uniqueNames;
    
    % remove instanceBranchName and recreate one
    %% Set lighting
%     skymap = 'sky-noon_009.exr';
    skymap = 'equi_belfast_sunset_4k.exr';
    thisR.set('skymap',skymap);
    disp('Set light intensity starts...');

    headlightSPD = 'headlight-Halogen';

    %%
    thisR.set('film resolution',[1920 1080]);
    thisR.set('rays per pixel',512);
    thisR.set('nbounces',10);
    thisR.sampler.subtype = 'zsobol';
    thisR.set('integrator','path');

    thisR.set('fov',42);

    thisR.set('film render type',{'radiance','depth'});
%     thisR.lookAt.from = [0 1.8 1.7];
%     thisR.lookAt.to = [1 1.8 1.6];
    thisR.lookAt.from = [53 2.6 1.5];
    thisR.lookAt.to   = [-35 -3.5 1.4];

    piWrite(thisR);
    scene = piRenderZhenyi(thisR, 'serverrender', false, 'renderlocal', true);
%     sceneWindow(scene);
    %%
%     scene = piAIdenoise(scene);
    save(fullfile(datasetFolder, sprintf('%s_fullscene.mat',sceneName)),'scene');
    
    % label
    [objectslist,instanceIdMap] = piRenderLabel(thisR);
    save(fullfile(datasetFolder, sprintf('%s_instanceId.mat',sceneName)),'instanceIdMap');

    camera_type = 'front';
    [~,sceneName] = fileparts(thisR.get('outputfile'));
    seg_FID = fopen(fullfile(datasetFolder,'additionalInfo',[sceneName,'.txt']),'w+');
    fprintf(seg_FID,'sceneName: %s\nSkymap: %s\nCameraType: %s\n CarPositions:[%.2f %.2f %.2f] ',sceneName, ...
        erase(skymap,'.exr'), camera_type, pos_1);
    fprintf(seg_FID,'Object ID:\n');

    for ii = 1:numel(objectslist)
        name = objectslist{ii};
        name = erase(name,{'ObjectInstance ', '"', '_m'});
        fprintf(seg_FID, '%d %s \n',ii, name);
    end

    % remove added car Instance
%     thisR.set('assets',instanceBranchName, 'delete');
end
%%

%{
% oi = piOICreate(scene.data.photons);
mlum = sceneGet(scene, 'meanluminance');
scene = sceneAdjustLuminance(scene, mlum/80);
Luminance  = sceneGet(scene, 'luminance');
maxLum = max(Luminance(:));
flare_scale  = 0.1;
oi = piFlareApply(scene, 'numsidesaperture', 100, 'focal length', 4e-3, ...
    'sensor size', 2.91e-3, 'pixelsize', 1.52e-6,'dirt aperture', false, ...
   'maxluminance',maxLum * flare_scale);

% millum = oiGet(oi, 'meanilluminance');
% 
% oi = oiAdjustIlluminance(oi, millum/100);
% ar0132atSensorRGB
ip = piRadiance2RGB(oi,'etime', 1/5, 'sensor', 'ar0132atSensorRGB', 'analoggain', 5);
radiance = ipGet(ip,'srgb');
figure;imshow(radiance);
imwrite(radiance, '/Users/zhenyi/Desktop/night_flare_dist.png');
%}
