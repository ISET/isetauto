%% s_iaNightScenes
%
% 
%
% Examine some of the night time scenes acquired with bracketed exposure on
% the Google Pixel 4a
%
%{
chdir('/Volumes/Wandell/nightscenes/20221106')
%}


%% Camera was using speed of 437 for some reason
% Maybe we should set the speed to 55, which is unity gain.

fname = 'IMG_20221106_180748';
fname = [fname,'_4.dng'];

exist(fname,'file')

[sensor,info] = sensorDNGRead(fname);
sensorWindow(sensor);

fname = 'IMG_20221106_180748';
fname = [fname,'_0.dng'];
[sensor,info] = sensorDNGRead(fname);
sensorWindow(sensor);
