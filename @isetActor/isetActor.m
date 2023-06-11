classdef isetActor < handle & matlab.mixin.Copyable
    %ACTOR Dynamic Elements in our scenes
    %   Place and animate assets for running scenarios
    %
    %   Initially written to support ISETAuto "native" scenarios
    %   Now we need to deal with scenarios imported from Matlab SDS
    %
    % D. Cardinal, Stanford University, June, 2023
    %
    properties
        name = '';
        recipe = [];
        assetType;
        branchID;
        position = [];
        rotation = [];
        velocity = [];
        yaw = 0; % rotation on road
        brakePower = [-7 0 0]; % -.7g, typical braking power

        % Whether we need to move the camera along with us
        hasCamera = false;
        braking = false;
    end
    
    methods
        function obj = isetActor()
            %ACTOR Construct an instance of this class
            %   Start with explicit property setting
            
        end
        
        %% For ISET scenarios we get a recipe
        %  For SDS scenarios we get a scenario
        %  that has scenario.roadData.recipe
        function recipe = place(obj,context)
            if isequal(class(context),'recipe')
                %place -- put actor as an asset into recipe
                recipe = context;
                recipe = iaPlaceAsset(recipe, obj.assetType, ...
                    obj.position, obj.rotation);
                obj.recipe = recipe;
            else
                % Assume we have a scenario
                scenario = context;
                % Coordinate systems are different
                obj.position = obj.position .* [-1 -1 1];
                obj.placeAsset(scenario);
                obj.recipe = scenario.roadData.recipe;

                % If we have the camera, move it
                if obj.hasCamera
                    obj.recipe.lookAt.from = ...
                        obj.recipe.lookAt.from + obj.position;
                end
            end
        end

        function turn(obj, seconds)
            assetBranchName = [obj.assetType '_B'];

            if obj.braking % Assume braking is straight ahead for now
                obj.velocity(1) = max(0, obj.velocity(1) + (obj.brakePower(1) * seconds));
            end
            % x direction needs to be reversed
            actualV = obj.velocity .* [-1 1 1];

            piAssetTranslate(obj.recipe,assetBranchName,actualV .* seconds);
            if obj.hasCamera
                obj.recipe.lookAt.from = obj.recipe.lookAt.from + (actualV .* seconds);
            end
        end
    end
end

