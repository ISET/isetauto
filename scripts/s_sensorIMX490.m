%% Simulate a IMX490 sensor
% ieInit;
DR = 1e5; % dynamic range
nPatches = ceil(log2(DR));
sceneSize = 512;
[scene,patches] = sceneCreateHDR(sceneSize*3,nPatches,1);

%
%% Interpolation the scene to be 3 times bigger.
% sSize = sceneGet(scene, 'size');
% nWave = 31;
% newPhotons = zeros(sSize(1)*3, sSize(2)*3, nWave);
% 
% for ii = 1:nWave
%     newPhotons(:,:,ii) = imresize(scene.data.photons(:,:,ii),[sSize(1)*3, sSize(2)*3]);
% end
% scene = sceneSet(scene,'photons',newPhotons);
%%
scene = sceneSet(scene,'fov',20);
scene = sceneAdjustLuminance(scene,'peak',DR);
%%
oi = oiCreate('shift invariant');

oi = oiSet(oi,'fnumber',8);
oi = oiSet(oi,'focal length',8e-3,'m');
wvf = wvfCreate();
wvf = wvfSet(wvf, 'spatial samples', 1024);
[aperture, params] = wvfAperture(wvf,'nsides',0,...
    'dot mean',50, 'dot sd',20, 'dot opacity',0.5,'dot radius',5,...
    'line mean',50, 'line sd', 20, 'line opacity',0.5,'linewidth',2);
oi = oiCompute(oi, scene,'aperture',aperture);

oi = oiCrop(oi,'border');
oiWindow(oi);
oi = oiSet(oi,'displaymode','hdr');

oiDelta = oiGet(oi,'sample spacing','um');
oiDelta = oiDelta(1);
oiSize = oiGet(oi,'size');
%%
% expsureTime = repmat(1/20,1,5);
%{
expsureTime = 1/4000;
lpixel_hgain = sensorIMX363(...
    'pixelsize', 3*oiDelta*1e-6, ...
    'quantization', '12 bit',...
    'qefilename',colorFilterFile, ...
    'wellcapacity',120000,'fillfactor',1,'isospeed',55,'exposuretime',expsureTime, ...
    'rowcol',ceil([oiSize(1) oiSize(2)]/3));

lpixel_lgain = sensorIMX363('pixelsize', 3*oiDelta*1e-6, ...
    'quantization', '12 bit',...
    'qefilename',colorFilterFile, ...
    'wellcapacity',120000,'fillfactor',1,'isospeed',55,'exposuretime',expsureTime, ...
    'rowcol',ceil([oiSize(1) oiSize(2)]/3));

spixel_hgain = sensorIMX363('pixelsize', oiDelta*1e-6, ...
    'quantization', '12 bit',...
    'qefilename',colorFilterFile, ...
    'wellcapacity',60000,'fillfactor',1,'isospeed',55,'exposuretime',expsureTime, ...
    'rowcol',[oiSize(1) oiSize(2)]);

spixel_lgain = sensorIMX363('pixelsize', oiDelta*1e-6, ...
    'quantization', '12 bit',...
    'qefilename',colorFilterFile, ...
    'wellcapacity',60000,'fillfactor',1,'isospeed',55,'exposuretime',expsureTime, ...
    'rowcol',[oiSize(1) oiSize(2)]);
%
analog_gain = [1/32,1/16,1/2,1];
% analog_gain = [1/16,1/8,1/2,1];

lpixel_hgain = sensorSet(lpixel_hgain,'analog gain', analog_gain(1));

lpixel_lgain = sensorSet(lpixel_lgain,'analog gain', analog_gain(2));

spixel_hgain = sensorSet(spixel_hgain,'analog gain', analog_gain(3));

spixel_lgain = sensorSet(spixel_lgain,'analog gain', analog_gain(4));

noiseFlag = 2;
%
lpixel_hgain = sensorSet(lpixel_hgain,'noise flag', noiseFlag);
% 
lpixel_lgain = sensorSet(lpixel_lgain,'noise flag', noiseFlag);
% 
spixel_hgain = sensorSet(spixel_hgain,'noise flag', noiseFlag);
% 
spixel_lgain = sensorSet(spixel_lgain,'noise flag', noiseFlag);

%
sen_lpixel_hgain = sensorCompute(lpixel_hgain,oi);

sen_lpixel_lgain = sensorCompute(lpixel_lgain,oi);

sen_spixel_hgain = sensorCompute(spixel_hgain,oi);

sen_spixel_lgain = sensorCompute(spixel_lgain,oi);

%

%
sSize = sensorGet(sen_spixel_lgain, 'size');
[X,  Y]  = meshgrid(1:sSize(2), 1:sSize(1));
[Xq, Yq] = meshgrid(1:3:sSize(2), 1:3:sSize(1));

sub_volts_1 = interp2(X,Y, mean(sen_spixel_hgain.data.volts,3), Xq, Yq,"linear");
sub_dvs_1   = interp2(X,Y, mean(sen_spixel_hgain.data.dv,3), Xq, Yq,"linear");

sen_spixel_hgain = sensorSet(sen_spixel_hgain, 'volts', sub_volts_1);
sen_spixel_hgain = sensorSet(sen_spixel_hgain, 'dv', sub_dvs_1);

sub_volts_2 = interp2(X,Y, mean(sen_spixel_lgain.data.volts,3), Xq, Yq,"linear");
sub_dvs_2   = interp2(X,Y, mean(sen_spixel_lgain.data.dv,3), Xq, Yq,"linear");

sen_spixel_lgain = sensorSet(sen_spixel_lgain, 'volts', sub_volts_2);
sen_spixel_lgain = sensorSet(sen_spixel_lgain, 'dv', sub_dvs_2);
%
combined_sensor = sub_volts_2*3^2/(analog_gain(1)) + ... 
sub_volts_1*3^2/(analog_gain(1)/analog_gain(3)) + ...
    sen_lpixel_hgain.data.volts/(analog_gain(1)/analog_gain(2)) + ...
sen_lpixel_hgain.data.volts;

combined_input = 2^24*combined_sensor/max(combined_sensor(:));

rgb_comb = demosaic(uint32(combined_input),'rggb');
% rgb_comb = double(rgb_comb)/max2(double(rgb_comb(:)));

%}

