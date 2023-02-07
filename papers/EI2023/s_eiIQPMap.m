% plot Image Quality Performance Contour

ap_day = [0.889	0.873	0.876	0.87	0.891	0.87	0.859	0.861	0.847	0.849	0.842	0.839	0.799
0.882	0.883	0.86	0.876	0.874	0.832	0.855	0.842	0.851	0.788	0.801	0.78	0.747
0.814	0.805	0.778	0.784	0.792	0.714	0.724	0.739	0.742	0.601	0.67	0.671	0.637
0.735	0.727	0.686	0.719	0.681	0.522	0.532	0.62	0.656	0.407	0.511	0.471	0.42
0.543	0.571	0.362	0.429	0.439	0.221	0.235	0.313	0.394	0.0997	0.191	0.263	0.225
0.448	0.532	0.277	0.31	0.357	0.219	0.17	0.188	0.29	0.0718	0.108	0.182	0.189];
ap_use(:,1)=ap_day(:,2);
ap_use(:,2)=ap_day(:,5);
ap_use(:,3)=ap_day(:,9);
ap_use(:,4)=ap_day(:,13);

mtf50 = [150 100 75 55];
distance = [25 50 75 100 150 200];

[X,Y] = meshgrid(mtf50, distance);

ieNewGraphWin;
[M,c] = contourf(Y, X, ap_use,'LineWidth',1.5); hold on

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

clabel(M,c,'FontSize',15);
set(gca,'FontSize',20);
fontname(gcf,"Georgia");
clim([0 1]);colorbar;
colormap gray