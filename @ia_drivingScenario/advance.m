%% Simulation turn advance
function running = advance(scenario)

% Need to place vehicles and actors now that we hopefully have yaw data
% Just do this once:
if scenario.needToPlaceVehicles == true
    scenario.placeVehicles();
    scenario.needToPlaceVehicles = false;
end
if scenario.needToPlaceActors == true
    scenario.placeActors();
    scenario.needToPlaceActors = false;
end

% Set our interval for use in computing motion
ourTimeStep = scenario.SampleTime;

% We may want to skip initial frame since it doesn't have yaw
% correct
if scenario.justStarting ~= true
    % First we show where we are (were)
    piWrite(scenario.roadData.recipe);
    scene = piRender(scenario.roadData.recipe);
    if scenario.deNoise == true
        scene = piAIdenoise(scene,'quiet', true, 'batch', true);
    end

    % add to our scene list for logging
    scenario.sceneList{end+1} = scene;

    % show preview if desired
    previousScene = [];
    if isempty(previousScene), previousScene = sceneCreate(); end
    if scenario.previewScenes
        scene = sceneSet(scene, 'display mode', 'hdr');
        % try sceneshowimage
        % Note: Faster but leads to un-labeled Window sprawl until we
        %       add some more pieces
        %sceneShowImage(scene, 3);
        sceneWindow(scene);

        %{ 
            % THIS IS JUST FOR DEBUGGING CHANGES IN RECIPES
        ourRecipe = scenario.roadData.recipe;
        sceneShowImage(previousScene, -3);
        previousScene = scene;
        previousRecipe = ourRecipe;
        %}
    end

    % Create an image with a camera, and run a detector on it
    [image, scenario.detectionResults] = scenario.imageAndDetect(scene);

    % Here we want to create a movie/video
    % presumably one frame at a time
    addToVideo(scenario, scene, image);
else
    scenario.justStarting = false;
end

% Move Actors based on their velocity
% e.g. both the egoVehicle & the lookAt from/to
% Assume that egoVehicle is #1
for ii = 1:numel(scenario.roadData.actorsIA)
    ourActor = scenario.roadData.actorsIA{ii};
    if ourActor.hasCamera
        egoVelocity = scenario.roadData.actorsDS{ii}.Velocity;

        % if we have a pedestrian, begin braking
        if  ~isempty(scenario.detectionResults) && ...
                ~isempty(scenario.detectionResults.foundPed) && ...
                (scenario.detectionResults.foundPed == true)

            cprintf('*Red','found ped\n');
            % braking should move closer to abs()
            % for now just decelerate in forward/back
            if ourActor.velocity(1) < 0
                % negativeVelocity = true;
                ourActor.velocity(1) = ...
                    ourActor.velocity(1) - ourActor.brakePower(1);
            else
                % negativeVelocity = false;
                ourActor.velocity(1) = ...
                    ourActor.velocity(1) + ourActor.brakePower(1);
            end

            ourActor.velocity(1) = ...
                max(ourActor.velocity(1) - ...,
                0);
        end

        % Move camera
        adjustedVelocity = ia_drivingScenario.dsToIA(egoVelocity);
        scenario.roadData.recipe.lookAt.from = ...
            scenario.roadData.recipe.lookAt.from + ...
            (adjustedVelocity .* ourTimeStep);
    end
    % Debug statements with current info
    currentActor = scenario.roadData.actorsDS{ii};
    assetBranchName = strcat(currentActor.Name, '_B');
    [~, currentAsset] = piAssetFind(scenario.roadData.recipe, 'name', assetBranchName);
    % I think we get a cell array from Find in case there is more than one?
    %{ 
    % Unfortunately this doesn't seem to work except for lights!
    currentRotation = piAssetGet(currentAsset{1}, 'worldrotation');
    %}
    cprintf('*Blue', "DSVelocity %s : %2.1f, %2.1f, %2.1f ", ...
        currentActor.Name, ...
        currentActor.Velocity(1), ...
        currentActor.Velocity(2), ...
        currentActor.Velocity(3));
    cprintf('*Blue', "DSyaw: %2.1f\n", currentActor.Yaw);
    % Also move our Actors by time step * velocity
    % move asset per velocity inherited from DS
    ourActor.yaw = currentActor.Yaw;
    ourActor.moveAsset(scenario, ...
        currentActor);
    % Then determine whether braking & subtract from Velocity
    % (We can't just subtract from speed, as it has been broken
    % into velocity components already based on waypoints
    % In this case we also need to modify the SDS version of
    % Velocity

    % run super-class method
end
running = advance@drivingScenario(scenario);
end


