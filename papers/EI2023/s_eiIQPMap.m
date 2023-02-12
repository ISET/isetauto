% plot Image Quality Performance Contours

%% The average precision

% Day AP
ap_day = [0.889	0.873	0.876	0.87	0.891	0.87	0.859	0.861	0.847	0.849	0.842	0.839	0.799
0.882	0.883	0.86	0.876	0.874	0.832	0.855	0.842	0.851	0.788	0.801	0.78	0.747
0.814	0.805	0.778	0.784	0.792	0.714	0.724	0.739	0.742	0.601	0.67	0.671	0.637
0.735	0.727	0.686	0.719	0.681	0.522	0.532	0.62	0.656	0.407	0.511	0.471	0.42
0.543	0.571	0.362	0.429	0.439	0.221	0.235	0.313	0.394	0.0997	0.191	0.263	0.225
0.448	0.532	0.277	0.31	0.357	0.219	0.17	0.188	0.29	0.0718	0.108	0.182	0.189];

% Night AP
ap_night = [0.57	0.586	0.522	0.55	0.561	0.496	0.488	0.493	0.518	0.426	0.425	0.462	0.458
0.456	0.469	0.418	0.43	0.408	0.356	0.363	0.332	0.361	0.268	0.284	0.289	0.285
0.395	0.398	0.319	0.336	0.344	0.246	0.264	0.275	0.294	0.176	0.209	0.213	0.225
0.33	0.357	0.276	0.302	0.304	0.186	0.189	0.243	0.245	0.127	0.157	0.176	0.146
0.192	0.212	0.108	0.124	0.142	0.041	0.0589	0.0751	0.0994	0.0148	0.0228	0.0278	0.0339
0.0936	0.14	0.0339	0.0516	0.0721	0.016	0.0182	0.0179	0.1	0.0089	0.0142	0.0279	0.0092];

% All the cameras have one of these four MTF50s
mtf50    = [150 100 75 55];

% The scene collection has these six distances
distance = [25 50 75 100 150 200];

% The mesh grid of possible MTF50 and distance values
[X,Y] = meshgrid(mtf50, distance);

cLevels = 0:0.1:1.0;

fontName = 'Arial';

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
clabel(M,c,'FontSize',18);   % Fonts on the contour
set(gca,'FontSize',20);      % Fonts on the axis
fontname(gcf,fontName);
clim([0 1]); colorbar;
colormap(gray.^0.5);   % Don't let the shading get too black.

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
clabel(M,c,'FontSize',18);

set(gca,'FontSize',20);
fontname(gcf,fontName);
clim([0 1]);
colorbar;
colormap(gray.^0.5);

%% Average precision for night time

ap_avg(:,1) = mean(ap_night(:,1:2),2);
ap_avg(:,2) = mean(ap_night(:,3:5),2);
ap_avg(:,3) = mean(ap_night(:,6:9),2);
ap_avg(:,4) = mean(ap_night(:,10:13),2);

[X,Y] = meshgrid(mtf50, distance);

ieNewGraphWin;
[M,c] = contourf(Y, X, ap_avg, cLevels, 'LineWidth',1.5); hold on
clabel(M,c,'FontSize',18,'Color','White');

set(gca,'FontSize',20);
fontname(gcf,fontName);
clim([0 1]);
colorbar;
colormap(gray.^0.5);

%%