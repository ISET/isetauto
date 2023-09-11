classdef headlamp < handle
    %HEADLAMP Specialized class of light
    %   for simulating vehicle headlamps (aka headlights)
    
    properties
        % for now we assume the headlamp can be approximated
        % using a point source with a single angle.
        % That isn't technically true for modern multi-source lamps.

        % Currently AssetRotate & AssetTranslate don't work with lights
        % So we are stuck with camera location & fromto angle
        location = [0 0 0];
        orientation = [0 0 0];

        resolution = [128 256]; % assume wider than tall 

        peakIntensity = 61500; % candelas at a nominal bright point

        horizontalFOV = 80; % apparently +/- 40 is fairly standard
        verticalFOV = 40; % set in creation function
        cutOffAngle = -2; % default for below horizon

        GenericData = readtable(fullfile("@headlamp","Generic Headlamp Light Distribution.csv"));

        % Calculated depending on the preset used
        lightMask;
        lightMaskFileName = ''; % where we put our mask for iset/pbrt to use
        isetLight; % ISET light object created by call
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
        function obj = headlamp(varargin)

            varargin = ieParamFormat(varargin);
            p = inputParser;

            p.addParameter('preset','',@ischar);
            p.addParameter('verbose',true,@islogical);
            
            p.parse(varargin{:});

            % Fix aspect ratio
            obj.verticalFOV = obj.horizontalFOV * (obj.resolution(1) \ obj.resolution(2));

            % now we want to generate the light & mask
            switch p.Results.preset
                case 'low beam'
                    obj.lightMask = obj.maskImage(-2);
                    obj.lightMaskFileName = 'headlamp_lowbeam.exr';
                case 'high beam'
                    obj.lightMask = obj.maskImage(10);
                    obj.lightMaskFileName = 'headlamp_highbeam.exr';
                case 'too low'
                    obj.lightMask = obj.maskImage(-17.5);
                    obj.lightMaskFileName = 'headlamp_toolow.exr';
                otherwise
                    % default is lowbeam
                    obj.lightMask = obj.maskImage(-2);
                    obj.lightMaskFileName = 'headlamp_lowbeam.exr';
            end

            obj.isetLight = obj.getLight();


        end
     
        %% Create the actual light
        function isetLight = getLight(obj)

            % We need to put the maskImageFile into the recipe/skymaps
            % folder here or elsewhere to make sure it is rsynced

            % In addition we have an issue where the headlamp map
            % should be unique to each headlamp, but still needs
            % to wind up on the server when remote rendering

            % fullfile won't work on Windows, so use '/'
            fullMaskFileName = ['skymaps','/',obj.lightMaskFileName];

            % Can we try to set a position???
            % Otherwise we seem stuck with camera pose

            % don't have units on light intensity yet
            isetLight = piLightCreate('ProjectedLight', ...
                    'type','projection',...
                    'scale',1,... % scales intensity
                    'fov',30, ...
                    'power', 15, ...
                    'cameracoordinate', 1, ...
                    'filename string', fullMaskFileName);

            % this writes out our projected image
            exrwrite(obj.lightMask, fullfile(piDirGet('data'),fullMaskFileName));

        end

        %% calculate how far up/down to move the cutoff for a specific
        % number of degrees (e.g. 2 below the horizon for USA)
        % NOTE: Once we can rotate lights, some of this can
        %       be achieved if the headlight is rotated down
        % NOTE: For high beams, we probably want degrees above the horizon
        function maskImage = maskImage(obj, degrees)
            % Start with how far off the horizon we need to be
            pixelOffset = sin(deg2rad(degrees)) / sin(deg2rad(obj.verticalFOV/2)) ...
                * obj.resolution(1);

            % Now calculate our horizontal cutoff
            darkRows = round((obj.resolution(1) / 2) - pixelOffset);
            litRows = obj.resolution(1) - darkRows;

            % try to make a simple image that goes from 1 to 0,
            % starting halfway down

            % begin with all 1's, then multiply
            maskImage = ones (obj.resolution(1), obj.resolution(2), 3);

            gradientMaskTop = zeros(darkRows, obj.resolution(2));
            gradientMaskBottom = ones(litRows, obj.resolution(2));

            gradientMaskBottom = gradientMaskBottom .* .8; % super simple

            gradientMask = [gradientMaskTop; gradientMaskBottom];

            maskImage = maskImage .* gradientMask;

        end
    end
end

