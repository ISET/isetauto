%% Automatically assemble a country road scene
%
% Dependencies
%   ISET3d, ISETAuto, ISETCam and scitran
%   Prefix:  ia- means isetauto
%            pi- means iset3d-v4
%
%   ISET3d-V4: Takes a PBRT file, parse 3D information including lights,
%   materials, textures and meshes. Modify the properties and render it.
%
%   ISETAuto: Assemble ISET3d OBJECT into a complex driving scene.
%
%   ISETCam: Convert scene radiance or optical irradiance data to RGB
%   image with a physically based sensor model and ISP pipeline.
%
% Zhenyi, 2022

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

camPositions = 2; % for each scene, we choose different cam positions.
sceneName = 'nightdrive0920';

fid_cpu = fopen(fullfile(piRootPath, 'local', sceneName, 'render_cpu.sh'),'w+');
fid_gpu_0 = fopen(fullfile(piRootPath, 'local', sceneName, 'render_gpu_0.sh'),'w+');
fid_gpu_1 = fopen(fullfile(piRootPath, 'local', sceneName, 'render_gpu_1.sh'),'w+');
fid_gpu_2 = fopen(fullfile(piRootPath, 'local', sceneName, 'render_gpu_2.sh'),'w+');
fid_gpu_3 = fopen(fullfile(piRootPath, 'local', sceneName, 'render_gpu_3.sh'),'w+');

%% Road initiation

% assetDir = fullfile(iaRootPath,'local','assets');
assetDir = '/Volumes/SSDZhenyi/Ford Project/PBRT_assets';
roadNames = {'road_001', 'road_002','road_003','road_004','road_005','road_006',...
    'road_011','road_012','road_013','road_015','road_020'};
