%% Illustrates rendering a scene exported from blender using blender2pbrt exporter
%
% Zhenyi, 2022
%%
ieInit;
if ~piDockerExists, piDockerConfig; end
%%
rootDir = '/Volumes/SSDZhenyi/Ford Project/PBRT_assets';
asset_type = 'cars';
scene_name = 'ford_mustang';
fileName = fullfile(rootDir, asset_type, scene_name,[scene_name,'.pbrt']);
thisR = piRead(fileName);
%%
currRes = [1280,720];
thisR.set('film resolution',currRes/2);
thisR.set('rays per pixel',128/2);
thisR.set('nbounces',5);
%%
% fileName = 'noon_009.exr';
%{
night.exr
noon_009.exr
%}
exampleEnvLight = piLightCreate('skylight', ...
    'type', 'infinite',...
    'spd', [0.55 0.4 0.4]);
thisR.set('light', exampleEnvLight, 'add');
% % 
% scene.skymap = fileName;
%% set render type
thisR.set('film render type',{'radiance','depth'});

%% write the data out
% scene = piWRS(thisR);
piWrite(thisR);
% thisR.lights{1} = exampleEnvLight;
% piLightWrite(thisR);
rendered = piRenderZhenyi(thisR,'device','gpu');
%
oi = piOICreate(rendered.data.photons,'mean illuminance',100);
% sceneWindow(scene);
% oi = piAIdenoise(oi);
oiWindow(oi);
%%
% %{
ip = piRadiance2RGB(oi,'etime',1/150,'sensor','MT9V024SensorRGB');
ipWindow(ip);
radiance = ipGet(ip,'srgb');
datasetFolder = fullfile(piRootPath, 'local/deer_dataset');
imageID = 1;
imgName = sprintf('%06d.png',imageID);
imgFilePath  = fullfile(datasetFolder,'data',imgName);
imwrite(radiance,imgFilePath);
[h,w,c]=size(radiance);
%{
% turn off axis marker/label for figure
set(gca, 'Visible', 'off')
%}
%% render instance label
thisR.set('rays per pixel',32);
thisR.set('nbounces',1);
thisR.set('film render type',{'instance'});
% add this line: Shape "sphere" "float radius" 500 
thisR.world(numel(thisR.world)+1) = {'Shape "sphere" "float radius" 5000'};

piWrite(thisR);
oiInstance = piRenderZhenyi(thisR,'device','cpu');

instanceID = oiInstance.metadata.instanceID;
figure;imagesc(instanceID);
set(gca, 'Visible', 'off');% turn off axis marker/label for figure
%% Get object instance list

objectslist = thisR.world(piContains(thisR.world,'ObjectInstance'));
%%
Image_coco = struct('file_name',imgName,'height',h,'width',w,'id',sprintf('%06d',imageID));

figure;imshow(radiance);
nBox=1;
nImage = 1;
Annotation={};
for ii = 1:numel(objectslist)
    name = objectslist{ii};
    if contains(lower(name), {'car','pickup','skoda','infinite'})
        label = 'vehicle';
        r = 0.1; g= 0.5; b = 0.1;
    elseif contains(lower(name),'deer')
        label = 'Deer';
        catId = 1;
        r = 1; g= 0.1; b = 0.1;
    else
        continue;
    end 
    [occluded, truncated, bbox2d, segmentation, area] = piAnnotationGet(instanceID,ii,0);
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
        'image_id',sprintf('%06d',imageID),'bbox',pos,'category_id',catId,'id',0,'ignore',0);
    nBox = nBox+1;
end
% save(fullfile(datasetFolder, sprintf('%06d_image.mat',imageID)),'Image_coco');
% save(fullfile(datasetFolder, sprintf('%06d_anno.mat',imageID)), 'Annotation_coco');

%}  
%%
% data, year, split, annFile
% generateCocoDt(dataSet, categories, year, split, annFile)
% CocoUtils.generateCocoDt(Annotation, categories, 2022, 'test',fullfile(datasetFolder, 'demo_annotation.json'));

% coco=CocoApi('demo_annotation.json');

%{
%% 
lensfile  = 'wide.40deg.6.0mm.json';    % 30 38 18 10
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);


% blocking skymap for instanceID
Shape "sphere" "float radius" 500 
%}
%{
% the piece that needs to insert as fog
AttributeBegin
    Translate -100 -30 -20
    MakeNamedMedium "foo" "string type" "nanovdb" # "homogeneous" #
    #"string filename" "/home/zhenyi/Documents/blender/FLAT/HD/high-altitude_big_cloud_flat.14.nvdb"
    "string filename" "/home/zhenyi/Documents/blender/data/fog.nvdb"
    "spectrum sigma_s" [400 0.8 900 0.8] "spectrum sigma_a" [400 0 900 0]
AttributeEnd

AttributeBegin
Translate 0 0.00000 100
MediumInterface "foo" ""
Material "interface"
Shape "sphere" "float radius" 209
AttributeEnd
%}


