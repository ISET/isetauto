% get luminance
%% add
sceneNames = load(fullfile(iaRootPath, 'papers/ICCV2023','scenenames_cleanup'));
sceneNames = sceneNames.sceneNameList;
sceneDir = '/acorn/data/iset/isetauto/Ford/Flare_paper/SceneMats';

ii = 1;

% load('/acorn/data/iset/isetauto/dataset/skymap_scale10/nighttime_001/1112160159.mat');
%%
thisLoad = load(fullfile(sceneDir, strrep(sceneNames{ii},'.png','.mat')));
scene    = thisLoad.scene;
lum = sceneGet(scene,'luminance');
% scene = sceneAdjustLuminance(scene,10);
[h,w] = size(lum);
lightsourceMask = zeros(h, w);

% using threshold as 1e5 for light source luminance level
lightsourceMask(lum>1.5e5)=1; 

% find connected pixel groups
ccomp = bwconncomp(lightsourceMask);
for ii = 1:ccomp.NumObjects
    [rows,cols] = ind2sub([h,w], ccomp.PixelIdxList{ii});
     lightSourcePosList(ii,:)= [mean(rows), mean(cols)];
     scatter(mean(cols),mean(rows),100,'^');hold on
end
% without optics
oi = piOICreate(scene.data.photons);
[ip,sensor] = piRadiance2RGB(oi,'etime',1/30);
ipWindow(ip);

rgb = demosaic(uint16(sensor.data.dv),'grbg');

% % base_img(base_img>1)=1;
% srgb = lrgb2srgb(base_img);
% 
% figure;imshow(srgb);

flareFiles = dir('/acorn/data/iset/isetauto/dataset/flare7k/Flare7k/Scattering_Flare/Compound_Flare/img_*.png');
%%
base_img = double(rgb)/(2.^12-1);
flare_size = 128;
index = randi(5000,1);
flare_image = imread(fullfile(flareFiles(index).folder, flareFiles(index).name));
flare_image = double(flare_image)/255;
flare_image = imresize(flare_image, [flare_size, flare_size]);

for ii = 1: size(lightSourcePosList,1)
    lightPos = round(lightSourcePosList(ii,:));
    base_img(lightPos(1)-flare_size/2:lightPos(1)+flare_size/2-1, lightPos(2)-flare_size/2:lightPos(2)+flare_size/2-1,:) = ...
        base_img(lightPos(1)-flare_size/2:lightPos(1)+flare_size/2-1, lightPos(2)-flare_size/2:lightPos(2)+flare_size/2-1,:) + flare_image;
end

base_img(base_img>1)=1;
base_img(base_img<0)=0;
srgb = lrgb2srgb(base_img);

figure;imshow(srgb);