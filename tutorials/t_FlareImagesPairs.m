% Illuminance consistency for Flare simulation using piFlareApply
ieInit;clear all
sceneDir = '/acorn/data/iset/isetauto/Ford/Flare_paper/SceneMats_002/1112153803.mat';
load(sceneDir,'scene');
fnumber =1.7;
focalLength = 4.38e-3;
psfsamplespacing = 0.7e-6;
%% flare case
[oi_flare,pupilmask, psf] = piFlareApply(scene,...
                    'psf sample spacing', psfsamplespacing, ...
                    'numsidesaperture', 10, ...
                    'fnumber',1.7,'focal length',4.38e-3,...
                    'dirtylevel',0.5);

ip_flare = piRadiance2RGB(oi_flare,'etime',1/2.5);
ipWindow(ip_flare);
meanilluminance_flare = oiGet(oi_flare, 'mean illuminance');
fprintf('Mean Illum of Flare OI is %f lux.\n',meanilluminance_flare);
%% flare free

[sceneHeight, sceneWidth, ~] = size(scene.data.photons);
oi = oi_flare;
oi = oiSet(oi,'photons',oiCalculateIrradiance(scene,oi_flare));

% Apply some of the oi methods to the initialized oi data
offaxismethod = opticsGet(oi.optics,'off axis method');
switch lower(offaxismethod)
    case {'skip','none',''}
    case 'cos4th'
        oi = opticsCos4th(oi);
    otherwise
        fprintf('\n-----\nUnknown offaxis method: %s.\nUsing cos4th.',optics.offaxis);
        oi = opticsCos4th(oi);
end

% Pad the optical image to allow for light spread (code from isetcam)
padSize  = round([sceneHeight sceneWidth]/8);
padSize(3) = 0;
sDist = sceneGet(scene,'distance');
oi = oiPad(oi,padSize,sDist);

oiSize = oiGet(oi,'size');
oiHeight = oiSize(1); oiWidth = oiSize(2);

oi = oiSet(oi, 'wAngular', 2*atand((oiWidth*psfsamplespacing/2)/focalLength));
% crop oi to remove extra edge
oi = oiCrop(oi, [(oiSize(2)-sceneWidth)/2,(oiSize(1)-sceneHeight)/2, ...
    sceneWidth-1, sceneHeight-1]);

% Compute illuminance, though not really necessary
oi = oiSet(oi,'illuminance',oiCalculateIlluminance(oi));
ip = piRadiance2RGB(oi,'etime',1/2.5);
ipWindow(ip);

meanilluminance_flareFree = oiGet(oi, 'mean illuminance');
fprintf('Mean Illum of Flare Free OI is %f lux.\n',meanilluminance_flareFree);






