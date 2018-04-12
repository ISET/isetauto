close all;
clear all;
clc;

fs = 8;
lw = 1;
ms = 2;
pos = [1 1 10 4];
cmap = jet(4);
cmap = cmap([1 2 4],:);
markers = {'-x','-o','-d','-*'};

destPath = fullfile('~','Desktop','Figures','ML');
if ~exist(destPath,'dir');
    mkdir(destPath);
end

%% SSD

data = [0.263 0.417 0.519 0.576 0.614 0.585 0.417 0.203 0.117;
        0.549 0.617 0.628 0.614 0.614 0.567 0.473 0.359 0.166];          
    
legendEntries = {'0EV',...
                 'xEV'};

figure;
hold on; grid on; box on;
for i=1:size(data,1)
    plot(-4:4,data(i,:),markers{i},'lineWidth',lw,'color',cmap(i,:),'markerSize',ms);
end
set(gca,'FontName','Arial');
set(gca,'FontSize',fs-2);
ylim([0 1]);
lg = legend(legendEntries,'FontSize',fs-2,'orientation','horizontal');
set(lg,'Position',[0.40 0.23 0.1448 0.0817]);
ylabel('mAP @ IOU 0.5','FontSize',fs);
xlabel('Exposure bias, EV','FontSize',fs);

set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',pos);

fName = fullfile(destPath,'exposure-SSD.png');
print('-dpng',fName);

%% RFCN

data = [0.59 0.70 0.75 0.76 0.77 0.73 0.60 0.40 0.22;
        0.75 0.76 0.76 0.78 0.77 0.75 0.72 0.64 0.56];
    
legendEntries = {'0EV',...
                 'xEV'};

figure;
hold on; grid on; box on;
for i=1:size(data,1)
    plot(-4:4,data(i,:),markers{i},'lineWidth',lw,'color',cmap(i,:),'markerSize',ms);
end
set(gca,'FontName','Arial');
set(gca,'FontSize',fs-2);
ylim([0 1]);
lg = legend(legendEntries,'FontSize',fs-2,'orientation','horizontal','FontName','Arial');
set(lg,'Position',[0.40 0.23 0.1448 0.0817]);
ylabel('mAP @ IOU 0.5','FontSize',fs);
xlabel('Exposure bias, EV','FontSize',fs);

set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',pos);

fName = fullfile(destPath,'exposure-RFCN.png');
print('-dpng',fName);


