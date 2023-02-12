%% plot the AP data for the different cameras
%
% Plots are made for both the day and night simulations
% There are thirteen different cameras
%
%%
ieInit;

load('eiAPData','ap_day','ap_night','mtf50','distance');
%%
symColors = [...
    0.2 0.2 0.8; % dark blue
    0 0.6 0.8;   % cyan
    0.6 0 0.6;   % purple
    1.0 0.8 0;   % orange
    0.6 0 0.6;   % purple
    1.0 0.8 0;   % orange
    1 0 0;       % red
    0 0.8 0;     % green
    1.0 0.8 0;   % orange
    1 0 0    ;   % red
    0 0.8 0 ;    % green
    1 0 0 ;      % red
    0 0.8 0;     % green
    ];
sym = {'o','o','o','o','square','square','square','square','^','^','^','hexagram','hexagram'};
lWidth = 1.5;
symSize = 200;
fontName = 'Georgia';

camera.pSize = [4.2 3.5 2.8 2.1 2.8 2.1 1.4 1.0 2.1 1.4 1.0 1.4 1.0];
camera.fnum =  [3.1 6.4 9.1 10.9 3.8 6.4 3.3 8.9 2.7 5.4 5.1 1.9 3.3];

%% Day
ieNewGraphWin;
for ii = 1:13
    plot(distance, ap_day(:,14-ii),'-','LineWidth',lWidth,'LineStyle','-','Color',[0.5 0.5 0.5]);  % Lines
    hold on
    scatter(distance, ap_day(:,14-ii),symSize,symColors(ii,:),sym{ii},'filled','LineWidth',lWidth);
    hold on;
end
set(gca,'fontsize', 28);
set(gca,'fontname',fontName);
grid on
set(gca,'ylim',[0 1]);


%% Day
ieNewGraphWin;
symSize = 400;
for ii = [12 9 5 1]
    plot(distance, ap_day(:,14-ii),'-','LineWidth',lWidth,'LineStyle','-','Color',[0.5 0.5 0.5]);  % Lines
    hold on
    scatter(distance, ap_day(:,14-ii),symSize,symColors(ii,:),sym{ii},'filled','LineWidth',lWidth);
    hold on;
end
set(gca,'fontsize', 28); 
set(gca,'fontname',fontName);

grid on
set(gca,'ylim',[0 1]);

%% Night
ieNewGraphWin;
for ii = 13:-1:1
    plot(distance, ap_night(:,ii),'-','LineWidth',lWidth,'LineStyle','-','Color',[0.5 0.5 0.5]);  % Lines
    hold on
    scatter(distance, ap_night(:,ii),symSize,symColors(ii,:),sym{ii},'LineWidth',lWidth);
    hold on;
end
set(gca,'fontsize', 28); 
set(gca,'fontname',fontName);
grid on
set(gca,'ylim',[0 1]);


saveas(gcf,'nightAP','png');

%%
