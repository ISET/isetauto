%% Relate the fnumber/MTF issues to system performance
%
% Illustrate the MTF through the diffraction-limited lens and a sensor with
% different pixel sizes.  Then use these same sensors and lenses with the
% metric scenes.  
%
% This issue relates to the use of the MTF for autonomous driving.
% Remember the abstract that includes Alexander Braun and the work of the
% automobile committee.
%
% See also
%

%% The test scene

% Set a realistic light level
scene = sceneCreate('slanted edge',512);
scene = sceneSet(scene,'fov',1);
scene = sceneSet(scene,'mean luminance',10);
sceneWindow(scene);

%% Choose three different fnumbers?

oi = oiCreate('diffraction limited');
fnumber = 5.6;
oi = oiSet(oi,'fnumber',fnumber);
oi = oiCompute(oi,scene);
oi = oiSet(oi,'name',sprintf('%02.2f',fnumber));
oiWindow(oi);

oiPlot(oi,'psf 550');

% Spread in meters
psf =oiGet(oi,'optics psf data',550,'m');
mesh(psf.xy(:,:,1),psf.xy(:,:,2),psf.psf);

% Units are cycles per the size of the image, which is about 10 microns
otf = psf2otf(psf.psf);
ieNewGraphWin; mesh(fftshift(otf));

%%  Choose two different pixel sizes

sensor = sensorCreate;
pSize = 1.4*1e-6;
sensor = sensorSet(sensor,'pixel size constant fill factor',pSize);
sensor = sensorSet(sensor,'fov',1,oi);

% Realistic exposure duration
sensor = sensorSet(sensor,'exposure duration',16*1e-3);
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

%% Check ip properties

ip = ipCreate;
ip = ipCompute(ip,sensor);
ipWindow(ip);

%%