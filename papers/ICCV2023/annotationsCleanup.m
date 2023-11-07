%% combine all annotations

annFile = '/acorn/data/iset/isetauto/dataset/eval/skymap_scale10/annotations/annotations_001.json';
sceneNames = load(fullfile(iaRootPath, 'papers/ICCV2023','scenenames_cleanup'));
sceneNames = sceneNames.sceneNameList;

nImage = 1;
nBox   = 1;
for ii = 1:12
    annFile = sprintf('/acorn/data/iset/isetauto/dataset/eval/skymap_scale10/annotations/annotations_%03d.json',ii);

    coco = CocoApi(annFile);

    for ll = 1:numel(coco.inds.imgIds)
        imgId = coco.inds.imgIds(ll);
        if ~find(contains(sceneNames, num2str(imgId)))
            continue;
        end
%         catIds = coco.getCatIds('catNms',{'person','car','bus','truck','bike','motorbike','deer'});
        annIds = coco.getAnnIds('imgIds',imgId);
        for aa = 1:numel(annIds)
            annotations{nBox} = coco.loadAnns(annIds(aa));
            nBox = nBox+1;
        end

        images{nImage} = coco.loadImgs(imgId);

        nImage = nImage +1;
    end
end
data.images = images;
data.annotations = annotations;
data.info = coco.data.info;
data.licenses = coco.data.licenses;
data.categores = coco.data.categories;

annFile = '/acorn/data/iset/isetauto/dataset/eval/isetnight_annotations.json';
f=fopen(annFile,'w'); fwrite(f,gason(data)); fclose(f);


%% test
cocoNew = CocoApi(annFile);
catIds = cocoNew.getCatIds('catNms',{'person','car','bus','truck','bike','motorbike'});



