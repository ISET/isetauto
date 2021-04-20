close all;
clear all;
clc;

fs = 8;
lw = 1;
ms = 2;
pos = [1 1 10 5];
cmap = jet(2);

destPath = fullfile('~','Desktop','Figures','ML');
if ~exist(destPath,'dir');
    mkdir(destPath);
end

%% SSD-MobileNet

data = [0.54 0.65 0.61];
  

figure;
hold on; grid on; box on;
br = bar(data,'facecolor','black','barwidth',0.5);
set(gca,'FontName','Helvetica');
set(gca,'FontSize',fs-2);
ylim([0 1]);
xlim([0.5 3.5]);
ylabel('mAP @ IOU 0.5','FontSize',fs);
set(gca,'XTick',1:3);
set(gca,'XTickLabel',{'raw','linear','sRGB'});
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',pos);

fName = fullfile(destPath,'representation_SSD.eps');
print('-depsc',fName);

%% RFCN

data = [0.71 0.75 0.76]';


figure;
hold on; grid on; box on;
br = bar(data,'facecolor','black','barwidth',0.5);
set(gca,'FontName','Helvetica');
set(gca,'FontSize',fs-2);
ylim([0 1]);
xlim([0.5 3.5]);
ylabel('mAP @ IOU 0.5','FontSize',fs);
set(gca,'XTick',1:3);
set(gca,'XTickLabel',{'raw','linear','sRGB'});
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',pos);

fName = fullfile(destPath,'representation_RFCN.eps');
print('-depsc',fName);
