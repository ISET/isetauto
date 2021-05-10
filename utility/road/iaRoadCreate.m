function [road,assetRecipe] = iaRoadCreate(varargin)
% Generate a roadtype struct for Sumo TrafficFlow generation
%
% Syntax
%
% Brief description
%
% Input
%  N/A
% Key/value pairs
%  roadtype - See piRoadTypes
%  sceneType  
%  trafficflowDensity - low or high
%  sessions
%  scitran
%  cloudRender
%
% Zhenyi, 2018
% Update: Zhenyi, 2021

%%

% varargin = ieParamFormat(varargin);

p = inputParser;

p.addParameter('roadtype','city_cross_4lanes_002');
p.addParameter('sceneType','city');
p.addParameter('trafficflowDensity','medium');
p.addParameter('scitran',[]);
p.parse(varargin{:});


sceneType    = p.Results.sceneType;
trafficflowDensity = p.Results.trafficflowDensity;
roadtype        = p.Results.roadtype;
st = p.Results.scitran;

if isempty(st), st = scitran('stanfordlabs'); end

%% generate road information
iaRoadInfo;

% load it
load(fullfile(piRootPath,'local','configuration','roadInfo.mat'),'roadinfo');

% Lookup the session with the road information
roadSession = st.fw.lookup('wandell/Graphics auto/assets/road');
%%
vTypes={'pedestrian','passenger','bus','truck','bicycle'};

switch sceneType
    case {'city','city2','city1','city3','city4','citymix'}
        sceneType_tmp = 'city';
        interval=[0.1,0.5,0.05,0.05,0.05];
        %         if piContains(roadtype,'cross')
        %             roadname = sprintf('%s_%s_%dlanes',sceneType_tmp,roadtype,road.nlanes);
        %         else
        %         end
    case {'suburb'}
        sceneType_tmp = sceneType;
        interval=[0.05,0.1,0.01,0.01,0.03];
        %     case'residential'
        %         road.nlanes = 2;
        %         interval=[0.6,0.4,0.02,0.01,0.05];
        %     case 'highway'
        %         sceneType_tmp = sceneType;
        %         if randm ==1,road.nlanes = 6;else, road.nlanes = 8;end
        %         interval=[0,0.9,0.1,0.5,0];
        %         roadname = roadtype;
        %     case 'bridge'
        %         sceneType_tmp = sceneType;
        %         if randm ==1,road.nlanes = 6;else, road.nlanes = 8;end
        %         interval=[0,0.9,0.1,0.5,0];
        %         roadname = sceneType;
end

%% Check the road type and downald road assets


Road_acq = roadSession.acquisitions.findOne(sprintf('label=%s',roadtype));


% This is the rendering recipe for the road session
% fileType_json ='source code'; % json
% recipeFiles = st.dataFileList(roadSession,fileType_json);
% 
% fileType = 'CG Resource';
% [resourceFiles, resource_acqID] = st.dataFileList(roadSession, fileType);


% thisRoad_randm = randi(length(thisRoad),1);
% roadname_update = thisRoad(thisRoad_randm);
% roadname_tmp = strsplit(roadname_update{1},'.');
for ii = 1: length(roadinfo)
    if piContains(roadtype,'construct') % will change name from ***_construct_001 to ***_001_construct
        roadname=strrep(roadtype,'_construct','');
    else
        roadname = roadtype;
    end
    road.name = roadtype;
    if strcmp(roadinfo(ii).name,roadname)
        road.roadinfo =  roadinfo(ii);
        break;
    end
end

% get recipe
assetRecipe = piFWAssetCreate(Road_acq, 'resources', false);


% Set the temporal sampling interval for the SUMO simulation.  
switch trafficflowDensity
    case 'low'
        interval=interval*0.5;
    case 'high'
        interval=interval*1.5;
    otherwise
end

% Map key/value pairs
road.vTypes=containers.Map(vTypes,interval);

%% include "others" data
% others data include basic data which will be used for rendering 
% e.g. lens file, spd files

data_acq = st.fw.lookup('wandell/Graphics auto/assets/data/others');
thisResource = stFileSelect(Road_acq.files,'type','CG Resource');
road.fwList = [data_acq.id,' ','data.zip',' ',...
    Road_acq.id,' ',...
    thisResource{1}.name];
end