for ii = 1:25%numel(roadNames)
%     roadName = roadNames{ii};
    roadName = roadNames{randi(11)};
    roadName = 'road_001';
    roadDir  = sprintf('/Volumes/SSDZhenyi/Ford Project/PBRT_assets/road/%s', roadName);

    % The road data
    roadData = roadgen('road directory',roadDir, 'asset directory',assetDir);

    assetLibNames = keys(assetlib());
    %% Place the onroad elements

    % The driving lanes
    roadData.set('onroad car lanes',{'leftdriving','rightdriving'});
    % roadData.set('onroad car lanes', {'leftdriving'});

    % Cars on the road
    carNames = assetLibNames(contains(assetLibNames,'car'));

    roadData.set('onroad car names',carNames(randperm(numel(carNames), 8)));%

    % How many cars on each driving lane.
    % The vector length of these numbers should be the same as the number
    % of driving lanes.
    nCars = [randi(20), randi(20)];
    roadData.set('onroad n cars', nCars);

    truckNames = assetLibNames(contains(assetLibNames,'truck'));
    roadData.onroad.truck.namelist = truckNames(randperm(numel(truckNames), 3));
    roadData.onroad.truck.lane = {'leftdriving','rightdriving'};
    roadData.onroad.truck.number = [2, 2];

    busNames = assetLibNames(contains(assetLibNames,'bus'));
    roadData.onroad.bus.namelist = busNames(randperm(numel(busNames), 3));
    roadData.onroad.bus.lane = {'leftdriving','rightdriving'};
    roadData.onroad.bus.number = [2, 2];  

    bikerNames = assetLibNames(contains(assetLibNames,'biker'));
    roadData.onroad.biker.namelist = bikerNames(randperm(numel(bikerNames), 7));
    roadData.onroad.biker.lane = {'leftdriving','rightdriving'};
    roadData.onroad.biker.number = [3, 3];

    pedestrianNames = assetLibNames(contains(assetLibNames,'pedestrian'));
    roadData.onroad.pedestrian.namelist = pedestrianNames(randperm(numel(pedestrianNames), 30));
    roadData.onroad.pedestrian.lane = {'leftdriving','rightdriving'};
    roadData.onroad.pedestrian.number = [5, 5];

    % Now place the animals
    deerNames = assetLibNames(contains(assetLibNames,'deer'));
    deerNames = deerNames(randperm(numel(deerNames),2));
    roadData.set('onroad animal names',deerNames);
    roadData.set('onroad n animals', [randi(3)-1, randi(3)-1]);
    roadData.set('onroad animal lane',{'leftdriving','rightdriving'});

    % roadData.onroad.animal.namelist = {'deer_001'};
    % roadData.onroad.animal.number= randi(10);
    % roadData.onroad.animal.lane  = {'rightdriving'};

    %% Place the offroad elements.  These are animals and trees.  Not cars.

    roadData.set('offroad animal names',deerNames);
    roadData.set('offroad n animals', [randi(6)-1, randi(6)-1]);
    roadData.set('offroadanimallane', {'rightshoulder','leftshoulder'});

    roadData.set('offroad animal min distance',0);
    roadData.set('offroad animal layer width',5);

    pedestrianNames = assetLibNames(contains(assetLibNames,'pedestrian'));
    roadData.offroad.pedestrian.namelist = pedestrianNames(randperm(numel(pedestrianNames), 30));
    roadData.offroad.pedestrian.lane = {'rightshoulder','leftshoulder'};
    roadData.offroad.pedestrian.number = [10, 10];

    treeNames = assetLibNames(contains(assetLibNames,'tree'));
    treeNames = treeNames(randperm(numel(treeNames), 10));
    roadData.set('offroad tree names', treeNames);
    roadData.set('offroad n trees', [100, 200, 30]); % [50, 100, 150]
    roadData.set('offroad tree lane', {'rightshoulder','leftshoulder'});

    % Place the trees for different distance range from the boundary of road
    roadData.offroad.grass.namelist = {'grass_001','grass_002','grass_003','grass_004','grass_005','grass_006','grass_007','grass_008'};
    roadData.offroad.grass.number   = [1000, 50, 10];%[800, 100, 50];
    roadData.offroad.grass.lane     = {'rightshoulder','leftshoulder'};

    roadData.offroad.streetlight.namelist = {'streetlight_001'};
    roadData.offroad.streetlight.number = [10, 10];
    roadData.offroad.streetlight.lane = {'rightshoulder', 'leftshoulder'};
    roadData.offroad.rock.namelist = {'rock_001','rock_002','rock_003'};
    roadData.offroad.rock.number   = [200, 200, 1];
    roadData.offroad.rock.lane     = {'rightshoulder','leftshoulder'};

    %% Set the recipe parameters
    thisR = roadData.recipe;

    thisR.set('film render type',{'radiance','depth'});
    % render quality
    thisR.set('film resolution',[1920 1080]); % 4
    thisR.set('pixel samples',128); % 512
    thisR.set('max depth',5);
    thisR.set('sampler subtype','pmj02bn');
    imageID = iaImageID();

    % outputFile = fullfile(iaRootPath, 'local', sceneName, [num2str(imageID),'.pbrt']);
    outputFile = fullfile(piRootPath, 'local', sceneName, [num2str(imageID),'.pbrt']);

    thisR.set('outputFile',outputFile);
    %% Set up the rendering skymap
    skymapLists     = dir('/Volumes/SSDZhenyi/Ford Project/PBRT_assets/skymap/sky*.exr');
    skymapRandIndex = randi(size(skymapLists,1));
    skymapName      = skymapLists(skymapRandIndex).name;
%     skymapName = 'sky-noon_009.exr';
    thisR.set('skymap',fullfile(skymapLists(skymapRandIndex).folder, skymapName));
    thisR.set('asset',strrep(skymapName,'.exr','_B'),'rotation', [0 0 0]);
    % useful Docker cmd for reading or making a skymap.
    %{
        piDockerImgtool('makeequiarea','infile','/Users/zhenyi/git_repo/dev/iset3d-v4/data/lights/dikhololo_night_4k.exr');
    %}
    %% Assemble the scene using ISET3d methods

    assemble_tic = tic();
    roadData.assemble();
    fprintf('---> Scene assembled in %.f seconds.\n',toc(assemble_tic));

    %% Apply our customized material
    iaAutoMaterialGroupAssignV4(thisR, true);
    disp('--> Material assigned');

    %% Use a camera for this car

    % lensfile  = 'wide.40deg.6.0mm.json';    % 30 38 18 10
    % fprintf('Using lens: %s\n',lensfile);

    % random pick a car, use the camera on it.  This are the types of cameras
    % so far:
    %
    %   front
    %   back
    %   left
    %   camera_type = 'right'
    for cc = 1:camPositions
        camera_type = 'front';
        % random pick a car, use the camera on it.
        branchID(cc) = roadData.cameraSet(camera_type); % (camera_type, car_id)
        
        if cc > 1 && branchID(cc) == branchID(cc-1)
            disp('Cam position was used, pick a different.');
            branchID(cc) = roadData.cameraSet('camera type', camera_type); % (camera_type, car_id)
        end

        direction = thisR.get('object direction');
        thisR.set('object distance', 0.95);

        %% Render the scene, and maybe an OI
        if cc > 1
            imageID = iaImageID();
            outputFile = fullfile(piRootPath, 'local', sceneName, [num2str(imageID),'.pbrt']);
            thisR.set('outputFile',outputFile);
        end

        outputFile = thisR.get('output file');
        sceneRecipe = strrep(outputFile,'.pbrt','.mat');
        save(sceneRecipe,'thisR','-mat');
        %% create light group
        skyName = erase(skymapName,'.exr');
