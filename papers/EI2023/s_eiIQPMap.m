% plot System Performance Maps
%
% This script should be
%
%   s_eiSPM.m
%

%%
ieInit;

%% The average precision

load('eiAPData','ap_day','ap_night','mtf50','distance');

% The mesh grid of possible MTF50 and distance values
[X,Y] = meshgrid(mtf50, distance);

cLevels = 0:0.1:1.0;
cFontSize = 20;

fontName = 'Georgia';
fontSize = 24;

%% Make the contour map that illustrates the idea
% This is the only one that uses the symbols

% These are the four example cameras we use to illustrate
ap_use(:,1) = ap_day(:,2);
ap_use(:,2) = ap_day(:,5);
ap_use(:,3) = ap_day(:,9);
ap_use(:,4) = ap_day(:,13);

% Make the contour plot
ieNewGraphWin;
[M,c] = contourf(Y, X, ap_use, cLevels,'LineWidth',1.5); 
clabel(M,c,'FontSize',cFontSize);   % Fonts on the contour
set(gca,'FontSize',fontSize);      % Fonts on the axis
fontname(gcf,fontName);
clim([0 1]); colorbar;
colormap(gray.^0.5);   % Don't let the shading get too black.
set(gca,'ylim',[55 150],'YTick',75:25:150);

% Add symbols to contour plot identifying the AP values by MTF
hold on;
sym = {'hexagram','^','square','o'};
symColors = [...
    1 0 0;
    1.0 0.8 0;
    0.6 0 0.6;
    0.2 0.2 0.8;];
symSize = 400;
lWidth = 1.5;
for ii = 1:4
    for dd = 1:6
        scatter(distance(dd), mtf50(ii),symSize,symColors(ii,:),sym{ii},'filled','LineWidth',lWidth);
        hold on;
    end
end

%% Make the contour map data for day

% Average the different AP examples together
ap_avg(:,1) = mean(ap_day(:,1:2),2);
ap_avg(:,2) = mean(ap_day(:,3:5),2);
ap_avg(:,3) = mean(ap_day(:,6:9),2);
ap_avg(:,4) = mean(ap_day(:,10:13),2);

ieNewGraphWin;
[M,c] = contourf(Y, X, ap_avg, cLevels,'LineWidth',1.5); 
clabel(M,c,'FontSize',cFontSize);   % Fonts on the contour
set(gca,'FontSize',fontSize);      % Fonts on the axis
clim([0 1]);
colorbar;
colormap(gray.^0.5);
set(gca,'ylim',[55 150],'YTick',[75:25:150]);

%% Average precision for night time

ap_avg(:,1) = mean(ap_night(:,1:2),2);
ap_avg(:,2) = mean(ap_night(:,3:5),2);
ap_avg(:,3) = mean(ap_night(:,6:9),2);
ap_avg(:,4) = mean(ap_night(:,10:13),2);

[X,Y] = meshgrid(mtf50, distance);

ieNewGraphWin;
[M,c] = contourf(Y, X, ap_avg, cLevels, 'LineWidth',1.5); hold on
clabel(M,c,'FontSize',cFontSize,'Color','White');   % Fonts on the contour
set(gca,'FontSize',fontSize);      % Fonts on the axis
clim([0 1]);
colorbar;
colormap(gray.^0.5);
set(gca,'ylim',[55 150],'YTick',[75:25:150]);

%%