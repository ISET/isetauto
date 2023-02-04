% get luminance

lum = sceneGet(scene,'luminance');

[h,w] = size(lum);
lightsourceMask = zeros(h, w);

% using threshold as 1e5 for light source luminance level
lightsourceMask(lum>1.5e5)=1; 

% figure;imagesc(lightsourceMask); 
figure;
imagesc(lum); hold on
% find connected pixel groups
ccomp = bwconncomp(lightsourceMask);
for ii = 1:ccomp.NumObjects
    [rows,cols] = ind2sub([h,w], ccomp.PixelIdxList{ii});
     lightSourcePosList(ii,:)= [mean(rows), mean(cols)];
     scatter(mean(cols),mean(rows),100,'^');hold on
end

oi = piOICreate(scene.data.photons);
[ip,sensor] = piRadiance2RGB(oi);
ipWindow(ip);

rgb = demosaic(uint16(sensor.data.dv),'grbg');
base_img = double(rgb)/(2.^12-1);
% % base_img(base_img>1)=1;
% srgb = lrgb2srgb(base_img);
% 
% figure;imshow(srgb);

flareFiles = dir('/Volumes/SSDZhenyi/Ford Project/Flare/Flare7k/Scattering_Flare/Compound_Flare/img_*.png');

flare_size = 128;
for ii = 1: length(lightSourcePosList)
    index = randi(5000,1);
    flare_image = imread(fullfile(flareFiles(index).folder, flareFiles(index).name));
    flare_image = double(flare_image)/255;
    flare_image = imresize(flare_image, [flare_size, flare_size]);
    lightPos = round(lightSourcePosList(ii,:));
    base_img(lightPos(1)-flare_size/2:lightPos(1)+flare_size/2-1, lightPos(2)-flare_size/2:lightPos(2)+flare_size/2-1,:) = ...
        base_img(lightPos(1)-flare_size/2:lightPos(1)+flare_size/2-1, lightPos(2)-flare_size/2:lightPos(2)+flare_size/2-1,:) + flare_image;
end

base_img(base_img>1)=1;
srgb = lrgb2srgb(base_img);

figure;imshow(srgb);