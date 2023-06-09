classdef ia_drivingScenario < drivingScenario
    %IA_DRIVINGSCENARIO our custom version of a driving scenario

    % D. Cardinal, Stanford University, June, 2023

    properties
    end

    methods
        function ds = ia_drivingScenario(varargin)

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

        function road(obj, ~, varargin)
            p = inputParser;
            p.addParameter('Name','road_020', @ischar);

            % LOAD ROAD SCENE OR AT LEAST SET PARAMETER

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
        function vehicle(obj, scenario, varargin)
            p = inputParser;
            p.addParameter('Name','car_004', @ischar);

            % ADD VEHICLE OR AT LEAST SET PARAMETER
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
            p.addParameter('Name','pedestrian_001', @ischar);

            % ADD NON_VEHICLE ASSET OR AT LEAST SET PARAMETER
        end
    end
end

