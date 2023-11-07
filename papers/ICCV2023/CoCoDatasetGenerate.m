%%
% mex('CFLAGS=\$CFLAGS -Wall -std=c99','-largeArrayDims',...
%     'private/maskApiMex.c','../common/maskApi.c',...
%     '-I../common/','-outdir','private');
% coco annotation categories: https://tech.amikelive.com/node-718/what-object-categories-labels-are-in-coco-dataset/comment-page-1/
ieInit;

%% Info
info.description = 'Stanford Nighttime Scene Dataset';
info.url = '';
info.version = '1.0';
info.year = 2022;
info.contributor = 'Zhenyi Liu';
info.data_created = datestr(now,26);
data.info = info;
%% licenses 
% No licenses
data.licenses = [];
%% Categories

catNames = ["person", "deer", "car", "bus", "truck", "bicycle", "motorcycle"];
catIds   = [0, 17, 2, 5, 7, 1, 3]; % use horse class for deer when training yolo
% BDD----
% catNames = ["pedestrain", "rider", "car", "truck", "bus", "train", "motorcycle", "bicycle", "traffic light", "traffic sign"];
% catIds   = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
% BDD---
dataDict = dictionary(catNames, catIds);
% categories{1} = struct('supercategory','person','id',dataDict("pedestrain"),'name','pedestrain');
categories{1} =struct('supercategory','animal','id',dataDict("deer"),'name','deer');%
% yolo
categories{2} = struct('supercategory','person','id',dataDict("person"),'name','person');
categories{3} = struct('supercategory','vehicle','id',dataDict("car"),'name','car');
categories{4} = struct('supercategory','vehicle','id',dataDict("bus"),'name','bus');
categories{5} = struct('supercategory','vehicle','id',dataDict("truck"),'name','truck');
categories{6} = struct('supercategory','vehicle','id',dataDict("bicycle"),'name','bicycle');
categories{7} = struct('supercategory','vehicle','id',dataDict("motorcycle"),'name','motorcycle');

data.categories = categories;
%{
%% images
dataset_dir = '/Volumes/SSDZhenyi/Ford Project/dataset/ford_dataset';
imgList = dir(sprintf('%s/rgb/*.png',dataset_dir));
%%
% images = cell(size(imgList,1),1);
nn_anno = 1;n_img = 1;
% anno_uniqueID = randperm(n,k);
for ii = 1:numel(imgList)
    if strncmp(imgList(ii).name, '._',2)
        continue;
    end
    imgName = erase(imgList(ii).name,{'.png'});
    imgId   = erase(imgList(ii).name,{'.png','T'});% otherwise too long to save
    imgId   = str2double(imgId(6:end));

    newFilePath = fullfile(dataset_dir,'rgb',[sprintf('%d',imgId),'.png']);
    if ~exist(newFilePath,'file')
        thisImgOld = fullfile(dataset_dir,'rgb',imgList(ii).name);
        newFilePath = fullfile(dataset_dir,'rgb',[sprintf('%d',imgId),'.png']);
        movefile(thisImgOld,newFilePath);

        thisImgOld = fullfile(dataset_dir,'depth',imgList(ii).name);
        newFilePath = fullfile(dataset_dir,'depth',[sprintf('%d',imgId),'.png']);
        movefile(thisImgOld,newFilePath);

        thisImgOld = fullfile(dataset_dir,'segmentation',imgList(ii).name);
        newFilePath = fullfile(dataset_dir,'segmentation',[sprintf('%d',imgId),'.png']);
        movefile(thisImgOld,newFilePath);

        thisFileOld = fullfile(dataset_dir,'additionalInfo',strrep(imgList(ii).name,'.png','.txt'));        
        newFilePath = fullfile(dataset_dir,'additionalInfo',[sprintf('%d',imgId),'.txt']);
        movefile(thisFileOld,newFilePath);
    end
    % image

    Image_coco = load(sprintf('%s/%s_image.mat',dataset_dir,imgName),'Image_coco');

    thisFileOld = sprintf('%s/%s_image.mat',dataset_dir,imgName);
    newFilePath = sprintf('%s/%s_image.mat',dataset_dir,[sprintf('%d',imgId)]);
    movefile(thisFileOld,newFilePath);

    Image_coco = Image_coco.Image_coco;
    Image_coco.file_name = sprintf('%d.png',imgId);
    Image_coco.id = imgId;  % my mistake here, no need in the future;
    images{n_img} = Image_coco;
    
    % annotation
    Anno_coco = load(sprintf('%s/%s_anno.mat',dataset_dir,imgName),'Annotation_coco');
    Anno_coco = Anno_coco.Annotation_coco;

    for nn = 1:numel(Anno_coco)
        Anno_coco{nn}.image_id = imgId;  % my mistake here, no need in the future;
        if Anno_coco{nn}.category_id == 2
            Anno_coco{nn}.category_id = 3;
        end
        annotations{nn_anno} = Anno_coco{nn};
        nn_anno = nn_anno + 1;
    end

    n_img = n_img + 1;

end
% coco needs a random unique number for each annoation;
anno_uniqueID = randperm(100000,numel(annotations));
for nn = 1:numel(annotations)
    annotations{nn}.id = anno_uniqueID(nn);
end

data.images = images;
data.annotations = annotations;
%%    
clk = tic;
annFile = fullfile(dataset_dir, 'annotations.json');
f=fopen(annFile,'w'); fwrite(f,gason(data)); fclose(f);
fprintf('DONE (t=%0.2fs).\n',toc(clk));
%% Test
cd(dataset_dir);
annFile = 'annotations.json';
coco=CocoApi(annFile);
dataType = [];
%% get all images containing given categories, select one at random
catIds = coco.getCatIds('catNms',{'car','deer'});
for ii = 1:numel(coco.data.images)
    imgId  = coco.data.images(ii).id;
    % load and display image
    img = coco.loadImgs(imgId);
    I = imread(sprintf('rgb/%s',img.file_name));
    figure(1); imagesc(I); axis('image'); set(gca,'XTick',[],'YTick',[]);
    fprintf('No.%d ImageId: %13d\n',ii,imgId);
    % load and display annotations
    annIds = coco.getAnnIds('imgIds',imgId,'catIds',catIds,'iscrowd',[]);
    anns   = coco.loadAnns(annIds); coco.showAnns(anns);
    pause();
end
%}

