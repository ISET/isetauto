close all;
clear all;
clc;

fs = 8;
lw = 1;
ms = 10;
pos = [1 1 5 7];

destPath = fullfile('~','Desktop','Figures','ML');
if ~exist(destPath,'dir');
    mkdir(destPath);
end

%% SSD

ev = -4:4;
data = [0.263 0.417 0.519 0.576 0.614 0.585 0.417 0.203 0.117];          
mix = [0.367 0.426 0.448 0.449 0.458 0.460 0.424 0.343 0.223];
bound = [0.549 0.617 0.628 0.614 0.614 0.567 0.473 0.359 0.166];



figure;
box on;

fill([ev fliplr(ev)],[bound ones(1,9)],[0.9 0.9 0.9],'EdgeColor','none');
grid on; hold on;

plot(ev,data,'marker','.','lineWidth',lw,'color','black','markerSize',ms);
plot(ev,mix,'--','marker','.','lineWidth',lw,'color','black','markerSize',ms);

set(gca,'FontName','Helvetica');
set(gca,'FontSize',fs-2);
ylim([0 1]);
ylabel('mAP @ IoU 0.5','FontSize',fs);
xlabel('Exposure bias, EV','FontSize',fs);

set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',pos);

fName = fullfile(destPath,'exposure-SSD.eps');
print('-depsc',fName);

%% RFCN

data = [0.59 0.70 0.75 0.76 0.77 0.73 0.60 0.40 0.22];
bound = [0.75 0.76 0.76 0.78 0.77 0.75 0.72 0.64 0.56];
mix = [0.67 0.70 0.71 0.71 0.70 0.69 0.64 0.58 0.44];    


figure;
box on;
fill([ev fliplr(ev)],[bound ones(1,9)],[0.9 0.9 0.9],'EdgeColor','none');
grid on; hold on;

plot(ev,data,'marker','.','lineWidth',lw,'color','black','markerSize',ms);
plot(ev,mix,'--','marker','.','lineWidth',lw,'color','black','markerSize',ms);
    
    
set(gca,'FontName','Helvetica');
set(gca,'FontSize',fs-2);
ylim([0 1]);
ylabel('mAP @ IoU 0.5','FontSize',fs);
xlabel('Exposure bias, EV','FontSize',fs);

set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',pos);

fName = fullfile(destPath,'exposure-RFCN.eps');
print('-depsc',fName);


