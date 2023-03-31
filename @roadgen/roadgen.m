classdef roadgen < matlab.mixin.Copyable
    % roadgen class - functions to generate a PBRT scene
    %
    % We save the following information:
    %   camera   : lookAt; lens;
    %
    %   road     : roadrunner road information
    %
    %   targetAssets: The assets we used for object detection,e.g.
    %     cars/pedestrian/animals.
    %
    %   backgroundAssets: The assets only used for backgournd formation,
    %     e.g. trees/streetlights/buildings.
    %
    %   assetdirectory: the directory which contains our curated assets.
    %
    % Zhenyi, 2022

    properties (GetAccess=public, SetAccess=public)
        sceneName;
        % cameraUsed;  % It contains the lookAt information and the car ID which the camera belongs to.
        recipe;      % ISET3d recipe includes camera and other info
        road;        % Road specification from Road Runner
        onroad;      % Metadata about the road
        offroad;     % More metadata about the road
        roaddirectory  = '';
        assetdirectory = '/Volumes/SSDZhenyi/Ford Project/PBRT_assets';

    end

    methods 

        % Constructor
        function obj = roadgen(varargin)
            % scene = road('asset directory',yourChoice,'rr map path',yourChoice).
            %
            % rr map path - This is a directory produced by RoadRunner
            %               along with additional files produced via
            %               Blender exports
            %
            % asset directory - Where we are stashing assets for now.
            %
            % This is a road recipe.  It includes an ISET3d recipe, but it
            % also includes specific features for the driving application.
            %

            varargin = ieParamFormat(varargin);

            p = inputParser;
            p.addParameter('roaddirectory','');
            p.addParameter('assetdirectory','/Volumes/SSDZhenyi/Ford Project/PBRT_assets',@ischar)
            %             p.addParameter('lane','');
            %             p.addParameter('pos','');
            %             p.addParameter('pointnum',0);
            %             p.addParameter('layerWidth',5);
            %             p.addParameter('minDistanceToRoad',2);

            p.parse(varargin{:});

            % Assets for this project.  Will generalize later.
            obj.assetdirectory = p.Results.assetdirectory;

            % Road runner data information
            rrMapPath = p.Results.roaddirectory;
            if ~exist(rrMapPath,'folder')
                % If fullpath to the asset is not given, 
                % we will find it in our database
                roadInfo = sceneDB.docFind('assetsPBRT', ...
                    sprintf("{""name"": ""%s""}", road_name));
                if ~isempty(roadInfo)
                    rrMapPath = roadInfo.folder;
                else
                    error('Road Directory can not be located.');
                end
            end
            [~,roadName] = fileparts(rrMapPath);
            obj.sceneName = roadName;

            % read road runner map
            obj = rrMapRead(obj, rrMapPath);

            % create recipe
            pbrtFile = fullfile(rrMapPath,roadName,[roadName,'.pbrt']);
            recipeMat = fullfile(rrMapPath,roadName,[roadName,'.mat']);
            if exist(recipeMat, "file")
                roadRecipe = load(recipeMat);
                obj.recipe = roadRecipe.recipe;
            else
                obj.recipe = piRead(pbrtFile);
            end
        end

        function assetList = assetListCreate(obj)

            if obj.numoftrees>0

            end

            if obj.numofdeers>0

            end

            if obj.numofdeers>0

            end

        end

        function newAssetList = getAssetInfo(obj,assetList)
            % assetList = {'obj1','obj2','obj3'};
            % name; size; position

            newAssetList = cell(size(assetList));

            for ii = 1:numel(assetList)
                [~, thisAsset] = piAssetFind(sceneR.assets, 'name',[assetList{ii},'_m_B']);
                newAssetList{ii}.name = assetList{ii};
                newAssetList{ii}.size = thisAsset{1}.size;
            end
        end
        
        function set(obj,param,val)
            roadSet(obj,param,val);            
        end

        function val = get(obj,param, varargin)
            val = roadGet(obj,param,varargin);
        end

        % Visualization
        function rrDraw(obj, varargin)
            p = inputParser;
            p.addParameter('points',[]);
            p.addParameter('dir',[]);

            p.parse(varargin{:});
            points = p.Results.points;
            dir    = p.Results.dir;
            
            fig = get(groot,'CurrentFigure');
            % create a fig if one does not exist.
            if isempty(fig)
                figure(1);
            else
                figure(fig);
            end
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


