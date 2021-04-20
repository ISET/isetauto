function [thisR,skymapInfo] = piSkymapAdd(thisR,skyName)
% Choose a skymap, or random skybox, write this line to thisR.world.
%
% Inputs
%   thisR - A rendering recipe
%   skymap options:
%        'morning'
%        'sunset'
%        'cloudy'
%        'random'- pick a random skymap from skymaps folder
%        daytime: 06:41-17:59
% Returns
%   none, but thisR.world is modified.
%
% Example:
%    piSkymapAdd(thisR,'day');
%
% Zhenyi,2018
% Zhenyi, updated, 2021

%%
st = scitran('stanfordlabs');
% sunlights = sprintf('# LightSource "distant" "point from" [ -30 100  100 ] "blackbody L" [6500 1.5]');

if ~piContains(skyName,':')

    skyName = lower(skyName);
    if isequal(skyName,'random')
        index = randi(4,1);
        skynamelist = {'morning','noon','sunset','cloudy'};
        skyName = skynamelist{index};
    end
    thisR.metadata.daytime = skyName;
    switch skyName
        case 'morning'
            skyname = sprintf('morning_%03d.exr',randi(4,1));
        case 'noon'
            skyname = sprintf('noon_%03d.exr',randi(10,1));
            % skyname = sprintf('noon_%03d.exr',9);
        case 'sunset'
            skyname = sprintf('sunset_%03d.exr',randi(4,1));
        case 'cloudy'
            skyname = sprintf('cloudy_%03d.exr',randi(2,1));
    end

    % Get the information about the skymap so we can download from
    % Flywheel

    % Is this data/data bit right?
    try
        acquisition = st.fw.lookup('wandell/Graphics auto/assets/data/skymaps');
        dataId      = acquisition.id;
    catch
        % We have had trouble making lookup work across Add-On toolbox
        % versions.  So we have this
        warning('Using piSkymapAdd search, not lookup')
        acquisition = st.search('acquisitions',...
            'project label exact','Graphics auto',...
            'session label exact','data',...
            'acquisition label exact','skymaps');
        dataId = st.objectParse(acquisition{1});
    end
else
    % Fix this with Flywheel and Justin E
    time = strsplit(skyName,':');
    acqName = sprintf('wandell/Graphics auto/assets/skymap_daytime/%02d00',str2double(time{1}));
    thisAcq = st.fw.lookup(acqName);
    dataId = thisAcq.id;
    skyname= sprintf('probe_%02d-%02d_latlongmap.exr',str2double(time{1}),str2double(time{2}));
end

rotation(:,1) = [0 0 0 1]';
rotation(:,2) = [45 0 1 0]';
rotation(:,3) = [-90 1 0 0]';

thisR = piLightDelete(thisR, 'all');

skymap = piLightCreate('new skymap', 'type', 'infinite',...
    'cameracoordinate', false,...
    'string mapname', skyname,...
    'rotation',rotation);

thisR.set('light', 'add', skymap);


skymapInfo = [dataId,' ',skyname];

end
