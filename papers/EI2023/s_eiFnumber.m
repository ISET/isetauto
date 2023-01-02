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
% oi = oiCompute(oi,scene);
% oi = oiSet(oi,'name',sprintf('%02.2f',fnumber));
% oiWindow(oi);

% oiPlot(oi,'psf 550');

%% Spread in millimeters
unit = 'mm';
psf = oiGet(oi,'optics psf data',550,unit);
mesh(psf.xy(:,:,1),psf.xy(:,:,2),psf.psf);

dx = psf.xy(1,end,1) - psf.xy(1,1,1);   % Distance in millimeters
dy = psf.xy(end,1,2) - psf.xy(1,1,2);   % Distance in millimeters
[r,c] = size(psf.psf);
[v,idx] = max(psf.psf(:));
[rCenter,cCenter] = ind2sub([r,c],idx);
[X,Y] = meshgrid(1:c,1:r);

Xs = (X - cCenter)*dx;
Ys = (Y - rCenter)*dy;
ieNewGraphWin; mesh(Xs,Ys,psf.psf)
xlabel(sprintf('position (%s)',unit));
ylabel(sprintf('position (%s)',unit));

%% Units are cycles per the size of the image, which is about 10 microns
otf = fftshift(psf2otf(psf.psf));

% 1 is one cycle per the width of the support, dx.
% To convert that into cycles per unit, 
% we multiply by dx
Xf = (X - cCenter)/dx;
Yf = (Y - rCenter)/dy;
ieNewGraphWin; mesh(Xf,Yf,otf);
xlabel(sprintf('cycles/%s',unit));
ylabel(sprintf('cycles/%s',unit));


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