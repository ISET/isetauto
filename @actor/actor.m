classdef actor < matlab.mixin.Copyable
    %ACTOR Dynamic Elements in our scenes
    %   Place and animage assets for running scenarios
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
        brakePower = [-7 0 0]; % -.7g, typical braking power

        % Whether we need to move the camera along with us
        hasCamera = false;
        braking = false;
    end
    
    methods
        function obj = actor()
            %ACTOR Construct an instance of this class
            %   Start with explicit property setting
            
        end
        
        function recipe = place(obj,recipe)
            %place -- put actor as an asset into recipe
            recipe = iaPlaceAsset(recipe, obj.assetType, ...
                obj.position, obj.rotation);
            obj.recipe = recipe;
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

