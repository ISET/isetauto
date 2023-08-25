classdef headlamp < handle
    %HEADLAMP Specialized class of light
    %   for simulating vehicle headlamps (aka headlights)
    
    properties
        % for now we assume the headlamp can be approximated
        % using a point source with a single angle.
        % That isn't technically true for modern multi-source lamps.
        angles = [0 0 0];

        peakIntensity = 61500; % candelas at a nominal bright point

        horizontalFOV = 80; % apparently +/- 40 is fairly standard


    end

    %% Equations:
    %{
        Amount of light on an illuminated surface
        Lux = Candela/meter^2
        Candela = meter^2 * Lux

        NOTE: Vertical is angle from beam center, not from ground
        groundDistance = height / -1 * tan(angle['vertical'])
        hypotenuseDistance = height / -1 * sin(angle['vertical')

        Chart here: https://blog.betterautomotivelighting.com/high-quality-low-beam-distribution
        to map beam intensity spread. Still working it out.
        It definitely shows light intensity falloff based on beam angle.
        Which then needs to be divided by the surface area.

        An optimized light distribution is in:
        Generic Headlamp Light Distribution

        In theory we can use that to generate a "mask"
        
    %}
    
    methods
        function obj = headlamp(inputArg1,inputArg2)
            %HEADLAMP Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

