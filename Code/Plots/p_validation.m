close all;
clear all;
clc;

fs = 8;
lw = 1;
ms = 2;
pos = [1 1 10 5];
cmap = jet(5);

destPath = fullfile('~','Desktop','Figures','ML');
if ~exist(destPath,'dir');
    mkdir(destPath);
end

data = [0.89 0.88 0.85 0.74 0.64;
        0.26 0.23 0.17 0.13 0.08;
        0.51 0.46 0.43 0.32 0.2];
    
    
xDataLabels = {'PASCAL VOC07','SYNTHIA','Ours'};
legendEntries = {'R-CNN-Inception-Resnet',...
                 'R-CNN-Resnet101',...
                 'RFCN-Resnet101',...
                 'SSD-InceptionV2',...
                 'SSD-Mobilenet'};

figure;
hold on; grid on; box on;
bar(data);
colormap(cmap);
set(gca,'xTick',1:3);
set(gca,'xTickLabel',xDataLabels);
set(gca,'tickLabelInterpreter','LaTeX');
set(gca,'FontSize',fs-2);
ylim([0 1]);
legend(legendEntries,'interpreter','LaTeX','FontSize',fs-2);
ylabel('mAP @ IOU 0.5','interpreter','LaTeX','FontSize',fs);
xlabel('Test data set','interpreter','LaTeX','FontSize',fs);

set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',pos);

fName = fullfile(destPath,'validation.eps');
print('-depsc',fName);
