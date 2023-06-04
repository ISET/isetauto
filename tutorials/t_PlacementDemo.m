%% Show how to manually place cars & subjects in a road scene
% 
% Dependencies
%   ISET3d, ISETAuto, ISETonline, and ISETCam
%   Prefix:  ia- means isetauto
%            pi- means iset3d-v4
%
%   ISET3d: Takes a PBRT file, parses 3D information including lights,
%   materials, textures and meshes. Modify the properties and render it.
%
%   ISETAuto: Assembles an ISET3d OBJECT into a complex driving scene.
%
%   ISETCam: Converts scene radiance or optical irradiance data to an RGB
%   image with a physically based sensor model and ISP pipeline. The 
%   resulting image is then rendered as an sRGB approximation.
%
%   ISETOnline:  Looks up the road data using the database.
%
%   Extended to use Zhenyi's Flare code
%
% D. Cardinal, Stanford, 2023

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% (Optional) isetdb() setup
% setup stanford server (n.b. ideally in user startup file)
setpref('db','server','acorn.stanford.edu'); 
setpref('db','port',49153);

% Opens a connection to the server
sceneDB = isetdb();

%% Find the road starter scene/asset and load it
% If fullpath to the asset is not given, we will find it in our database
% We have quite a few generated roads. Currently they are usually 400m long
road_name  = 'road_020';

% Create the road data object that we will populate with vehicles
% and other objects for eventual assembly into our scene
% We can find it either in our path, or the sceneDB
roadData = roadgen('road directory',road_name, 'asset directory', sceneDB);

% Create driving lane(s) for both directions
roadData.set('onroad car lanes',{'leftdriving','rightdriving'});


%% Place the offroad elements.  These are only animals and trees.  Not cars.
% In this demo we only use 3 types of trees from our library
% We will allow automatic placement of these, to save time
roadData.set('offroad tree names', {'tree_001','tree_002','tree_003'});
roadData.set('offroad n trees', [50, 1, 1]); % [50, 100, 150]
roadData.set('offroad tree lane', {'rightshoulder','leftshoulder'});

% the roadData object comes with a base ISET3d recipe for rendering
roadRecipe = roadData.recipe;

%% We want to write out the final recipe in local for rendering by PBRT
% Our convention is <iaRootDir>/local/<scenename>/<scenename.pbrt>
% even though road scenes in /data have two levels of nesting

sceneName = 'PlacementDemo'; %num2str(iaImageID); % random scene id, or we can give it a name
roadRecipe.set('outputfile',fullfile(piDirGet('local'),sceneName,[sceneName,'.pbrt']));

%% Set up the rendering skymap -- this is just one of many available
skymapName = 'sky-noon_009.exr'; % Most skymaps are in the Matlab path already
roadRecipe.set('skymap',skymapName);

% If we want to make the scene a night time scene
skymapNode = strrep(skymapName, '.exr','_L');
roadRecipe.set('light',skymapNode, 'specscale', 0.001);

%% Place the elements that are on the road (onroad)
% For this demo we add cars, animals, and people manually
% For the cars so far, z appears to be up, y is L/R, x is towards us

% iaAssetPlacement is relative to the car
% For x and y, and relative to the ground for z

% Start with an F150 for the camera (car type 058)
% Not sure how to place it + the camera correctly
roadRecipe = iaPlaceAsset(roadRecipe, 'car_058', [0 0 0], [0 0 180]);

% Add a car coming towards us
iaPlaceAsset(roadRecipe, 'car_001', [15 -8 0], []);

% Add a car ahead of us in our lane
oncoming = false;
if oncoming
    roadRecipe = iaPlaceAsset(roadRecipe,'car_002',[20 0 0], [0 0 0]);
else
    roadRecipe = iaPlaceAsset(roadRecipe,'car_002',[20 0 0], [0 0 180]);
end

% Add another care coming our way, but farther away
roadRecipe = iaPlaceAsset(roadRecipe, 'car_003', [18 -12 0], [0 0 0]);

% Add a deer in front of our car
roadRecipe = iaPlaceAsset(roadRecipe, 'deer_001', [10 -1 0], [0 0 90]);

% Add a pedestrian coming across to our side of the road
% At 90 rotation he is walking down the centerline towards us
roadRecipe = iaPlaceAsset(roadRecipe, 'pedestrian_001', [8 -5 0], [0 0 180]);

%% Now we can assemble the scene using ISET3d methods
assemble_tic = tic(); % to time scene assembly
roadData.assemble();
fprintf('---> Scene assembled in %.f seconds.\n',toc(assemble_tic));

%% Set the recipe parameters
%  We want to render both the scene radiance and a depth map
roadRecipe.set('film render type',{'radiance','depth'});

% Set the render quality parameters, use 'quick' preset for demo
roadRecipe = iaQualitySet(roadRecipe, 'preset', 'quick');
roadRecipe.set('fov',45);                       % Field of View

% Put the camera on the F150
camera_type = 'front'; % Or Grille
switch camera_type
    case 'front' % which means behind the mirrof -- IPMA in Ford speak
        cameraHeightF150 = 1.8; % Mirror meters above ground
        cameraOffsetF150 = .9; % meters offset towards rear of truck
    case 'grille'
        cameraHeightF150 = .9; % Grille 
        cameraOffsetF150 = -1.9; % meters offset towards rear of truck
end

% Tweak position. Not elegant at all currently
roadRecipe.lookAt.from = [roadRecipe.lookAt.from(1) + cameraOffsetF150 ...
    roadRecipe.lookAt.from(2) cameraHeightF150];
roadRecipe.lookAt.to = [0 roadRecipe.lookAt.from(2) cameraHeightF150];

%% Render the scene, and maybe an OI (Optical Image through the lens)
scene = piWRS(roadRecipe,'render flag','hdr');

%% Add Flare if desired
% flare parameters are borrowed from other code, may not be ideal
sceneSampleSize = sceneGet(scene,'sample size','m');
[flareOI,pupilmask, psf] = piFlareApply(scene,...
                    'psf sample spacing', sceneSampleSize, ...
                    'numsidesaperture', 10, ...
                    'fnumber',5, 'dirtylevel',0);

% These parameters yield a good result, but can't be right
flareIP = piRadiance2RGB(flareOI,'etime',1/6000,'sensor', 'MT9V024SensorRGB.mat',...
            'analoggain', 1/5);

%% Process the (non-flare) scene through a sensor to the ip 
%
% This isn't great because the sensor is not explicit.
ip = piRadiance2RGB(scene,'etime',1/30,'sensor','MT9V024SensorRGB');

% In case we want to check
%oiWindow(flareOI);

rgb = ipGet(ip, 'srgb');
ieNewGraphWin;
imshow(rgb);
title("Rendered Image -- No flare");

flareRGB = ipGet(flareIP, 'srgb');
ieNewGraphWin;
imshow(flareRGB);
title("Rendered Image -- With flare");

