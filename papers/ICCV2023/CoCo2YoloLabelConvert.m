% covnert annotation format from CoCo to Yolo
imgFolder = '/acorn/data/iset/isetauto/Ford/Flare_paper/Flare_corrupted/flare7k';
outputFolder = '/acorn/data/iset/isetauto/Ford/Flare_paper/Flare_corrupted/pixel4a_yolo/flare7k';mkdir(outputFolder);
cd(outputFolder);

imgDir_train = 'images/train';
labelDir_train ='labels/train';
imgDir_val  = 'images/val';
labelDir_val = 'labels/val';

if ~exist(imgDir_train,'dir')
    mkdir(imgDir_train), mkdir(labelDir_train), mkdir(imgDir_val), mkdir(labelDir_val); 
end

annFile = '/acorn/data/iset/isetauto/Ford/Flare_paper/annotations.json';
coco=CocoApi(annFile);
dataType = [];
% catIds = coco.getCatIds('catNms',{'person','car','bus','truck','bike','motorbike'});
%%
% nn = 0;
for ii = 1:numel(coco.inds.imgIds) % train 1607, val 401
    if ii<1636
        imgDir = imgDir_train;
        labelDir = labelDir_train;
    else
        imgDir = imgDir_val;
        labelDir = labelDir_val;
    end
    imgId = coco.inds.imgIds(ii);
    % load and display image
    img = coco.loadImgs(imgId);

    if ~exist(fullfile(imgFolder,img.file_name))
        continue;
    end

    copyfile(fullfile(imgFolder,img.file_name), ...
        fullfile(imgDir, img.file_name));
%{
    annIds = coco.getAnnIds('imgIds',imgId);
    anns   = coco.loadAnns(annIds); % coco.showAnns(anns);

    if isempty(anns), fprintf('No objects find in %d. \n',imgId);continue;end

    fid = fopen(fullfile(labelDir,sprintf('%s.txt',num2str(imgId))),"w+");
    for ll = 1:length(anns)
        thisAnns = anns(ll);
        % id, xcenter, ycenter, width, height
        if thisAnns.category_id>10, thisAnns.category_id = 17;end % send deer to horse class
   
        
        fprintf(fid,'%d %06f %06f %06f %06f \n',thisAnns.category_id, ...
            (thisAnns.bbox(1)+thisAnns.bbox(3)/2)/img.width, ...
            (thisAnns.bbox(2)+thisAnns.bbox(4)/2)/img.height, ...
            thisAnns.bbox(3)/img.width, ...
            thisAnns.bbox(4)/img.height);
    end
%}
%     nn = nn +1;
%     if nn==1620, disp(ii),break;end
end


