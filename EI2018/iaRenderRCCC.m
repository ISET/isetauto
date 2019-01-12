%% Test RCCC rendering

scene = sceneCreate('reflectance chart');
scene = sceneSet(scene,'fov',10);
oi = oiCreate; oi = oiCompute(oi,scene);
oiWindow(oi);

%%
load('MT9V024SensorRCCC.mat','sensor');
sensor = sensorSetSizeToFOV(sensor,1.2*sceneGet(scene,'fov'));

%% Adjust the RCCC sensor to 4 channel
%{
filterSpectra = sensorGet(sensor,'filter spectra');
filterSpectra = [filterSpectra, filterSpectra(:,2), filterSpectra(:,2)];

filterNames = sensorGet(sensor,'filter names');
filterNames{3} = filterNames{2};
filterNames{4} = filterNames{2};

sensor = sensorSet(sensor,'filter names',filterNames);
sensor = sensorSet(sensor,'filter spectra',filterSpectra);

sensor = sensorSet(sensor,'cfa pattern',[1 2; 3 4]);
%}

%%
sensor = sensorSet(sensor,'exp time',0.001);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

%% 
ip = ipCreate;
ip = ipSet(ip,'internal colorspace','sensor');
ip = ipSet(ip,'correction method illuminant','none');
ip = ipSet(ip,'conversion method sensor','none');

img = Demosaic(ip,sensor);
vcNewGraphWin;
imagesc(img(:,:,1)); colormap(gray)
imagesc(img(:,:,2)); colormap(gray)

[r,c,w] = size(img);

rcc = zeros(r,c,3);
rcc(:,:,1) = 0.1*img(:,:,2) + 2*img(:,:,1);
rcc(:,:,2) = img(:,:,2);
rcc(:,:,3) = img(:,:,2);
vcNewGraphWin;
imagesc(rcc); 

%%
ip = ipCompute(ip,sensor);
ipWindow(ip);


