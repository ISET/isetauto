%% mtf vs od50
mtf = [55 55 55 55 75 75 75 75 100 100 100 150 150];

od50_night = [40.3509   43.3761   30.2885   35.4167   34.9673   24.2857   22.6000   23.9130   27.8662   13.2911   11.7021   19.5087   18.9306];

od50_day = [172.6316  241.0256  128.7037  137.7586  137.3967  103.6545  105.3872  119.5440  129.7710   88.0155  101.7188   96.3750   90.7834];

od = od50_day;
od = flip(od);

ieNewGraphWin;

scatter(mtf(1), od(1), 600, 'o', 'filled','LineWidth',1.5); hold on
scatter(mtf(2), od(2), 600,'o', 'filled','LineWidth',1.5); hold on
scatter(mtf(3), od(3), 600,'o', 'filled','LineWidth',1.5); hold on
scatter(mtf(4), od(4), 600,'o', 'filled','LineWidth',1.5); hold on
scatter(mtf(5), od(5), 600,'diamond', 'filled','LineWidth',1.5); hold on
scatter(mtf(6), od(6), 600,'diamond', 'filled','LineWidth',1.5); hold on
scatter(mtf(7), od(7), 600,'diamond', 'filled','LineWidth',1.5); hold on
scatter(mtf(8), od(8), 600,'diamond', 'filled','LineWidth',1.5); hold on
scatter(mtf(9), od(9), 600,'^', 'filled','LineWidth',1.5); hold on
scatter(mtf(10), od(10), 600,'^', 'filled','LineWidth',1.5); hold on
scatter(mtf(11), od(11), 600,'^', 'filled','LineWidth',1.5); hold on
scatter(mtf(12), od(12), 600,"hexagram", 'filled','LineWidth',1.5); hold on
scatter(mtf(13), od(13), 600,"hexagram", 'filled','LineWidth',1.5); 

% end
xlabel('MTF50 (c/mm)');
ylabel('OD50 (meters)'); 
% ylim([50,300]); xlim([50, 200]);
grid on
set(gca,'fontsize', 28); 

lgnd{1} = 'ps4.2um-f#3.1';
lgnd{2} = 'ps3.5um-f#6.4';
lgnd{3} = 'ps2.8um-f#9.1';
lgnd{4} = 'ps2.1um-f#10.9';
lgnd{5} = 'ps2.8um-f#3.8';
lgnd{6} = 'ps2.1um-f#6.4';
lgnd{7} = 'ps1.4um-f#3.3';
lgnd{8} = 'ps1um-f#8.9';
lgnd{9} = 'ps2.1um-f#2.7';
lgnd{10} = 'ps1.4um-f#5.4';
lgnd{11} = 'ps1um-f#6.1';
lgnd{12} = 'ps1.4um-f#1.9';
lgnd{13} = 'ps1um-f#3.3';
[lgd] = legend(lgnd,'Location','northwest','NumColumns',4);lgd.FontSize = 20;
