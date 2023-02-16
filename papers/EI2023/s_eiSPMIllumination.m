%% plot the AP data for different illumination levels
%
% Not sure which camera.  Should put it here.
%
%%
ieInit;

load('eiAPData','ap_illumination','illuminance','distance');

% The mesh grid of possible MTF50 and distance values
[X,Y] = meshgrid(log10(illuminance), distance);

cLevels = 0:0.1:1.0;
cFontSize = 20;

fontName = 'Georgia';
fontSize = 24;

%%

ieNewGraphWin;
[M,c] = contourf(Y, X, ap_illumination, cLevels,'LineWidth',1.5); 
clabel(M,c,'FontSize',cFontSize);   % Fonts on the contour
set(gca,'FontSize',fontSize);      % Fonts on the axis
clim([0 1]);
colorbar;
foo = gray*0.7 + ones(size(gray))*0.3;
colormap(foo);
set(gca,'ytick',[0 1 2],'YTickLabel',{'1','10','100'});

%%