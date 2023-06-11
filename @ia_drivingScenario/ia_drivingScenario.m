classdef ia_drivingScenario < drivingScenario
    %IA_DRIVINGSCENARIO our custom version of a driving scenario

    % D. Cardinal, Stanford University, June, 2023

    properties
        roadData; % our ISETAuto road data struct
        waypoints; % in meters (might just be able to get from superclass
        speed; % meters/second (might just be able to get from superclass
    end

    methods
        function ds = ia_drivingScenario(varargin)

            % Should we do the ieInit/dockerInit here
            % Better at beginning of script, but that's generated
            % each time by Matlab

            % However we definitely need to clear the egoVehicle:
            clear vehicle;
            clear advance;

            % Let the Matlab driving scenario (superclass) set things up first
            % ds now contains a "blank slate" scenario
            try
                %parseInputs(ds, varargin{:});
            catch ME
                throwAsCaller(ME);
            end
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
            scenario.roadData = scenario.initRoadScene(roadName, 'dusk');
            road@drivingScenario(scenario, segments, varargin{:});
        end

        % The name is what we use to know what vehicle to add
        % We can also use other object names (like building_xxx)
        %{
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
        % Not clear how egoVehicle gets set
        % Maybe as simple as if a return value is requested
        % it is used as the ego vehicle
        function vehicleID = vehicle(scenario, varargin)

            persistent egoVehicle;
            p = inputParser;
            p.addParameter('ClassID',1); % don't know if we need this
            p.addParameter('Name','car_004', @ischar);
            p.addParameter('Position', [0 0 0]);
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            % Add Vehicle asset to our @Recipe
            ourCar = isetActor();
            ourCar.position = p.Results.Position;
            % what about pitch, roll, yaw?
            %ourCar.rotation = [0 0 180]; % facing forward
            ourCar.assetType = p.Results.Name;
            ourCar.name = p.Results.Name;

            ourCar.velocity = [0 0 0]; % set separately
            %ourCar.hasCamera = true; % if ego vehicle
            % Now we need to place the vehicle in the ISET scene
            ourCar.place(scenario);

            %% If we are the egoVehicle, need to move the camera
            % to us on the ISETAuto side. Without more editing of
            % the DSD function, that is a bit of a guess. Assume the first
            % one?
            if isempty(egoVehicle)
                egoVehicle = ourCar;
                % car position is below the rear axle. sigh.
                cameraPosition = ourCar.position;
                % hack to get it out from under the car
                cameraPosition = cameraPosition + [-3 0 2];
                ourRecipe = scenario.roadData.recipe;
                ourRecipe.lookAt.from = cameraPosition;
            end
            % call with egoVehicle if we have the sensors?
            vehicleID = vehicle@drivingScenario(scenario, varargin{:});
        end

        % Non-vehicle actors (e.g. Pedestrians)
        % and presumably we can add deer and other animate objects
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
        % Need to check if we need obj + scenario, or if scenario is obj
        function actorID = actor(scenario, varargin)
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
            ourActor.position = p.Results.Position;
            ourActor.assetType = p.Results.Name;
            ourActor.name = p.Results.Name;

            ourActor.velocity = [0 0 0]; % set separately
            ourActor.place(scenario);
            actorID = actor@drivingScenario(scenario, varargin{:});

        end

        % Not sure if we need this or not?
        function trajectory(scenario, egoVehicle, waypoints, speed)
            trajectory@drivingScenario(scenario, egoVehicle, waypoints, speed);
        end

        function running = advance(scenario)
            
            persistent ourSimulationTime;

            % First we show where we are (were)
            piWrite(scenario.roadData.recipe);
            scene = piRender(scenario.roadData.recipe);
            sceneSet(scene, 'display mode', 'hdr');
            sceneWindow(scene);

            % Move our vehicle forward based on its velocity
            % e.g. both the egoVehicle & the lookAt from/to
            % Assume that egoVehicle is #1
            egoVelocity = scenario.Actors(1).Velocity;

            if isempty(ourSimulationTime)
                ourSimulationTime = scenario.SimulationTime;
                ourTimeStep = ourSimulationTime;
            else
                ourTimeStep = scenario.SimulationTime ...
                    - ourSimulationTime; % just a time step
            end
            % move our car by time step * velocity
            % initially just move camera:), after adjusting coordinates
            adjustedVelocity = egoVelocity .* [-1 -1 0];
            scenario.roadData.recipe.lookAt.from = ...
                scenario.roadData.recipe.lookAt.from + ...
                (adjustedVelocity .* ourTimeStep);

            % Then determine whether braking & subtract from Velocity
            % (We can't just subtract from speed, as it has been broken
            % into velocity components already based on waypoints
            % In this case we also need to modify the SDS version of
            % Velocity



            % run super-class method
            running = advance@drivingScenario(scenario);
        end
    end
end

