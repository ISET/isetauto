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

        % coordinate systems are different between DS & IA
        positionDS = [];
        positionIA = [];
        rotation = [];
        velocity = [];
        yaw = 0; % rotation on road
        brakePower = [-7 0 0]; % -.7g, typical braking power

        % Whether we need to move the camera along with us
        hasCamera = false;
        braking = false;
        %cameraOffset = [1 0 1.2]; % good for car_004 (Shelby)
        cameraOffset = [.9 0 1.5]; % good for car_058 (F150)

    end

    methods
        function obj = isetActor()
            %ACTOR Construct an instance of this class
            %   Start with explicit property setting

        end

        %%  For DSD scenarios we get a scenario
        %  that has scenario.roadData.recipe
        function egoVehicle = place(anActor,scenario)
            % Coordinate systems are different
            anActor.positionIA = anActor.positionDS .* scenario.coordinateMapping;

            % placeAsset redoes the recipeMerge, which is of course an
            % error from the vehicle placement queue
            anActor.placeAsset(scenario);
            anActor.recipe = scenario.roadData.recipe;

            % If we have the camera, move it
            if anActor.hasCamera
                anActor.recipe.lookAt.from = ...
                    anActor.positionIA + anActor.cameraOffset;

                % We need to rotate our camera view to match anActor.yaw
                rotationMatrix = makehgtform('zrotate',deg2rad(-1 * anActor.yaw));
                % assume "in the distance" on x is the default, but then
                anActor.recipe.lookAt.to = ...
                    anActor.recipe.lookAt.from + [-300 0 0] * rotationMatrix(1:3, 1:3);

                % We almost always want "up" to be straight up 
                anActor.recipe.lookAt.up = [0 0 1]; % set per recipe or per lookat
                egoVehicle = anActor;
            end

        end

        %% Mostly deprecated, as we are using the DSD/ML simulation engine
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