%         recipeList = iaLightsGroup(thisR, skyName);
        recipeList{1} = thisR;
        for rr = 1:numel(recipeList)
            piWrite(recipeList{rr});
            
            gpuDeviceID = randi(3);

            [~, ~, renderCMD] = piRenderZhenyi(recipeList{rr}, 'gpuDeviceID', gpuDeviceID, ...
                'renderLater',true);
            switch gpuDeviceID
                case 0
                    fprintf(fid_gpu_0, [renderCMD,'\n']);
                case 1
                    fprintf(fid_gpu_1, [renderCMD,'\n']);
                case 2
                    fprintf(fid_gpu_2, [renderCMD,'\n']);
                case 3
                    fprintf(fid_gpu_3, [renderCMD,'\n']);
            end
        end
        
        %% render label
        % Label the objects using the CPU 
%         renderLater = true;
%         [objectslist, instanceIdMap, renderCMD] = piRenderLabel(thisR, renderLater); % (thisR, renderLater)
%         fprintf(fid_cpu, [renderCMD,'\n']);
    end
end
% run command in background
fclose(fid_gpu_0);
fclose(fid_gpu_1);
fclose(fid_gpu_2);
fclose(fid_gpu_3);
fclose(fid_cpu);

%{
for campos = 1:5
    camera_type = 'front';

    % random pick a car, use the camera on it.
    branchID = roadData.cameraSet(camera_type); % (camera_type, car_id)
    direction = thisR.get('object direction');
    thisR.set('object distance', 0.95);

    imageID = iaImageID();
    outputFile = fullfile(piRootPath, 'local', sceneName, [num2str(imageID),'.pbrt']);
    thisR.set('outputFile',outputFile);
    piWrite(thisR);
    scene = piRenderZhenyi(thisR);sceneWindow(scene);

    outputFile = thisR.get('output file');
    sceneRecipe = strrep(outputFile,'.pbrt','.mat');
    save(sceneRecipe,'thisR','-mat');
end

%% create light group
skyName = erase(skymapName,'.exr');
recipeList = iaLightsGroup(thisR, skyName);
%%
for rr = 1:numel(recipeList)
%     recipeList{rr}.set('pixel samples',1024);
%     recipeList{rr}.set('film resolution',[1280 720]*1.5);
    piWrite(recipeList{rr});
    scene_lg{rr} = piRenderZhenyi(recipeList{rr}, 'meanluminance',0);
end

%{
%debug: scene = piRenderZhenyi(thisR);sceneWindow(scene);

% The position does not seem to change correctly yet.
% We do have a repeatable scene if we change from front - left -
% front, we get the same scene back.  But the 'left' position doesn't
% seem good.
camera_type = 'front';
roadData.cameraSet(camera_type, branchID); % (camera_type, car_id)
[scene, res] = piWRS(thisR);
%}

%{
oi = oiCreate;
oi = oiCompute(oi,scene);
oi = oiCrop(oi,'border');
sensor = sensorCreate('MT9V024');
sensor = sensorSet(sensor,'fov',sceneGet(scene,'fov'),oi);
sensor = sensorSet(sensor,'auto exposure',true);
% sensor = sensorSet(sensor,'exposure time',0.016);
sensor = sensorCompute(sensor,oi);
ip = ipCreate;
ip = ipCompute(ip, sensor);
% ipWindow(ip);
%}
for rr = 1:3
    scene_lg_dn{rr} = piAIdenoise(scene_lg{rr});
end

%% Label the objects using the CPU 
[objectslist, instanceIdMap] = piRenderLabel(thisR);
% [objectslist,instanceMap] = roadData.label();

%% Show the various images

ieNewGraphWin([],'upperleftbig');

% We should be able to use the sensor image for finding the objects.
% But not yet.
imgscene = sceneGet(scene,'rgb');
% imgscene = ipGet(ip,'srgb');

subplot(2,2,1);
imshow(imgscene);title('Radiance')
ax1 = subplot(2,2,2);
imagesc(scene.depthMap);colormap(ax1,"gray");title('Depth');axis off
set(gca, 'Visible', 'off');
ax2=subplot(2,2,3);
imagesc(instanceMap);colormap(ax2,"colorcube");axis off;title('Pixel Label');
subplot(2,2,4);
imshow(imgscene);title('Bounding Box');

%% Add the bounding boxes, which requires the cocoapi method

nBox=1;
nImage = 1;
Annotation=[];
[h,w,~] = size(imgscene);

datasetFolder = fullfile(piRootPath,'local','dataset_demo');

% write out object ID for segmentation map;
if ~exist(fullfile(datasetFolder,'additionalInfo'),'dir')
    mkdir(fullfile(datasetFolder,'additionalInfo'))
end
seg_FID = fopen(fullfile(datasetFolder,'additionalInfo',[num2str(imageID),'.txt']),'w+');

fprintf(seg_FID,'sceneName: %s\nSkymap: %s\nCameraType: %s\n',sceneName, ...
    erase(skymapName,'.exr'), camera_type);
fprintf(seg_FID,'Object ID:\n');

for ii = 1:numel(objectslist)
    name = objectslist{ii};
    name = erase(name,{'ObjectInstance ', '"', '_m'});
    fprintf(seg_FID, '%d %s \n',ii, name);
    if contains(lower(name), {'car'})
        label = 'vehicle';
        catId = 3;
        r = 0.1; g= 0.5; b = 0.1;
    elseif contains(lower(name),'deer')
        label = 'Deer';
        catId = 9;
        r = 1; g= 0.1; b = 0.1;
    else
        continue;
    end
    [occluded, truncated, bbox2d, segmentation, area] = piAnnotationGet(instanceMap,ii,0);
    if isempty(bbox2d), continue;end
    pos = [bbox2d.xmin bbox2d.ymin ...
            bbox2d.xmax-bbox2d.xmin ...
            bbox2d.ymax-bbox2d.ymin];

    rectangle('Position',pos,'EdgeColor',[r g b],'LineWidth',1);
    tex=text(bbox2d.xmin+2.5,bbox2d.ymin-8,label);
    tex.Color = [1 1 1];
    tex.BackgroundColor = [r g b];
    tex.FontSize = 12;

    Annotation_coco{nBox} = struct('segmentation',segmentation,'area',area,'iscrowd',0,...
        'image_id',sprintf('%d',imageID),'bbox',pos,'category_id',catId,'id',0,'ignore',0); %#ok<SAGROW> 
    fprintf('Class %s, instanceID: %d \n', label, ii);
    nBox = nBox+1;
end
truesize;

%%  Save the images


%{
% We are going to put the rgb image, depth map, pixel label, and
% bounding box in COCO format using this directory.  You can use these
% image data again later.
datasetFolder = fullfile(iaRootPath,'local','nightdrive','dataset');
if ~exist(datasetFolder,'dir'), mkdir(datasetFolder); end


if ~exist(fullfile(datasetFolder,'rgb'),'dir')
    mkdir(fullfile(datasetFolder,'rgb'))
end
if ~exist(fullfile(datasetFolder,'segmentation'),'dir')
    mkdir(fullfile(datasetFolder,'segmentation'))
end
if ~exist(fullfile(datasetFolder,'depth'),'dir')
    mkdir(fullfile(datasetFolder,'depth'))
end
if ~exist(fullfile(datasetFolder,'rendered'),'dir')
    mkdir(fullfile(datasetFolder,'rendered'))
end
imgName = sprintf('%d.png',imageID);

% Image_coco = struct('file_name',imgName,'height',h,'width',w,'id',sprintf('%d',imageID));
%
% % write files out
% save(fullfile(datasetFolder, sprintf('%d_image.mat',imageID)),'Image_coco');
% save(fullfile(datasetFolder, sprintf('%d_anno.mat',imageID)), 'Annotation_coco');

imgFilePath  = fullfile(datasetFolder,'rgb',imgName);
imwrite(radiance,imgFilePath);

imwrite(uint16(instanceMap),fullfile(datasetFolder,'segmentation',imgName));
imwrite(uint16(scene.depthMap),fullfile(datasetFolder,'depth',imgName));
outputFolder = roadData.recipe.get('outputdir');
movefile(fullfile(outputFolder,sprintf('renderings/%d.exr',imageID)),fullfile(datasetFolder,'rendered/'));
%}
% fprintf('****** Scene%d Generated! ******\n',nScene);

% end
%}

%% End
%}

