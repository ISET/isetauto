%% generate flare dataset 
sceneDir = '/acorn/data/iset/isetauto/Ford/Flare_paper/SceneMats_002';
sceneNames = load(fullfile(iaRootPath, 'papers/ICCV2023','scenenames_cleanup'));
sceneNames = sceneNames.sceneNameList;
% baseRGB_dir='/acorn/data/iset/isetauto/Ford/Flare_paper/Flare_free/pinhole';
output_dir ='/acorn/data/iset/isetauto/Ford/Flare_paper/Flare_corrupted_002/flare7k_large_correct_01';
if ~exist(output_dir,'dir'),mkdir(output_dir);end
outputPH_gt = '/acorn/data/iset/isetauto/Ford/Flare_paper/Flare_free_002';
for ii = 2:numel(sceneNames)
%     if exist(sprintf('%s/%s',output_dir, sceneNames{ii}),'file')
%         continue;
%     end
    thisLoad = load(fullfile(sceneDir, strrep(sceneNames{ii},'.png','.mat'))); % for parfor
    scene    = thisLoad.scene;

    [oi_gt, ~,~]= piFlareApply(scene,'fnumber',1.7,'focal length',4.38e-3,...
    'psfsamplespacing',0.7e-6,'dirtylevel',0); % pixel4a
   
    oi_gt.wAngular = 34.2;
    meanilluminance = oiGet(oi_gt, 'mean illuminance');  
    
    oi = oi_gt;
    oi = oiSet(oi,'photons',oiCalculateIrradiance(scene,oi_gt));

    oi = oiAdjustIlluminance(oi, meanilluminance);
    sensor = sensorCreate('IMX363');
    sensor = sensorSet(sensor,'pixel size same fill factor',1.4*1e-6);

%     exposureTime = autoExposure(oi,sensor,0.90,'weighted','center rect',round([429 351.0000 993 471.0000]));
    sensor = sensorSet(sensor, 'exposure time',1/60);
    oiSize = oiGet(oi_gt,'size');
    sensor = sensorSet(sensor, 'size', oiSize);
    sensor = sensorCompute(sensor, oi);
    ip = ipCreate;
    ip = ipSet(ip,'conversion method sensor','MCC Optimized');
    ip = ipSet(ip,'illuminant correction method','gray world');
    ip = ipSet(ip,'demosaic method','Adaptive Laplacian');
    ip = ipCompute(ip,sensor);
    rgb_pinhole = ipGet(ip, 'srgb');
    imgPath = fullfile(outputPH_gt, sprintf('pinhole/%s', sceneNames{ii}));
%     imwrite(rgb_pinhole, imgPath);
%% Add Flare from Flare7K
    flareFiles = dir('/acorn/data/iset/isetauto/dataset/flare7k/Flare7k/Scattering_Flare/Compound_Flare/img_*.png');
    base_img = ipGet(ip, 'result');
     base_img_Free = base_img;
%     base_img = ipGet(ip,'srgb');
%     flare_size = round(256*(rand(1)*1+0.5));
    flare_size = 1920;
    if mod(flare_size,2),flare_size = flare_size+1;end
    index = randi(5000,1);
    flare_image = imread(fullfile(flareFiles(index).folder, flareFiles(index).name));
    flare_image = double(flare_image)/255;
    flare_image = imresize(flare_image, [flare_size, flare_size]);
    lightsourceMask =imread(sprintf('/acorn/data/iset/isetauto/Ford/Flare_paper/Flare_free/lightmask/%s',sceneNames{ii}));
    intensity_base = rgb2gray(base_img);
    flare_image_linear = srgb2lrgb(flare_image);

    intensity_flare = flare_image_linear(:,:,1)*0.2126+...
        flare_image_linear(:,:,2)*0.7152+flare_image_linear(:,:,3)*0.0722;

    h = 1080; w = 1920;
%     lum = sceneGet(scene,'luminance');
%     % scene = sceneAdjustLuminance(scene,10);
%     [h,w] = size(lum);
%     lightsourceMask = zeros(h, w);
% 
%     % using threshold as 1e5 for light source luminance level
%     lightsourceMask(lum>5e3)=1;
%     imwrite(lightsourceMask, sprintf('/acorn/data/iset/isetauto/Ford/Flare_paper/Flare_free/lightmask/%s', ...
%         sceneNames{ii}));
    % find connected pixel groups
    ccomp = bwconncomp(lightsourceMask);
    flare_scale = 0.4+rand()*0.4;
    try
    lightPos_previous = [0,0];
    for mm = 1:ccomp.NumObjects
        [rows,cols] = ind2sub([h, w], ccomp.PixelIdxList{mm});

        lightPos_current = round([mean(rows), mean(cols)]);
        if sqrt((lightPos_previous(2)-lightPos_current(2))^2 + (lightPos_previous(1)-lightPos_current(1))^2)<30
            disp('Light sources too close');
            continue;
        end
        flare_image_new = flare_image;
        %
        % Account for spatial variant intensity and color of light source
        
        r_mean = mean2(base_img(rows, cols, 1));
        g_mean = mean2(base_img(rows, cols, 2));
        b_mean = mean2(base_img(rows, cols, 3));
%         i_mean = mean2(intensity_base(rows, cols));

        
        flare_image_new(:,:, 1) = r_mean*intensity_flare*flare_scale;
        flare_image_new(:,:, 2) = g_mean*intensity_flare*flare_scale;
        flare_image_new(:,:, 3) = b_mean*intensity_flare*flare_scale;
        %}
       

        base_img(min(max(lightPos_current(1)-flare_size/2:lightPos_current(1)+flare_size/2-1,1), h), ...
            min(max(lightPos_current(2)-flare_size/2:lightPos_current(2)+flare_size/2-1,1), w),:) = ...
            base_img(min(max(lightPos_current(1)-flare_size/2:lightPos_current(1)+flare_size/2-1, 1), h), ...
            min(max(lightPos_current(2)-flare_size/2:lightPos_current(2)+flare_size/2-1, 1), w),:) + ...
            flare_image_new;      

        lightPos_previous = lightPos_current;
    end
    % control flare amount
    % convolution method

    for cc = 1:3
        thisFlare = intensity_flare(:,:,1);
        thisFlare = thisFlare ./ sum(thisFlare(:));
        base_img_flared(:,:,cc) = ImageConvFrequencyDomain(base_img_Free(:,:,cc), thisFlare, 2);
    end
    flareAlpha = 0.5;
    base_img_conv = base_img_Free*(1-flareAlpha) + base_img_flared*flareAlpha;
    base_img_conv(base_img_conv>1) = 1;
    base_img(base_img>1) = 1;

   ip = ipSet(ip,'result',base_img);
   srgb = ipGet(ip,'srgb');

   ip = ipSet(ip,'result',base_img_conv);
   srgb_conv = ipGet(ip,'srgb');
    catch
        fprintf('%d: something is wrong.\n',ii);
        continue;
    end
   figure;imshow(srgb);title('Directly Placing Flare Pattern');
   figure;imshow(srgb_conv);title('Flare Conv');
    imwrite(srgb, sprintf('%s/%s',output_dir, sceneNames{ii}));
    disp(ii);

end
disp('DONE!!!')
