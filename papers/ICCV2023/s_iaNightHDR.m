%% Night HDR estimates from Google Pixel 4
%
% Reading the DNG files


%%
ieInit;

%% Base directory with example DNG files
baseDir = fullfile(iaRootPath,'local');
chdir(baseDir);


%% Experiments

chdir('campusMaybe')
fname = 'IMG_20221113_183244';
for ii=0:2
    sensor = sensorDNGRead(sprintf('%s_%01d.dng',fname,ii));
    sensorWindow(sensor);
end

[roiLocs] = ieROISelect(sensor);

sensor = ieGetObject('sensor');
sensor = sensorSet(sensor,'roi',roiLocs);
dv = sensorGet(sensor,'roi dv');
dv = dv - 64;

mean(dv,'omitnan')/sensorGet(sensor,'exptime','s')

%% License plate and downtownPA1
chdir(baseDir);
chdir('downtownPA1')
fname = 'IMG_20221113_183348';

for ii=0:2
    sensor = sensorDNGRead(sprintf('%s_%01d.dng',fname,ii));
    sensorWindow(sensor);
end

% Get an ROI from one of the sensor images
[roiLocs] = ieROISelect(sensor);

% Make sure you get the sensor data and set the roiLocs in the sensor
sensor = ieGetObject('sensor');
sensor = sensorSet(sensor,'roi',roiLocs);

% Get the digital values and remove the base 64
dv = sensorGet(sensor,'roi dv');
dv = dv - 64;

% DV per second
mean(dv,'omitnan')/sensorGet(sensor,'exptime','s')

% How to show the ROI on the sensor image
roiRect = ieLocs2Rect(roiLocs);
ieROIDraw('sensor','shape','rect','shape data',roiRect,'line width',2);
%% 
chdir(baseDir);
chdir('downtownPA2');

fname = 'IMG_20221113_183435';

for ii=0:2
    sensor = sensorDNGRead(sprintf('%s_%01d.dng',fname,ii));
    sensorWindow(sensor);
end

% Get an ROI from one of the sensor images
[roiLocs] = ieROISelect(sensor);

% Make sure you get the sensor data and set the roiLocs in the sensor
sensor = ieGetObject('sensor');
sensor = sensorSet(sensor,'roi',roiLocs);

% Get the digital values and remove the base 64
dv = sensorGet(sensor,'roi dv');
dv = dv - 64;
% DV per second
mean(dv,'omitnan')/sensorGet(sensor,'exptime','s')

% How to show the ROI on the sensor image
roiRect = ieLocs2Rect(roiLocs);
ieROIDraw('sensor','shape','rect','shape data',roiRect,'line width',2);
%% 

sensor = ieGetObject('sensor');

[roiLocs,cropRect] = ieROISelect(sensor);
sensor = sensorCrop(sensor,cropRect);
sensorWindow(sensor);

%%
% They come in groups of three
fnames = dir('*.dng');

% 
tmp = imread(fnames(1).name); imagesc(tmp);

start = 3;  % Which group
for ii=1:3
    sensor = sensorDNGRead(fnames((start-1)*3 + ii).name);
    sensorWindow(sensor);
end
