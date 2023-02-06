%% plot the AP data for the different cameras
%
% Plots are made for both the day and night simulations
% There are thirteen different cameras
%
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

camera.pSize = [4.2 3.5 2.8 2.1 2.8 2.1 1.4 1.0 2.1 1.4 1.0 1.4 1.0];
camera.fnum =  [3.1 6.4 9.1 10.9 3.8 6.4 3.3 8.9 2.7 5.4 5.1 1.9 3.3];


%% day
distance = [25, 50, 75, 100, 150, 200];
ap_day = [0.889	0.873	0.876	0.87	0.891	0.87	0.859	0.861	0.847	0.849	0.842	0.839	0.799
0.882	0.883	0.86	0.876	0.874	0.832	0.855	0.842	0.851	0.788	0.801	0.78	0.747
0.814	0.805	0.778	0.784	0.792	0.714	0.724	0.739	0.742	0.601	0.67	0.671	0.637
0.735	0.727	0.686	0.719	0.681	0.522	0.532	0.62	0.656	0.407	0.511	0.471	0.42
0.543	0.571	0.362	0.429	0.439	0.221	0.235	0.313	0.394	0.0997	0.191	0.263	0.225
0.448	0.532	0.277	0.31	0.357	0.219	0.17	0.188	0.29	0.0718	0.108	0.182	0.189];

%% night
ap_night = [0.57	0.586	0.522	0.55	0.561	0.496	0.488	0.493	0.518	0.426	0.425	0.462	0.458
0.456	0.469	0.418	0.43	0.408	0.356	0.363	0.332	0.361	0.268	0.284	0.289	0.285
0.395	0.398	0.319	0.336	0.344	0.246	0.264	0.275	0.294	0.176	0.209	0.213	0.225
0.33	0.357	0.276	0.302	0.304	0.186	0.189	0.243	0.245	0.127	0.157	0.176	0.146
0.192	0.212	0.108	0.124	0.142	0.041	0.0589	0.0751	0.0994	0.0148	0.0228	0.0278	0.0339
0.0936	0.14	0.0339	0.0516	0.0721	0.016	0.0182	0.0179	0.1	0.0089	0.0142	0.0279	0.0092];

%% Day
ieNewGraphWin;
for ii = 13:-1:1
    plot(distance, ap_day(:,ii),'-','LineWidth',lWidth,'LineStyle','-','Color',[0.5 0.5 0.5]);  % Lines
    hold on
    scatter(distance, ap_day(:,ii),symSize,symColors(ii,:),sym{ii},'filled','LineWidth',lWidth);
    hold on;
end
set(gca,'fontsize', 28); 
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
grid on
set(gca,'ylim',[0 1]);


