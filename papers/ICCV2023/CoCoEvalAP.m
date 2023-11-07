cocoDt = CocoApi('/acorn/data/iset/isetauto/Ford/SAE_Eval/COCO_format/pixel4a/annotations/instances_val2017_pred.json');

cocoGt = CocoApi('/acorn/data/iset/isetauto/Ford/SAE_Eval/COCO_format/pixel4a/annotations/instances_val2017.json');

% cocoGt = cocoDt;
for ii  = 1 : numel(cocoGt.data.annotations)
cocoGt.data.annotations(ii).area = 1e5;
end
% cocoGt = cocoDt;

type = {'bbox'};
cocoEval=CocoEval(cocoGt,cocoDt,type);
cocoEval.params.catIds = 2;
% cocoEval.params.areaRng=[];
imgIds=sort(cocoDt.getImgIds());
cocoEval.params.imgIds=imgIds;
cocoEval.evaluate();
cocoEval.accumulate();
cocoEval.summarize();


%% Visulize

imgDir = '/acorn/data/iset/isetauto/Ford/SAE_Eval/COCO_format/pixel4a/val2017';

coco = cocoDt;
dataType = [];
% get all images containing given categories, select one at random
% catIds = coco.getCatIds('catNms',{'car'});
for ii = 1:numel(coco.data.images)
    imgId  = coco.data.images(ii).id;
    % load and display image
    img = coco.loadImgs(imgId);
    I = imread(fullfile(imgDir,img.file_name));
    figure(1); imagesc(I); axis('image'); set(gca,'XTick',[],'YTick',[]); hold on
    fprintf('No.%d ImageId: %13d\n',ii,imgId);
    % load and display annotations
%     annIds = coco.getAnnIds('imgIds',imgId,'catIds',catIds,'iscrowd',[]);
    annIds = coco.getAnnIds('imgIds',imgId);

    anns   = coco.loadAnns(annIds); 
%     anns = rmfield(anns, 'segmentation');
    coco.showAnns(anns); 

    pause();
end