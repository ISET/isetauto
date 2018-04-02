%% Script to illustrate city with different sensors
%
%  At this point we have a default, foggy car scene.  But we will update
%  that with another OI.
%
%  The current sensors are the 6 micron MT9V024 line.
%
%  We have part of the AR0132 line implemented and we could do more on that.
%  That is a 3.75 micron pixel
%
% Copyright ZL/BW SCIEN Stanford, April, 1, 2018

%% Read in the oi from somehwere

% If you don't have the AWS access below, you can create an OI this way
%{
 scene = sceneCreate('sweep frequency');
 scene = sceneSet(scene,'fov',30);
 oi = oiCreate;
 oi = oiCompute(oi,scene);
%}

%%
ieInit

%% Download the car in fog example sensor irradiance
rdt = RdtClient('isetbio');
rdt.crp('/resources/oi');
oiCarFog = rdt.readArtifact('oiCarFog','type','mat');
oi = oiCarFog.oi;
ieAddObject(oi); oiWindow;

%% Calculate a sensor response

% This is the ON RGB sensor
load('MT9V024SensorRGB','sensor');
oi = oiSet(oi,'fov',40);
sensor = sensorSetSizeToFOV(sensor,oiGet(oi,'fov'));
sensor = sensorCompute(sensor,oi);

ieAddObject(sensor); sensorWindow; truesize

%% Load a monochrome sensor

load('MT9V024SensorMono','sensor');

% Set its field of view to match the OI field of view.
% This changes the number of rows and columns.
sensor = sensorSetSizeToFOV(sensor,oiGet(oi,'fov'));
sensor = sensorSet(sensor,'auto exposure',true);  % 2 ms exposure
sensor = sensorCompute(sensor,oi);

ieAddObject(sensor); sensorWindow;

% This sets it up to display reasonably for the high dynamic range.
sensor = sensorSet(sensor,'gamma',0.7);

%% An RCCC camera design - to be fixed up by BW

load('MT9V024SensorRCCC','sensor');

sensor = sensorSetSizeToFOV(sensor,oiGet(oi,'fov'));
sensor = sensorSet(sensor,'auto exposure',true);  % 2 ms exposure
sensor = sensorCompute(sensor,oi);

ieAddObject(sensor); sensorWindow;

% This sets it up to display reasonably for the high dynamic range.
sensor = sensorSet(sensor,'gamma',0.7);

%%