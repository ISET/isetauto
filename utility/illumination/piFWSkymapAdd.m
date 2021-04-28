function [acqID,skyname] = piFWSkymapAdd(skyName,st)
% Find a skymap on Flywheel
%
% Inputs
%   skyName:  (Name of the type of sky)
%          'morning'
%          'sunset'
%          'cloudy'
%          'random'  - pick a random skymap from skymaps folder
%           daytime:  06:41-17:59
%   st -  Scitran object
%
% Returns
%   acqID  - Flywheel acquisition ID
%   fname  - Name of the skymap
%
% Zhenyi,2018
% Zhenyi, updated, 2021
%
% See also
%   piSkymapAdd

%%
if notDefined('skyName'), error('Sky name required'); end
if notDefined('st'), st = scitran('stanfordlabs'); end


%% Figure out the name of the file
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
    
    % We will clean up the skymaps on Flywheel.  But for now, we are
    % searching through data/skymaps
    try
        % Find the acquisition that contains the skymaps
        acquisition = st.lookup('wandell/Graphics auto/assets/data/skymaps');
        acqID      = acquisition.id;
    catch
        % We have had trouble making lookup work across Add-On toolbox
        % versions.  So we have this
        warning('Using piSkymapAdd search, not lookup')
        acquisition = st.search('acquisitions',...
            'project label exact','Graphics auto',...
            'session label exact','data',...
            'acquisition label exact','skymaps');
        acqID = st.objectParse(acquisition{1});
    end
else
    % Fix this with Flywheel and Justin E
    time = strsplit(skyName,':');
    acqName = sprintf('wandell/Graphics auto/assets/skymap_daytime/%02d00',str2double(time{1}));
    thisAcq = st.lookup(acqName);
    acqID = thisAcq.id;
    skyname= sprintf('probe_%02d-%02d_latlongmap.exr',str2double(time{1}),str2double(time{2}));
end

end


