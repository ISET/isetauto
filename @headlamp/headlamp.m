classdef headlamp < handle
    %HEADLAMP Specialized class of light
    %   for simulating vehicle headlamps (aka headlights)

    % We model them using projection lights.
    % That gives us an RGB "mask" image that is projected onto the FOV of the
    % light. The class generates those as needed.
    % If they are preset maps, we keep them in /Resources/skymaps.
    % If they are generated at runtime they use <recipe>/instanced/

    % Masks either have a simple cutoff angle and power multiplier below that
    % cutoff

    properties

        location = [0 0 0];
        orientation = [0 0 0];
        name;

        resolution = [320 640]; % assume wider than tall

        peakIntensity = 61500; % candelas at a nominal bright point

        % Having trouble seeing where light projects
        % so try cutting from 80/20 to 20/10
        horizontalFOV = 80; % apparently +/- 40 is fairly standard
        verticalFOV; % set in creation function
        power = 5; % for level beams with .8 mask, pretty good match

        % Calculated depending on the preset used
        lightMask;
        lightMaskFileName = ''; % where we put our mask for iset/pbrt to use
        isetLight; % ISET light object created by call

        % internal
        ourRecipe = [];

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
            p.addParameter('location', [0 0 0]); % can be a preset or a vector
            p.addParameter('verbose',true,@islogical);
            p.addParameter('name','Projected Headlight',@ischar);
            p.addParameter('recipe',[]);

            p.parse(varargin{:});

            obj.ourRecipe = p.Results.recipe;

            % Fix aspect ratio
            obj.verticalFOV = round(obj.horizontalFOV * (obj.resolution(1) / obj.resolution(2)));
            obj.name = p.Results.name;

            if ~isempty(p.Results.location)
                obj.location = p.Results.location;
            end
            % now we want to generate the light & mask
            switch p.Results.preset
                case 'low beam'
                    obj.lightMask = obj.maskImage(-.5, '');
                    obj.lightMaskFileName = 'headlamp_lowbeam.exr';
                    obj.power = 5;
                case 'level beam'

                    % Modify power based on distance
                    % as we need less power for closer objects
                    attenuation = obj.modelAttenuation(0);
                    obj.lightMask = obj.maskImage(0, '') .* attenuation;

                    obj.lightMaskFileName = 'headlamp_levelbeam.exr';
                    obj.power = 5;
                case 'high beam'
                    obj.lightMask = obj.maskImage(10, '');
                    obj.lightMaskFileName = 'headlamp_highbeam.exr';
                    obj.power = 9; % arbitrarily more
                case 'too low'
                    obj.lightMask = obj.maskImage(-17.5, '');
                    obj.lightMaskFileName = 'headlamp_toolow.exr';
                    obj.power = 5;
                case 'area' % start to see what we can do with area lights
                    % Start with same code as level-beam:
                    
                    % Modify power based on distance
                    % as we need less power for closer objects
                    attenuation = obj.modelAttenuation(0);
                    obj.lightMask = obj.maskImage(0, '') .* attenuation;

                    obj.lightMaskFileName = 'headlamp_levelbeam.exr';
                    obj.power = 5;
                otherwise
                    % default is lowbeam
                    obj.lightMask = obj.maskImage(-2, '');
                    obj.lightMaskFileName = 'headlamp_lowbeam.exr';
                    obj.power = 5;
            end

            obj.isetLight = obj.getLight(p.Results.preset);


        end

        %% Create the actual light
        function isetLight = getLight(obj, preset)

            % Begin to model what an area light looks like
            if isequal(preset, 'area')
                % Add the area lights
                numBulbs = 1; % how many area lights in our headlight
                lampBulbs = cell(1,numBulbs);

                % Triangular positions, a few millimeters off to the side of the
                % camera
                pos = [0 0 0;
                    0.100 0 0;
                    0.05 0.050 0];

                % If we have two area headlamps may have a name conflict
                for ii=1:numBulbs
                    lampBulbs{ii} = piLightCreate(sprintf('bulb-%d',ii),...
                        'type','area',...
                        'spd spectrum','D65.mat', ...
                        'cameracoordinate', true);
                    obj.ourRecipe.set('light',lampBulbs{ii},'add');
                    obj.ourRecipe.set('light',lampBulbs{ii},'rotate',[0 180 0]);
                    obj.ourRecipe.set('light',lampBulbs{ii},'shape scale',0.01);   
                    obj.ourRecipe.set('light',lampBulbs{ii},'spread',10);
                    obj.ourRecipe.set('light',lampBulbs{ii},'specscale',100); % Brighten it
                end
                isetLight = lampBulbs{1}; % for now we only use one
                return
            else
                % In addition we have an issue where the headlamp map
                % should be unique to each headlamp, but still needs
                % to wind up on the server when remote rendering
                % So we put it in <recipe>/instanced that allows the
                % creation and use of unique resource files per render

                % fullfile won't work on Windows, so use '/'
                headlampDir = 'instanced';
                fullMaskFileName = [headlampDir,'/',obj.lightMaskFileName];

                % -- industry spec is 5+ lux at 200 feet for low beam
                %    and 300 feet for high beams (+ they have a higher cutoff)

                % We don't know how to directly measure lux in ISET
                % So we have an option for driving scenarios to place
                % a mirrored sphere in the scene to help us estimate

                % power = 5,scale = 1 gives about 5 cd/m2 @ 60 meters
                % on a (ground level) asphalt road
                isetLight = piLightCreate(obj.name, ...
                    'type','projection',...
                    'scale',1,... % scales intensity
                    'fov',40, ...
                    'power', obj.power, ...
                    'cameracoordinate', 1, ...
                    'filename string', fullMaskFileName);

                % NOTE: Let's see if we can move the light here
                %       and have it stick. Or maybe we need to do this
                %       differently, since we don't have the
                %       parent recipe here
                if ischar(obj.location)
                    switch (obj.location)
                        case 'left grille'
                        case 'right grille'
                    end
                else
                    % move per the location param
                end

                % this writes out our projected image
                % We need to write it to a subdir of our recipe
                if ~isfolder(fullfile(obj.ourRecipe.get('outputdir'),headlampDir))
                    mkdir(fullfile(obj.ourRecipe.get('outputdir'),headlampDir));
                end
                exrwrite(obj.lightMask, fullfile(obj.ourRecipe.get('outputdir'),fullMaskFileName));
            end
        end

        %% calculate how far up/down to move the cutoff for a specific
        % number of degrees (e.g. 2 below the horizon for USA)
        % NOTE: Once we can rotate lights, some of this can
        %       be achieved if the headlight is rotated down
        % NOTE: For high beams, we probably want degrees above the horizon
        function maskImage = maskImage(obj, degreesVertical, degreesHorizontal)
            % Start with how far off the horizon we need to be
            pixelOffset = sin(deg2rad(degreesVertical)) / sin(deg2rad(obj.verticalFOV/2)) ...
                * obj.resolution(1);

            % NOT implemented yet
            % for now try setting right headlamp to high beam instead
            % and also how far right/left:
            if ~isempty(degreesHorizontal)
                pixelOffsetHorizontal = sin(deg2rad(degreesHorizontal)) / sin(deg2rad(obj.horizontalFOV/2)) ...
                    * obj.resolution(1);
            else
                % not quite sure what to do here
                pixelOffsetHorizontal = 20;
            end

            % Baseline mask: begin with all 1's
            maskImage = ones (obj.resolution(1), obj.resolution(2), 3);

            % we need to deal with degreesHorizontal for "sidewalk"
            % lighting. The combination of the two is essentially an "OR"
            % as we want light provided either below degreesVertical
            % or to the (right) of degreesHorizontal
            % Now calculate our horizontal cutoff -- degreesVertical
            darkCols = round((obj.resolution(2) / 2) - pixelOffsetHorizontal);
            litCols = obj.resolution(2) - darkCols;

            gradientMaskLeft = zeros(darkCols, obj.resolution(1));
            gradientMaskRight = ones(litCols, obj.resolution(1));

            % Now calculate our horizontal cutoff -- degreesVertical
            darkRows = round((obj.resolution(1) / 2) - pixelOffset);
            litRows = obj.resolution(1) - darkRows;

            gradientMaskTop = zeros(darkRows, obj.resolution(2));
            gradientMaskBottom = ones(litRows, obj.resolution(2));

            gradientMaskBottom = gradientMaskBottom .* .8; % super simple

            gradientMaskVertical = [gradientMaskTop; gradientMaskBottom];
            gradientMaskHorizontal = [gradientMaskLeft; gradientMaskRight];

            if ~isempty(degreesHorizontal)
                gradientMask = max(gradientMaskVertical, gradientMaskHorizontal);
            else
                gradientMask = [gradientMaskTop; gradientMaskBottom];
            end

            maskImage = maskImage .* gradientMask;

        end

        %% Initial attempt to model lower luminance for lower angles
        function attenuationMask = modelAttenuation(obj, degrees)
            % To provide a consistent level of light at the range of
            % distances covered by the headlights requires less power
            % when illuminating closer objects.
            %

            % We have a table someone thoughtfully calculated for this:
            genericHeadlampAttenuation = readtable(fullfile("@headlamp","Generic Headlamp Light Distribution.csv"));

            % We know (think) that the top and bottom of the projected
            % light correspond to the boundaries of the FOV
            degreesPerPixel = obj.verticalFOV / obj.resolution(1);

            % Table assumes -1 as hotspot, but that's not always true
            degreeOffset = -1 - degrees(1); % vertical

            % We could just use a linear model but realistically, all
            % rows don't have the same degree delta

            % Start to look at interpolation
            deg = abs(genericHeadlampAttenuation.VerticalAngle) + ...
                degreeOffset;
            candelaValues = genericHeadlampAttenuation.RequiredCandela;
            smoothedCandelaValues = spline(deg, candelaValues, ...
                0:degreesPerPixel:(obj.resolution(1)/2*degreesPerPixel));

            % Now we have the needed candelas, but we want to normalize
            % to 0:1 since we are an attenuation mask.
            attenuationVals = smoothedCandelaValues./genericHeadlampAttenuation.RequiredCandela(1);

            % This is a little granular since we only have 17 steps in our
            % headlamp table, so we need to spline/smooth again
            smoothedAttenuationVals = spline(0:obj.resolution(1)/2, attenuationVals, ...
                1:numel(attenuationVals));

            % This still shows as a bit "piecewise." Either need to find a
            % better smoothing/curve system, or give up and just use trig

            % Then we need to take our attenuation values and replicate
            % them across the columns of a new mask
            attenuationArray = repmat(smoothedAttenuationVals, obj.resolution(2), 1);
            attenuationArray = transpose(attenuationArray);
            % At this point we need to align our attenuationArray with
            % the mask and then do a dot product.

            % begin with all 1's, then fill in lower half
            attenuationMask = ones (obj.resolution(1), obj.resolution(2), 3);
            startRow = obj.resolution(1) - size(attenuationArray,1) + 1;

            % assume we want to attenuate RGB equally
            attenuationMask(startRow:obj.resolution(1),:,1) = attenuationArray;
            attenuationMask(startRow:obj.resolution(1),:,2) = attenuationArray;
            attenuationMask(startRow:obj.resolution(1),:,3) = attenuationArray;

            % NOTE:
            % we could also simply use the cosd() of the implied angle
            % for each row of the mask below either the beam cutoff
            % angle or the cutoff angle + some "hot spot" allowance.


        end

    end

end
