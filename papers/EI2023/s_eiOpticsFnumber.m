%% s_eiOptics
%
% This produces the purely optical PSF, LSF and MTF for 1 and 2 dimensional
% cases. 
%
% We compute again after imaging the slanted edge on a sensor with
% various pixel sizes in the parallel script s_eiSensorFnumber.
%
ieInit

%% Choose three different fnumbers?

oi = oiCreate('diffraction limited');
fnumber = 5;
oi = oiSet(oi,'fnumber',fnumber);
% oi = oiCompute(oi,scene);
% oi = oiSet(oi,'name',sprintf('%02.2f',fnumber));
% oiWindow(oi);

% oiPlot(oi,'psf 550');

%% Spread in millimeters
unit = 'um';
psf = oiGet(oi,'optics psf data',550,unit);
ieNewGraphWin; mesh(psf.xy(:,:,1),psf.xy(:,:,2),psf.psf);

dx = psf.xy(1,end,1) - psf.xy(1,1,1);   % Distance in millimeters
dy = psf.xy(end,1,2) - psf.xy(1,1,2);   % Distance in millimeters
[r,c] = size(psf.psf);
[v,idx] = max(psf.psf(:));
[rCenter,cCenter] = ind2sub([r,c],idx);
[X,Y] = meshgrid(1:c,1:r);

Xs = (X - cCenter)*dx;
Ys = (Y - rCenter)*dy;
ieNewGraphWin; mesh(Xs,Ys,psf.psf);
set(gca,'xlim',[-200 200],'ylim',[-200 200]);

xlabel(sprintf('position (%s)',unit));
ylabel(sprintf('position (%s)',unit));
zlabel('Relative intensity')

%% Units are cycles per the size of the image, which is about 10 microns
otf = fftshift(psf2otf(psf.psf));

% 1 is one cycle per the width of the support, dx.
% To convert that into cycles per unit, 
% we multiply by dx
Xf = (X - cCenter)/dx;
Yf = (Y - rCenter)/dy;
ieNewGraphWin; mesh(Xf,Yf,otf);

set(gca,'xlim',[-3 3],'ylim',[-3 3]);

xlabel(sprintf('cycles/%s',unit));
ylabel(sprintf('cycles/%s',unit));
zlabel('SFR')

%% Now the psf to an lsf

lsf = PsfToLsf(psf.psf);   % PTB method, uses convolution with a line
space = ((1:r) - r/2)*dx;
ieNewGraphWin; plot(space,lsf);
grid on;

%{
% PTB code with convolution produces the same result as
tmp = sum(psf.psf,2);
tmp = ieScale(tmp,1);
ieNewGraphWin;
plot(tmp(:),lsf(:),'.');
identityLine;
%}

%%
mtf = fftshift(abs(fft(lsf)));
ieNewGraphWin;
xf = Xf(1,:,1);
plot(xf,mtf);
xlabel(sprintf('Spatial frequency (cycles/%s)',unit));
ylabel('SFR');


%%



%%
