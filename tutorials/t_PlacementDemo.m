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

% If fullpath to the asset is not given, we will find it in our database
% We have quite a few generated roads. Currently they are usually 400m long
road_name  = 'road_020';

% Create the road data object that we will populate with vehicles
% and other objects for eventual assembly into our scene
roadData = roadgen('road directory',road_name, 'asset directory', sceneDB);

%% First we place the elements that are on the road (onroad)

% The driving lane(s)
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
% even though road scenes in /data are have two levels of nesting
roadRecipe.set('outputfile',fullfile(piDirGet('local'),num2str(iaImageID),[num2str(iaImageID),'.pbrt']));

%% Set up the rendering skymap -- this is just one of many available
skymapName = 'sky-noon_009.exr'; % Most skymaps are in the Matlab path already
roadRecipe.set('skymap',skymapName);

%% Add cars, animals, and people manually
% For the cars so far, z appears to be up, y is L/R, x is towards the
% camera

% We're going to try to make iaAssetPlacement relative to the car
% For x and y, and relative to the ground for z

% Add a car coming towards us
iaPlaceAsset(roadRecipe, 'car_001', [15 -8 0], []);
% Old way was:
%car1 = piRead('car_001.pbrt');
%car1Branch = piAssetTranslate(car1, 'car_001_B', cameraLocation + [-35 -4 0]);
%thisR = piRecipeMerge(thisR, car1);

% Add a car ahead of us in our lane
roadRecipe = iaPlaceAsset(roadRecipe,'car_002',[20 0 0], [0 0 180]);

% Add another care coming our way, but farther away
roadRecipe = iaPlaceAsset(roadRecipe, 'car_003', [25 -12 0], [0 0 0]);

% Add a deer in front of our car
roadRecipe = iaPlaceAsset(roadRecipe, 'deer_001', [10 -1 0], [0 0 90]);

%% Now we can assemble the scene using ISET3d methods
assemble_tic = tic(); % to time scene assembly
roadData.assemble();
fprintf('---> Scene assembled in %.f seconds.\n',toc(assemble_tic));


%% Set the recipe parameters
%  We want to render both the scene radiance and a depth map
roadRecipe.set('film render type',{'radiance','depth'});

% Set the render quality parameters
% For publication 1080p by as many as 4096 rays per pixel are used
roadRecipe.set('film resolution',[1920 1080]/1.5); % Divide by 4 for speed
roadRecipe.set('pixel samples',128);            % 256 for speed
roadRecipe.set('max depth',5);                  % Number of bounces
roadRecipe.set('sampler subtype','pmj02bn');    
roadRecipe.set('fov',45);                       % Field of View

%% Render the scene, and maybe an OI (Optical Image through the lens)
scene = piWRS(roadRecipe,'render flag','hdr');

%% Process the scene through a sensor to the ip 
%
% This isn't great because the sensor is not explicit.
ip = piRadiance2RGB(scene,'etime',1/30,'analoggain',1/5);

rgb = ipGet(ip, 'srgb');
ieNewGraphWin;
imshow(rgb);

