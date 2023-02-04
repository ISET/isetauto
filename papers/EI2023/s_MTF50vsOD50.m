%% mtf vs od50
%
%  Computed analysis by Zhenyi of the relationship between MTF50 and OD50
%
% See also
%   s_ei*

%% Values
mtf = [55 55 55 55 75 75 75 75 100 100 100 150 150];

% Separated by night and day
od50_night = [40.3509   43.3761   30.2885   35.4167   34.9673   24.2857   22.6000   23.9130   27.8662   13.2911   11.7021   19.5087   18.9306];

od50_day = [172.6316  241.0256  128.7037  137.7586  137.3967  103.6545  105.3872  119.5440  129.7710   88.0155  101.7188   96.3750   90.7834];

od = od50_day;
od = flip(od);

%%
ieNewGraphWin([],'tall');
symSize = 600;

delta9 = 2;

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
for ii=1:numel(mtf)
    if ii==9
        % Make it visible underneat the red
        scatter(mtf(ii),od(ii)- delta9,symSize,symColors(ii,:),sym{ii},'filled','LineWidth',lWidth);
    else
        scatter(mtf(ii),od(ii),symSize,symColors(ii,:),sym{ii},'filled','LineWidth',lWidth);
    end
    hold on;
end

%{
scatter(mtf(1), od(1), symSize, symColors(1,:),'o', 'filled','LineWidth',lWidth); hold on
scatter(mtf(2), od(2), symSize, symColors(2,:),'o','filled','LineWidth',lWidth); hold on
scatter(mtf(3), od(3), symSize, symColors(3,:),'o','filled','LineWidth',lWidth); hold on
scatter(mtf(4), od(4), symSize, symColors(4,:),'o', 'filled','LineWidth',lWidth); hold on
scatter(mtf(5), od(5), symSize,'square', 'filled','LineWidth',lWidth); hold on
scatter(mtf(6), od(6), symSize,'square', 'filled','LineWidth',lWidth); hold on
scatter(mtf(7), od(7), symSize,'square', 'filled','LineWidth',lWidth); hold on
scatter(mtf(8), od(8), symSize,'square', 'filled','LineWidth',lWidth); hold on
scatter(mtf(9), od(9), symSize,'^', 'filled','LineWidth',lWidth); hold on
scatter(mtf(10), od(10), symSize,'^', 'filled','LineWidth',lWidth); hold on
scatter(mtf(11), od(11), symSize,'^', 'filled','LineWidth',lWidth); hold on
scatter(mtf(12), od(12), symSize,"hexagram", 'filled','LineWidth',lWidth); hold on
scatter(mtf(13), od(13), symSize,"hexagram", 'filled','LineWidth',lWidth); 
%}
% xlabel('MTF50 (c/mm)');
% ylabel('OD50 (meters)'); 
% ylim([50,300]); xlim([50, 200]);
grid on
set(gca,'fontsize', 28); 



%%  Add the night time values

od = od50_night;
od = flip(od);

hold on
lWidth = 2;
for ii=1:numel(mtf)
    if ii==9
        % Make it visible underneat the red
        scatter(mtf(ii),od(ii)-delta9,symSize,symColors(ii,:),sym{ii},'LineWidth',lWidth);
    else
        scatter(mtf(ii),od(ii),symSize,symColors(ii,:),sym{ii},'LineWidth',lWidth);
    end
    hold on;
end

%{

scatter(mtf(1), od(1), symSize, 'o', 'LineWidth',lWidth); hold on
scatter(mtf(2), od(2), symSize,'o', 'LineWidth',lWidth); hold on
scatter(mtf(3), od(3), symSize,'o', 'LineWidth',lWidth); hold on
scatter(mtf(4), od(4), symSize,'o', 'LineWidth',lWidth); hold on
scatter(mtf(5), od(5), symSize,'square', 'LineWidth',lWidth); hold on
scatter(mtf(6), od(6), symSize,'square', 'LineWidth',lWidth); hold on
scatter(mtf(7), od(7), symSize,'square', 'LineWidth',lWidth); hold on
scatter(mtf(8), od(8), symSize,'square', 'LineWidth',lWidth); hold on
scatter(mtf(9), od(9), symSize,'^', 'LineWidth',lWidth); hold on
scatter(mtf(10), od(10), symSize,'^', 'LineWidth',lWidth); hold on
scatter(mtf(11), od(11), symSize,'^', 'LineWidth',lWidth); hold on
scatter(mtf(12), od(12), symSize,"hexagram", 'LineWidth',lWidth); hold on
scatter(mtf(13), od(13), symSize,"hexagram", 'LineWidth',lWidth); 
%}

% xlabel('MTF {50} (cycles/mm)');
% ylabel('OD {50} (m)'); 
set(gca,'fontsize', 28); 
grid on

set(gca,'xlim',[50 200])
set(gcf,'Position',[0.0070 0.4486 0.2800 0.4564]);
%%
%{
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
%}

%% plot all data for different mtf50
% day
distance = [25, 50, 75, 100, 150, 200];
ap_day = [0.889	0.873	0.876	0.87	0.891	0.87	0.859	0.861	0.847	0.849	0.842	0.839	0.799
0.882	0.883	0.86	0.876	0.874	0.832	0.855	0.842	0.851	0.788	0.801	0.78	0.747
0.814	0.805	0.778	0.784	0.792	0.714	0.724	0.739	0.742	0.601	0.67	0.671	0.637
0.735	0.727	0.686	0.719	0.681	0.522	0.532	0.62	0.656	0.407	0.511	0.471	0.42
0.543	0.571	0.362	0.429	0.439	0.221	0.235	0.313	0.394	0.0997	0.191	0.263	0.225
0.448	0.532	0.277	0.31	0.357	0.219	0.17	0.188	0.29	0.0718	0.108	0.182	0.189];

ap_night = [0.57	0.586	0.522	0.55	0.561	0.496	0.488	0.493	0.518	0.426	0.425	0.462	0.458
0.456	0.469	0.418	0.43	0.408	0.356	0.363	0.332	0.361	0.268	0.284	0.289	0.285
0.395	0.398	0.319	0.336	0.344	0.246	0.264	0.275	0.294	0.176	0.209	0.213	0.225
0.33	0.357	0.276	0.302	0.304	0.186	0.189	0.243	0.245	0.127	0.157	0.176	0.146
0.192	0.212	0.108	0.124	0.142	0.041	0.0589	0.0751	0.0994	0.0148	0.0228	0.0278	0.0339
0.0936	0.14	0.0339	0.0516	0.0721	0.016	0.0182	0.0179	0.1	0.0089	0.0142	0.0279	0.0092];
ieNewGraphWin([],'wide');
for ii = 13:-1:1
    plot(distance, ap_day(:,ii),'Color',symColors(ii,:),'LineWidth',lWidth);hold on
    plot(distance,ap_night(:,ii),'-.','Color',symColors(ii,:),'LineWidth',lWidth);hold on
end
set(gca,'fontsize', 28); 
grid on

