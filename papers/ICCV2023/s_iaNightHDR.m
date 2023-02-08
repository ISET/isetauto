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
