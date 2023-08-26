classdef headlamp < handle
    %HEADLAMP Specialized class of light
    %   for simulating vehicle headlamps (aka headlights)
    
    properties
        % for now we assume the headlamp can be approximated
        % using a point source with a single angle.
        % That isn't technically true for modern multi-source lamps.
        angles = [0 0 0];
        resolution = [128 256]; % assume wider than tall 

        peakIntensity = 61500; % candelas at a nominal bright point

        horizontalFOV = 80; % apparently +/- 40 is fairly standard

        GenericData = readtable(fullfile("@headlamp","Generic Headlamp Light Distribution.csv"));

        % Calculated
        maskImage = [];
        mask = []; % for debugging

        % temporary variables
        maskGradientX = [];
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
        function obj = headlamp()

            % try to make a simle image that goes from 1 to 0,
            % starting halfway down

            % begin with all 1's, then multiply
            obj.maskImage = ones (obj.resolution(1), obj.resolution(2), 3);

            gradientMaskTop = zeros(obj.resolution(1)/2, obj.resolution(2), 3);

            verticalGradient = 1:-1/(obj.resolution(1)/2):0;

            % How do we make the vertical gradient appear!
            gradientMaskBottom = [obj.resolution(1)/2, obj.resolution(2), 3];

            gradientMaskBottom(:, :, :) = (verticalGradient; : , :);

            gradientMask = [gradientMaskTop; gradientMaskBottom];

            obj.maskImage = obj.maskImage .* gradientMask;
            %Now need to add mask to bottom half of mask image

        end
     
    end
end