lrgb = iaSensorIMX490Compute(oi,'pixelsize',oiDelta, 'etime',1/4000); % normalized
figure;
subplot(3,1,1);imagesc(lrgb(:,:,1)); clim([2^0 2^8]);
subplot(3,1,2);imagesc(lrgb(:,:,1)); clim([2^8 2^16]);
subplot(3,1,3);imagesc(lrgb(:,:,1)); clim([2^16 2^24]);

[hdr_rendered] = hdrRender(double(lrgb),'haar',0.5,1,1,1);
figure;imshow(hdr_rendered);
%%
%{
% ISP
ip = ipCreate;

ip = ipSet(ip,'conversion method sensor','MCC Optimized');
ip = ipSet(ip,'illuminant correction method','gray world');

ip = ipSet(ip,'demosaic method','Adaptive Laplacian'); 

ip_lphg = ipCompute(ip, sen_lpixel_hgain); rgb_lphg = ipGet(ip_lphg,'data display'); 

ip_lplg = ipCompute(ip, sen_lpixel_lgain); rgb_lplg = ipGet(ip_lplg,'data display'); 

ip_sphg = ipCompute(ip, sen_spixel_hgain); rgb_sphg = ipGet(ip_sphg,'data display'); 

ip_splg = ipCompute(ip, sen_spixel_lgain); rgb_splg = ipGet(ip_splg,'data display');
input       = ipGet(ip_splg,'input');
%
figure;
subplot(2,2,1);imshow(rgb_lphg);title('large pixel high gain');
subplot(2,2,2);imshow(rgb_lplg);title('large pixel low gain');
subplot(2,2,3);imshow(rgb_sphg);title('small pixel high gain');
subplot(2,2,4);imshow(rgb_splg);title('small pixel low gain');


% map the image into a very high dynamic range scene

combined_input = rgb_splg*3^2/(analog_gain(1)) + rgb_sphg*3^2/(analog_gain(1)/analog_gain(3)) + ...
    rgb_lplg/(analog_gain(1)/analog_gain(2)) +  rgb_lphg;

[hdr_rendered] = hdrRender(combined_input,'haar',0.5,1,1,1);

figure;imshow(hdr_rendered);

% compare capture scene luminance and original scene luminance.
rchannel = combined_input(:,:,1);
rchannel = rchannel/max2(rchannel);

figure;plot(1:512,rchannel(257,:),"LineWidth",1.5,"Color","r"); hold on

lum = imresize(lum,[512, 512],'Antialiasing',false);
lum_norm = lum/max2(lum);
plot(1:512,lum_norm(257,:),"LineWidth",1.5,"Color","g");

illum = oiGet(oi,'illuminance');
illum = imresize(illum,[512, 512],'Antialiasing',false);
illum_norm = illum/max2(illum);
plot(1:512,illum_norm(257,:),"LineWidth",1.5,"Color","b");
legend('IP image','Scene','Optical image');
%}
%%




