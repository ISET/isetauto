%% Automatically assemble a country road scene
%
% Dependencies
%   ISET3d, ISETAuto, ISETCam and scitran
%   Prefix: ia- means isetauto
%            pi- means pbrt2iset(iset3d)
%
%   ISET3d: Takes a PBRT file, parse 3D information including lights,
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
% for nScene = 1

%% scene initiation
%
% The outputs will go here
%   datasetFolder = '/Volumes/SSDZhenyi/Ford Project/dataset/dataset_demo';
%

assetDir = fullfile(iaRootPath,'local','assets');
roadDir = fullfile(iaRootPath,'local','assets','road','road_001');
roadData = roadgen('road directory',roadDir, 'asset directory',assetDir);

%% Set parameters for the scene
%
% We both add asset names, how many assets we add, and their on and off
% road positions.
%

%% Place the cars

roadData.onroad.car.namelist = {'car_001'};

% The driving lanes
roadData.onroad.car.lane   = {'leftdriving','rightdriving'};

% How many cars on each driving lane.  The vector length of these numbers
% should be the same as the number of driving lanes.
roadData.onroad.car.number = [randi(20),randi(20)];

%% Now place the animals
roadData.onroad.animal.namelist = {'deer_001'};
roadData.onroad.animal.number= randi(10);
roadData.onroad.animal.lane  = {'rightdriving'};

roadData.offroad.animal.namelist = {'deer_001'};
roadData.offroad.animal.number= [randi(10),randi(10)];
roadData.offroad.animal.lane= {'rightshoulder','leftshoulder'};
roadData.offroad.animal.minDistanceToRoad = 0;
roadData.offroad.animal.layerWidth = 5;

%% Now the trees

% for different distance range from the boundary of road
roadData.offroad.tree.namelist = ...
    {'tree_mid_001','tree_mid_002'};
roadData.offroad.tree.number= [100, 50, 10];
roadData.offroad.tree.lane = {'rightshoulder','leftshoulder'};

skymapLists = dir(fullfile(iaRootPath,'data/skymap/*.exr'));
skymapRandIndex = randi(size(skymapLists,1));
roadData.skymap = skymapLists(skymapRandIndex).name;
roadData.skymap = 'noon_009.exr';

% useful cmd for reading or making a skymap.
%{
sceneData.skymap = 'noon_009.exr';
piDockerImgtool('makeequiarea','infile','/Users/zhenyi/git_repo/dev/iset3d-v4/data/lights/dikhololo_night_4k.exr');
%}

%% Set the recipe

thisR = roadData.recipe;

thisR.set('film render type',{'radiance','depth'});

% render quality
thisR.set('film resolution',[1536 864]/4);
thisR.set('pixel samples',512);
thisR.set('max depth',5);
thisR.sampler.subtype = 'pmj02bn';

datastring  = datestr(now,30);
datastring  = erase(datastring,'T');

% if the number of digits is larger than 9, the matlab rounds the number
% cocoapi allow only number as image id, not a string.
imageID  = str2double(datastring(5:end));
sceneName = 'nightdrive';
outputFile = fullfile(iaRootPath, 'local', sceneName, [num2str(imageID),'.pbrt']);
thisR.set('outputFile',outputFile);

%% Assemble the scene using ISET3d methods
assemble_tic = tic();

% This is interesting.
roadData.assemble();
fprintf('---> Scene assembled in %.f seconds.\n',toc(assemble_tic));
% sceneData.rrDraw('points',points, 'dir',dirs); % visualization function is to fix

%% Use a camera for this car

% lensfile  = 'wide.40deg.6.0mm.json';    % 30 38 18 10
% fprintf('Using lens: %s\n',lensfile);
% sceneData.recipe.camera = piCameraCreate('omni','lensFile',lensfile);

% random pick a car, use the camera on it.  This are the types of cameras
% so far:
%
%   front_cam
%   back_cam
%   left_mirror_cam
%   right_mirror_cam
camera_type = 'front_cam';

% sceneData.recipe.lookAt.from = [-215.4888 -2.5427 69.2109];
% sceneData.recipe.lookAt.to   = [-214.5653 -2.5193 68.8282];
% sceneData.recipe.lookAt.up   = [0.3825 0.0151 0.9238];
% random pick a car, use the camera on it.
roadData.cameraSet(camera_type); % (camera_type, car_id)

%%
scene = piWRS(thisR);

%{
thisR.set('camera','position'
%}

%%
% sceneData.recipe.integrator.subtype = 'volpath';
%{
% Write and render
% For demo purpose, this render the scene from the road default camera

piWrite(sceneData.recipe);

rendered = piRenderZhenyi(sceneData.recipe,'device','gpu');
%
oi = piOICreate(rendered.data.photons,'mean illuminance',100);

oi.name = [sceneName,'_sceneCamera'];

oiWindow(oi);
%}

piWrite(roadData.recipe);
if ismac
    rendered = piRenderZhenyi(sceneData.recipe, 'device', 'gpu', 'scalepupilarea', false);
else
    rendered = piRenderServer(roadData.recipe,'device','gpu');
end

oi = piOICreate(rendered.data.photons,'meanilluminance',5);

% oi = piAIdenoise(oi);

ip = piRadiance2RGB(oi,'etime',1/30,'sensor','MT9V024SensorRGB');
radiance = ipGet(ip,'srgb');figure;imshow(radiance);
%% Render instance label

[obj,objectslist,instanceMap] = roadData.label();

%%
figure;
subplot(2,2,1);
imshow(radiance);title('Radiance')
ax1 = subplot(2,2,2);
imagesc(rendered.depthMap);colormap(ax1,"gray");title('Depth');axis off
set(gca, 'Visible', 'off');
ax2=subplot(2,2,3);
imagesc(instanceMap);colormap(ax2,"colorcube");axis off;title('Pixel Label');
subplot(2,2,4);
imshow(radiance);title('Bounding Box');

nBox=1;
nImage = 1;
Annotation=[];
[h,w,~] = size(radiance);

% write out object ID for segmentation map;
seg_FID = fopen(fullfile(datasetFolder,'additionalInfo',[num2str(imageID),'.txt']),'w+');
fprintf(seg_FID,'sceneName: %s\nSkymap: %s\nCameraType: %s\n',sceneName, ...
    erase(roadData.skymap,'.exr'), camera_type);
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
        'image_id',sprintf('%d',imageID),'bbox',pos,'category_id',catId,'id',0,'ignore',0);
    fprintf('Class %s, instanceID: %d \n', label, ii);
    nBox = nBox+1;
end
truesize;
% %{

imgName = sprintf('%d.png',imageID);

% Image_coco = struct('file_name',imgName,'height',h,'width',w,'id',sprintf('%d',imageID));
%
% % write files out
% save(fullfile(datasetFolder, sprintf('%d_image.mat',imageID)),'Image_coco');
% save(fullfile(datasetFolder, sprintf('%d_anno.mat',imageID)), 'Annotation_coco');

imgFilePath  = fullfile(datasetFolder,'rgb',imgName);
imwrite(radiance,imgFilePath);

imwrite(uint16(instanceMap),fullfile(datasetFolder,'segmentation',imgName));
imwrite(uint16(rendered.depthMap),fullfile(datasetFolder,'depth',imgName));
outputFolder = roadData.recipe.get('outputdir');
movefile(fullfile(outputFolder,sprintf('renderings/%d.exr',imageID)),fullfile(datasetFolder,'rendered/'));
%}
fprintf('****** Scene%d Generated! ******\n',nScene);
% end

%% End