%% TMP debug
% %{
% datasetFolder = '/Volumes/SSDZhenyi/Ford Project/dataset/driving_night';
% imgList = dir(sprintf('%s/renderings/*.mat',datasetFolder));

metaFolder = '/acorn/data/iset/isetauto/Ford/SceneMetadata';
sceneNames = load(fullfile(iaRootPath, 'papers/ICCV2023','scenenames_cleanup'));
sceneNames = sceneNames.sceneNameList;
outputFolder = '/acorn/data/iset/isetauto/Ford/Flare_paper';
if ~exist(outputFolder, 'dir'), mkdir(outputFolder);end
% imageID = '20220328T155503';
nBox=1;
nImage = 1;
annotations={};
%%
for ss = 1:numel(sceneNames)

    imageID = erase(sceneNames{ss},'.png');
    sceneMeta = load(fullfile(metaFolder, [imageID, '.mat']));
    sceneMeta = sceneMeta.sceneMeta;
    instanceMap = sceneMeta.instanceMap;
    objectslist = sceneMeta.objectslist;
   
    [h,w,~] = size(instanceMap);
    % write out object ID for segmentation map;
    % seg_FID = fopen(fullfile(datasetFolder,'additionalInfo',[imageID,'.txt']),'w+');
    % fprintf(seg_FID,'sceneName: %s\nSkymap: %s\nCameraType: %s\n',sceneName, ...
    %     erase(sceneData.skymap,'.exr'), camera_type);
    % fprintf(seg_FID,'Object ID:\n');
%     Annotation_coco = [];
    
    for ii = 1:numel(sceneMeta.target)
%         name = objectslist{ii};
        name = sceneMeta.target(ii).name;
        namesplit = strsplit(name,' ');
        instanceIndex = str2num(namesplit{1});
%         if sceneMeta.target(ii).distance > 100
%             continue;
%         end
%         name = erase(name,{'ObjectInstance ', '"', '_m'});
        %     fprintf(seg_FID, '%d %s \n',ii, name);
        if contains(lower(name), {'car'})
            label = 'car';
            catId = dataDict('car');
%             r = 0.1; g= 0.5; b = 0.1;
%         elseif contains(lower(name),'deer')
%             label = 'Deer';
%             catId = dataDict('deer');
        elseif contains(lower(name),["person", "pedestrian"])
            lable = 'Person';
            catId = dataDict('person');
        elseif contains(lower(name), 'bus')
            label = 'bus';
            catId = dataDict('bus');  
        elseif contains(lower(name), 'truck')
            label = 'truck';
            catId = dataDict('truck'); 
        elseif contains(lower(name), ["bicycle", "bike"])
            label = 'bicycle';
            catId = dataDict('bicycle'); 
        elseif contains(lower(name), ["motorbicycle", "motorbike", "otorbike"])
            label = 'motorcycle';
            catId = dataDict('motorbicycle');
%             Id = 9;
%             r = 1; g= 0.1; b = 0.1;
        else
            continue;
        end
        [occluded, truncated, bbox2d, segmentation, area] = piAnnotationGet(instanceMap,instanceIndex,0);
        if isempty(bbox2d), continue;end
        pos = [bbox2d.xmin bbox2d.ymin ...
            bbox2d.xmax-bbox2d.xmin ...
            bbox2d.ymax-bbox2d.ymin];
        if pos(3)<5 && pos(4)<5
            continue
        end
%         if pos(4)<500 && pos(3)>960
%             continue
%         end
%         rectangle('Position',pos,'EdgeColor',[r g b],'LineWidth',1);
%         tex=text(bbox2d.xmin+2.5,bbox2d.ymin-8,label);
%         tex.Color = [1 1 1];
%         tex.BackgroundColor = [r g b];
%         tex.FontSize = 12;
        if area == 0
            fprintf('No target found in %s.\n',imageID);
            continue;
        end
        annotations{nBox} = struct('segmentation',segmentation,'area',area,'iscrowd',0,...
            'image_id',str2double(imageID),'bbox',pos,'category_id',catId,'id',0,'ignore',0);
        fprintf('Class %s, catId: %d \n', label, catId);
        nBox = nBox+1;
    end
%     truesize;
    %%

    imgName = sprintf('%d.png',str2double(imageID));

    images{nImage} = struct('file_name',imgName,'height',h,'width',w,'id',str2double(imageID));

    % write files out
%     save(fullfile(datasetFolder, sprintf('%s_image.mat',imageID)),'Image_coco');
%     save(fullfile(datasetFolder, sprintf('%s_anno.mat',imageID)), 'Annotation_coco');

%     imgFilePath  = fullfile(datasetFolder,'rgb',imgName);
%     imwrite(radiance,imgFilePath);

%     imwrite(uint16(instanceMap),fullfile(datasetFolder,'segmentation',imgName));
%     imwrite(uint16(depth),fullfile(datasetFolder,'depth',imgName));
%     outputFolder = sceneData.recipe.get('outputdir');
%     movefile(fullfile(outputFolder,'renderings/*.exr'),fullfile(datasetFolder,'rendered/'));
    nImage = nImage + 1;
end

%%
anno_uniqueID = randperm(100000,numel(annotations));
for nn = 1:numel(annotations)
    annotations{nn}.id = anno_uniqueID(nn);
end

data.images = images;
data.annotations = annotations;

clk = tic;
annFile = fullfile(outputFolder, 'ISETCoco_annotations.json');
f=fopen(annFile,'w'); fwrite(f,gason(data)); fclose(f);
fprintf('DONE (t=%0.2fs).\n',toc(clk));

%%
%{
imgFolder = '/acorn/data/iset/isetauto/Ford/Flare_paper/Flare_corrupted/pixel4a/drityLevel_3';
cd(imgFolder);
%
coco=CocoApi(annFile);
dataType = [];
% get all images containing given categories, select one at random
catIds = coco.getCatIds('catNms',{'person','car','bus','truck','bicycle','motorcycle','deer'});
for ii = 1:numel(coco.data.images)
    imgId  = coco.data.images(ii).id;
    % load and display image
    img = coco.loadImgs(imgId);
    I = imread(fullfile(imgFolder,img.file_name));
    figure(1); imagesc(I); axis('image'); set(gca,'XTick',[],'YTick',[]);
    fprintf('No.%d ImageId: %13d\n',ii,imgId);
    % load and display annotations
%     annIds = coco.getAnnIds('imgIds',imgId,'catIds',catIds,'iscrowd',[]);
    annIds = coco.getAnnIds('imgIds',imgId);
    anns   = coco.loadAnns(annIds); coco.showAnns(anns);
    pause();
end
%%

%}