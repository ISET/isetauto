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

data = [0.59 0.54 0.65;
        0.54 0.25 0.48]';

ref = 0.61;
    
legendEntries = {'optimal',...
                 'sRGB transfer',...
                 'sRGB'};

figure;
hold on; grid on; box on;
bar(data);
plot(-10:10,ref*ones(21,1),'--r','LineWidth',lw);
set(gca,'FontName','Arial');
set(gca,'FontSize',fs-2);
ylim([0 1]);
xlim([0.5 3.5]);
lg = legend(legendEntries,'FontSize',fs-2,'orientation','horizontal');
set(lg,'Position',[0.43 0.80 0.1448 0.0817]);
ylabel('mAP @ IOU 0.5','FontSize',fs);
set(gca,'XTick',1:3);
set(gca,'XTickLabel',{'irradiance','RAW','linear'});
xlabel('Data representation','FontSize',fs);
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',pos);

fName = fullfile(destPath,'representation_SSD.png');
print('-dpng',fName);

%% RFCN

data = [0.78 0.71 0.75;
        0.74 0.55 0.71]';

ref = 0.76;
    
legendEntries = {'optimal',...
                 'sRGB transfer',...
                 'sRGB'};

figure;
hold on; grid on; box on;
bar(data);
plot(-10:10,ref*ones(21,1),'--r','LineWidth',lw);
set(gca,'FontName','Arial');
set(gca,'FontSize',fs-2);
ylim([0 1]);
xlim([0.5 3.5]);
lg = legend(legendEntries,'FontSize',fs-2,'orientation','horizontal');
set(lg,'Position',[0.43 0.80 0.1448 0.0817]);
ylabel('mAP @ IOU 0.5','FontSize',fs);
set(gca,'XTick',1:3);
set(gca,'XTickLabel',{'irradiance','RAW','linear'});
xlabel('Data representation','FontSize',fs);
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',pos);

fName = fullfile(destPath,'representation_RFCN.png');
print('-dpng',fName);
