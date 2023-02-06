%% Night HDR estimates from Google Pixel 4
%
% Reading the DNG files
e
%% Base directory with example DNG files
baseDir = fullfile(iaRootPath,'local','nightimages');
chdir(baseDir);

% They come in groups of three
fnames = dir('*.dng');

% 
tmp = imread(fnames(1).name); imagesc(tmp);

start = 3;  % Which group
for ii=1:3
    sensor = sensorDNGRead(fnames((start-1)*3 + ii).name);
    sensorWindow(sensor);
end
