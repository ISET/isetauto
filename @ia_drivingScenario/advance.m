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
    if isempty(scene)
        error("Failed to render. dockerwrapper.reset might help\n");
    end
    if scenario.deNoise == true
        scene = piAIdenoise(scene,'quiet', true, 'batch', true);
    end

    % add to our scene list for logging
    scenario.sceneList{end+1} = scene;

    % show preview if desired
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
        if isempty(previousScene), previousScene = sceneCreate(); end
        sceneShowImage(previousScene, -3);
        previousScene = scene;
        previousRecipe = ourRecipe;
        %}
    end

    % Create an image with a camera, and run a detector on it
    image = scenario.imageAndDetect(scene);
    scenario.logFrameData(scene, scenario.detectionResults); % update our logging data structure

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

    % assume we are looking for ped 001
    if isempty(scenario.targetObject) && isequal(ourActor.name, 'pedestrian_001')
        scenario.targetObject = ourActor;
    end
    
    if ourActor.hasCamera
        ourActorDS = scenario.roadData.actorsDS{ii};
        if scenario.needEgoVelocity
            scenario.egoVelocity = ourActorDS.Velocity;
            scenario.needEgoVelocity = false;
        end
        
        % if we have a pedestrian, begin braking
        if  scenario.foundPed == true

            cprintf('*Red','Recognized pedestrian\n');
            % braking should move closer to abs()
            % for now just decelerate in forward/back
            ourActorDS.Velocity = scenario.egoVelocity + ...
                (ourActor.brakePower * scenario.stepTime);
            scenario.egoVelocity(1) = max(ourActorDS.Velocity(1), 0);
            ourActorDS.Velocity(1) = scenario.egoVelocity(1);

        end

        % Move camera
        adjustedVelocity = scenario.egoVelocity;
        scenario.roadData.recipe.lookAt.from = ...
            scenario.roadData.recipe.lookAt.from + ...
            (adjustedVelocity .* ourTimeStep);
        % NEED to make this follow Yaw!
        scenario.roadData.recipe.lookAt.to = ...
            scenario.roadData.recipe.lookAt.from + [200 0 0];
        cprintf('*Green', 'Camera from: %2.1f to: %2.1f\n', ...
            scenario.roadData.recipe.lookAt.from(1), ...
            scenario.roadData.recipe.lookAt.to(1));
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
    cprintf('*Blue', "DSVelocity %s : %2.2f, %2.2f, %2.1f", ...
        currentActor.Name, ...
        currentActor.Velocity(1), ...
        currentActor.Velocity(2), ...
        currentActor.Velocity(3));
    cprintf('*Blue', ", DSyaw: %2.1f\n", currentActor.Yaw);
    % Also move our Actors by time step * velocity
    % move asset per velocity inherited from DS
    ourActor.yaw = currentActor.Yaw;
    ourActor.moveAsset(scenario, ...
        currentActor);
end
% run super-class method
running = advance@drivingScenario(scenario);

% If scenario has ended, analyze results
if ~running
    scenario.analyzeData();
end
end


