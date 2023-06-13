classdef ia_drivingScenario < drivingScenario
    %IA_DRIVINGSCENARIO our custom version of a driving scenario

    % D. Cardinal, Stanford University, June, 2023

    properties
        roadData = []; % our ISETAuto road data struct
        % We get these from our superclass
        %waypoints; % in meters
        %speed; % meters/second
        numActors = 0;
        egoVehicle = [];

        % We don't get Pose information on Actors and Vehicles until
        % after we start up the scenario. So we need to create a collection
        % of them as they are initialized, for later placement.
        vehicleCount = 1;
        actorCount = 1;
        needToPlaceVehicles = true;
        needToPlaceActors = true;
        vehiclesToBePlaced = {};
        actorsToBePlaced = {};

        frameNum = 1; % to start
        scenarioName = 'LabTest'; % default
        scenarioQuality = 'quick'; % default

        v = [];
        % video structure with frames for creating clips
        ourVideo = struct('cdata',[],'colormap',[]);

        sceneList = {};

    end

    methods
        function ds = ia_drivingScenario(varargin)

            % Let the Matlab driving scenario (superclass) set things up first
            % ds now contains a "blank slate" scenario
            ds = ds@drivingScenario(varargin{:});

            % Should we do the ieInit/dockerInit here
            % Better at beginning of script, but that's generated
            % each time by Matlab
            %% Initialize ISET and Docker
            ieInit;
            if ~piDockerExists, piDockerConfig; end


        end

        %% We only use the road to tell us which of our road scenes
        % to load (based on the road name)
        % Here is the default call used by the ds superclass:
        % road(scenario, roadCenters, 'Heading', headings, 'Lanes', laneSpecification, 'Name', 'road_020');
        function road(scenario, segments, varargin)
            p = inputParser;
            p.addParameter('Name', 'road_020');
            p.KeepUnmatched = true; % we don't parse all args here
            p.parse(varargin{:});

            roadName = p.Results.Name;
            % LOAD ROAD DATA/SCENE into ISETAuto
            % We need to specify our own lighting
            % Road data is our IA data we stash in the driving scenario
            scenario.roadData = scenario.initRoadScene(roadName, 'nighttime');

            % Set up video here because it doesn't like the constructor
            % VideoWriter variables
            scenario.scenarioName = 'LabDemo';
            scenario.scenarioQuality = 'quick';
            scenario.v = VideoWriter(strcat(scenario.scenarioName, "-", scenario.scenarioQuality),'MPEG-4');
            scenario.v.FrameRate = 3; % high fidelity

            % Set output rendering quality
            iaQualitySet(scenario.roadData.recipe, 'preset', scenario.scenarioQuality);
            road@drivingScenario(scenario, segments, varargin{:});
        end

        % The name is what we use to know what vehicle to add
        % We can also use other assets by name
        %{
        % This is a sample call used by matlab
        egoVehicle = vehicle(scenario, ...
            'ClassID', 1, ...
            'Position', [-95.8 -4.9 0], ...
            'Mesh', driving.scenario.carMesh, ...
            'Name', 'car_004');
        waypoints = [-95.8 -4.9 0;
            -78.3 -6.2 0;
            -65.7 -6 0;
            -45.2 -5.6 0];
        speed = [17;17;17;17];
        trajectory(egoVehicle, waypoints, speed);
        %}

        % Scenario is our Object
        % We'll assume first vehicle is egoVehicle
        function vehicleDS = vehicle(scenario, varargin)

            p = inputParser;
            p.addParameter('ClassID',1); % don't know if we need this
            p.addParameter('Name','car_004', @ischar);
            p.addParameter('Position', [0 0 0]);

            % DS Doesn't pass yaw. Sigh.
            %p.addParameter('Yaw', 0); % rotation on road
            p.KeepUnmatched = true;
            p.parse(varargin{:});


            % Add Vehicle asset to our @Recipe
            ourVehicle = isetActor();

            % This is the Matlab (DS) position (x & y reversed from ISETauto)
            ourVehicle.positionDS = p.Results.Position;

            % what about pitch, roll, yaw?
            %ourCar.rotation = [0 0 180]; % facing forward
            ourVehicle.assetType = p.Results.Name;
            ourVehicle.name = p.Results.Name;

            ourVehicle.velocity = [0 0 0]; % set separately

            % call with egoVehicle if we have the sensors?
            vehicleDS = vehicle@drivingScenario(scenario, varargin{:});

            % Set first vehicle as ego vehicle
            if isempty(scenario.egoVehicle)
                scenario.egoVehicle = vehicleDS;
                ourVehicle.hasCamera = true;
            end

            % We don't get poses right away from DSD, so we might
            % need to stack these up and execute on advance

            addActor(scenario, vehicleDS, ourVehicle);

            % Start a queue of vehicles to be placed once we know
            % their Pose (mostly Yaw)
            scenario.vehiclesToBePlaced{scenario.vehicleCount} = {ourVehicle, vehicleDS};
            scenario.vehicleCount = scenario.vehicleCount + 1;

        end

        %% Non-vehicle actors (e.g. Pedestrians, Animals, etc.)
        % These an also be animated using Waypoints
        %{
        actor(scenario, ...
            'ClassID', 4, ...
            'Length', 0.24, ...
            'Width', 0.45, ...
            'Height', 1.7, ...
            'Position', [-30.6 -5.6 0], ...
            'RCSPattern', [-8 -8;-8 -8], ...
            'Mesh', driving.scenario.pedestrianMesh, ...
            'Name', 'pedestrian_001');
        %}

        %% Create an actor struct for DSD to use
        function actorDS = actor(scenario, varargin)
            p = inputParser;
            p.addParameter('ClassID',4); % don't know if we need this
            p.addParameter('Name','pedestrian_001', @ischar);
            p.addParameter('Position', [0 0 0]);
            p.addParameter('Length', .24);
            p.addParameter('Height', 1.7);
            p.addParameter('Width', .45);

            p.KeepUnmatched = true;
            p.parse(varargin{:});

            ourActor = isetActor();

            % ADD NON_VEHICLE ASSET OR AT LEAST SET PARAMETER
            ourActor.positionDS = p.Results.Position;
            ourActor.assetType = p.Results.Name;
            ourActor.name = p.Results.Name;

            ourActor.velocity = [0 0 0]; % set separately

            % We place later, after we know the Pose
            %ourActor.place(scenario);
            actorDS = actor@drivingScenario(scenario, varargin{:});
            addActor(scenario, actorDS, ourActor);

            % Start a queue of actors to be placed once we know
            % their Pose (mostly Yaw)
            scenario.actorsToBePlaced{scenario.actorCount} = {ourActor, actorDS};
            scenario.actorCount = scenario.actorCount + 1;

        end

        % For potential future use, right now we just call superclass
        function trajectory(scenario, egoVehicle, waypoints, speed)
            trajectory@drivingScenario(scenario, egoVehicle, waypoints, speed);
        end

        % We need to keep track of actors so we can animate them
        % NOTE: Haven't integrated Pose with non-vehicle actors yet
        function addActor(scenario, actorDS, actorIA)
            if scenario.numActors == 0
                scenario.roadData.actorsDS = {};
                scenario.roadData.actorsIA = {};
                scenario.numActors = 1;
            else
                scenario.numActors = scenario.numActors + 1;
            end
            scenario.roadData.actorsDS{scenario.numActors} = actorDS;
            scenario.roadData.actorsIA{scenario.numActors} = actorIA;
        end

        %% Simulation turn advance 
        function running = advance(scenario)

            % Need to place vehicles and actors now that we hopefully have yaw data
            if scenario.needToPlaceVehicles == true
                scenario.placeVehicles();
                scenario.needToPlaceVehicles = false;
            end
            if scenario.needToPlaceActors == true
                scenario.placeActors();
                scenario.needToPlaceActors = false;
            end

            % NOTE: Next we can place other animate assets
            %       once we move their code to a .placeActors() method;

            % First we show where we are (were)
            piWrite(scenario.roadData.recipe);
            scene = piRender(scenario.roadData.recipe);
            % Denoise with Nvidia if possible,
            % Currently an issue with writing .exr file
            %[~, txtHostname] = system('hostname'); 
            % if isequal(strtrim(txtHostname), 'Decimate')
            %    scene = piAIdenoise(scene, 'useNvidia', true);
            % else
                scene = piAIdenoise(scene, 'quiet', true, 'interleave', true);
            % end

            % add to our scene list
            scenario.sceneList{end+1} = scene;
            scene = sceneSet(scene, 'display mode', 'hdr');
            sceneWindow(scene);

            % Here we want to create a movie/video
            % presumably one frame at a time
            addToVideo(scenario, scene);

            % This might be more current
            ourTimeStep = scenario.SampleTime;

            % Move Actors based on their velocity
            % e.g. both the egoVehicle & the lookAt from/to
            % Assume that egoVehicle is #1
            for ii = 1:numel(scenario.roadData.actorsIA)
                ourActor = scenario.roadData.actorsIA{ii};
                if ourActor.hasCamera
                    egoVelocity = scenario.roadData.actorsDS{ii}.Velocity;
                    % Move camera
                    adjustedVelocity = egoVelocity .* [-1 -1 0];
                    scenario.roadData.recipe.lookAt.from = ...
                        scenario.roadData.recipe.lookAt.from + ...
                        (adjustedVelocity .* ourTimeStep);
                end
                % Also move our Actors by time step * velocity
                fprintf("DSVelocity for %s : %2.1f, %2.1f, %2.1f\n", ...
                    scenario.roadData.actorsDS{ii}.Name, ...
                    scenario.roadData.actorsDS{ii}.Velocity(1), ...
                    scenario.roadData.actorsDS{ii}.Velocity(2), ...
                    scenario.roadData.actorsDS{ii}.Velocity(3));

                % move asset per velocity inherited from DS
                ourActor.moveAsset(scenario, ...
                    scenario.roadData.actorsDS{ii});
            end


            % Then determine whether braking & subtract from Velocity
            % (We can't just subtract from speed, as it has been broken
            % into velocity components already based on waypoints
            % In this case we also need to modify the SDS version of
            % Velocity

            % run super-class method
            running = advance@drivingScenario(scenario);
        end

        function placeVehicles(scenario)

            % get poses needed for Yaw calcs
            gotPoses = actorPoses(scenario);
            %relativePoses = targetPoses(scenario.egoVehicle);

            % find yaw ourselves
            allPoses = gotPoses;

            for ii = 1:numel(scenario.vehiclesToBePlaced)
                ourVehicle = scenario.vehiclesToBePlaced{ii};
                ourPose = allPoses(ourVehicle{2}.ActorID);

                if isfield(ourPose,'Yaw')
                    ourVehicle{1}.yaw = ourPose.Yaw;
                else
                    ourVehicle{1}.yaw = 0;
                end

                % Now we can place the vehicle
                ourVehicle{1}.place(scenario);
            end
        end

        % Maybe this can be combined with placeVehicles?
        function placeActors(scenario)

            % get poses needed for Yaw calcs
            gotPoses = actorPoses(scenario);
            %relativePoses = targetPoses(scenario.egoVehicle);

            % find yaw ourselves
            allPoses = gotPoses;

            for ii = 1:numel(scenario.actorsToBePlaced)
                ourActor = scenario.actorsToBePlaced{ii};
                ourPose = allPoses(ourActor{2}.ActorID);

                if isfield(ourPose,'Yaw')
                    ourActor{1}.yaw = ourPose.Yaw;
                else
                    ourActor{1}.yaw = 0;
                end

                % Now we can place the vehicle
                ourActor{1}.place(scenario);
            end
        end
    end
end

