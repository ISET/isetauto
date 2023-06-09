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

            % Should we do the ieInit/dockerInit here??

            % Let the Matlab driving scenario set things up first
            % ds now contains a "blank slate" scenario
            try
                %parseInputs(ds, varargin{:});
            catch ME
                throwAsCaller(ME);
            end
        end

        % We only use the road to tell us which of our road scenes
        % to load (based on the road namd
        % Here is the default call:
        % road(scenario, roadCenters, 'Heading', headings, 'Lanes', laneSpecification, 'Name', 'road_020');

        function road(obj, scenario, varargin)
            p = inputParser;
            p.addParameter('Name', 'road_020');
            p.KeepUnmatched = true; % we don't parse all args here
            p.parse(varargin{:});

            roadName = p.Results.Name; 
            % LOAD ROAD DATA/SCENE into ISETAuto
            % We need to specify lighting
            obj.roadData = obj.initRoadScene(roadName, 'nighttime');
            road@drivingScenario(obj, scenario, varargin{:});
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
        function egoVehicle = vehicle(scenario, varargin)
            p = inputParser;
            p.addParameter('ClassID',1); % don't know if we need this
            p.addParameter('Name','car_004', @ischar);
            p.addParameter('Position', [0 0 0]);
            p.KeepUnmatched = true;
            p.parse(varargin{:});

            % Doesn't seem to get l,w,h ??
            % speed and trajectory are set in separate calls!
            
            % Add Vehicle asset to our @Recipe
            ourCar = actor();
            ourCar.position = p.Results.Position;
            % what about pitch, roll, yaw?
            %ourCar.rotation = [0 0 180]; % facing forward
            ourCar.assetType = p.Results.Name;
            ourCar.name = p.Results.Name;

            ourCar.velocity = [0 0 0]; % set separately
            ourCar.hasCamera = true; % if ego vehicle
            ourCar.place(scenario.roadData.recipe);

            % call with egoVehicle if we have the sensors?
            egoVehicle = vehicle@drivingScenario(scenario, varargin{:});
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
        function actor(obj, scenario, varargin)
            p = inputParser;
            p.addParameter('ClassID',4); % don't know if we need this
            p.addParameter('Name','pedestrian_001', @ischar);
            p.addParameter('Position', [0 0 0]);
            p.addParameter('Length', .24);
            p.addParameter('Height', 1.7);
            p.addParameter('Width', .45);

            % ADD NON_VEHICLE ASSET OR AT LEAST SET PARAMETER
        end

        function trajectory(obj, egoVehicle, waypoints, speed);
        end
    end
end

