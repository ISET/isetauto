classdef scenegen < matlab.mixin.Copyable
    % Scenegen class contains essential functions to generate a scene in PBRT
    % format.
    % We save the following information:
    %   camera   : lookAt; lens;
    %
    %   road     : roadrunner road information
    %
    %   timeofday: we have a collection of skymaps captured from morning to
    %   dusk.(Aroung 7AM to 6PM) at one minute interval, we pick one for
    %   current scene.
    %
    %   skymap   : We also have other skymaps roughly categorized by
    %   morning/afternoon/night, we save the information here when we use
    %   these set of skymaps.
    %
    %   targetAssets: The assets we used for object detection,e.g.
    %   cars/pedestrian/animals.
    %
    %   backgroundAssets: The assets only used for backgournd formation,
    %   e.g. trees/streetlights/buildings.
    %
    %   assetdirectory: the directory which contains our curated assets.
    %
    % Zhenyi, 2022

    properties (GetAccess=public, SetAccess=public)
        assetInfo; % asset library: name and size for each object.
        camera;
        recipe;
        road;
        timeofday;
        skymap;
        onroad;
        offroad;
        rrdatadirectory = '';
        assetdirectory = '/Volumes/SSDZhenyi/Ford Project/PBRT_assets';

    end

    methods (Static)
        function obj = scenegen(varargin)
            
            p = inputParser;
            p.addParameter('rrmappath','');
%             p.addParameter('lane','');
%             p.addParameter('pos','');
%             p.addParameter('pointnum',0);
%             p.addParameter('layerWidth',5);
%             p.addParameter('minDistanceToRoad',2);

            p.parse(varargin{:});

            rrMapPath = p.Results.rrmappath;
            [~,roadName] = fileparts(rrMapPath);

            % read road runner map
            obj = rrMapRead(obj, rrMapPath);

            % create recipe
            obj.recipe = piRead(fullfile(rrMapPath,roadName,[roadName,'.pbrt']));
        end

        function [obj, val] = set(obj,varargin)

        end

        function [obj, val] = get(obj, varargin)

        end

        function assetList = assetListCreate(obj)

            if obj.numoftrees>0

            end

            if obj.numofdeers>0

            end

            if obj.numofdeers>0

            end

        end

        function newAssetList = getAssetInfo(assetList)
            % assetList = {'obj1','obj2','obj3'};
            % name; size; position

            newAssetList = cell(size(assetList));

            for ii = 1:numel(assetList)
                [~, thisAsset] = piAssetFind(sceneR.assets, 'name',[assetList{ii},'_m_B']);
                newAssetList{ii}.name = assetList{ii};
                newAssetList{ii}.size = thisAsset{1}.size;
            end
        end

        
        
        % visulization
        function rrDraw(obj, varargin)
            p = inputParser;
            p.addParameter('points',[]);
            p.addParameter('dir',[]);

            p.parse(varargin{:});
            points = p.Results.points;
            dir    = p.Results.dir;

            figure;
            fieldNameLists = fieldnames(obj.road);
            for ii = 1:numel(fieldNameLists)
                lanePoints = obj.road.(fieldNameLists{ii});
                plot(lanePoints(:,1),lanePoints(:,2),'-');
                axis equal;hold on;
            end
            if ~isempty(points)
                for ii = 1:size(points,1)
                    rotation = rad2deg(dir(ii));
                    plot(points(ii,1),points(ii,2), 'r*');
                text(points(ii,1),points(ii,2),'\rightarrow',...
                    'FontSize',30,'Rotation',rotation,...
                    'HorizontalAlignment','center');
                end
            end
            title('Bird view of the road');
            xlabel('meters');
            ylabel('meters');
        end
        


    end


end


