%% Script to illustrate city with different sensors
%
%
% ZL/BW SCIEN

%% Read in the oi from somehwere
% In this example I just ran
%
%{
s_piReadRenderLens
%}
% which produced a crummy oi.

%% Create a monochrome sensor

sensor = sensorCreate('monochrome');

% Set its field of view to match the OI field of view.
% This changes the number of rows and columns.
sensor = sensorSetSizeToFOV(sensor,oiGet(oi,'fov'));
sensor = sensorSet(sensor,'exposure duration',0.002);  % 2 ms exposure

sensor = sensorCompute(sensor,oi);

ieAddObject(sensor);
sensorWindow;

% This sets it up to display reasonably for the high dynamic range.
sensor = sensorSet(sensor,'gamma',0.7);

%% An RCCC camera design - to be fixed up by BW

foo = load('MT9V024_Mono');

%% Change the pixel size like this

sensor = sensorCompute(sensor,oi);