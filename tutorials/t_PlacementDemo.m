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
thisR = roadData.recipe;

%% We want to write out the final recipe in local for rendering by PBRT
% Our convention is <iaRootDir>/local/<scenename>/<scenename.pbrt>
% even though road scenes in /data are have two levels of nesting
thisR.set('outputfile',fullfile(piDirGet('local'),num2str(iaImageID),[num2str(iaImageID),'.pbrt']));

%% Set up the rendering skymap -- this is just one of many available
skymapName = 'sky-noon_009.exr'; % Most skymaps are in the Matlab path already
thisR.set('skymap',skymapName);

% Since we are starting with daytime, dim the Sun to simulate a night scene
% by finding it''s node in our asset tree and setting its spectrum scale
%skymapNode = strrep(skymapName, '.exr','_L');
%thisR.set('light',skymapNode, 'specscale', 0.001);

%% Now we can assemble the scene using ISET3d methods
assemble_tic = tic(); % to time scene assembly
roadData.assemble();
fprintf('---> Scene assembled in %.f seconds.\n',toc(assemble_tic));

% TBD: Add scene visualization
% sceneData.rrDraw('points',points, 'dir',dirs); % visualization function is to fix

%% Optionally specify a lens for our camera
% lensfile  = 'wide.40deg.6.0mm.json';    % 30 38 18 10
% fprintf('Using lens: %s\n',lensfile);

% We can randomly pick a car, and place the camera on it.  
% These are the types of cameras so far:
%
%   'front', 'back', 'left, 'right'
camera_type = 'front';

%% For this demo we'll actually set our camera to be on an F150
%  later in the script, so we don't set camera properties here
% branchID = roadData.cameraSet('camera type', camera_type); 
% direction = thisR.get('object direction');
% thisR.set('object distance', 0.95);

%% Set the recipe parameters
%  We want to render both the scene radiance and a depth map
thisR.set('film render type',{'radiance','depth'});

% Set the render quality parameters
% For publication 1080p by as many as 4096 rays per pixel are used
thisR.set('film resolution',[1920 1080]/1.5); % Divide by 4 for speed
thisR.set('pixel samples',128);            % 256 for speed
thisR.set('max depth',5);                  % Number of bounces
thisR.set('sampler subtype','pmj02bn');    
thisR.set('fov',45);                       % Field of View

%% For camera placement simulation we want a specific model of car
%  so that we know the actual dimensions

% In this case we look for a Ford F150 (car_058) in the scene
% NOTE: If there is no F150, you may need to generate a new scene
%branchID = roadData.cameraSet('camera type', camera_type,...
%                                'car name','car_058'); 

%% Render the scene, and maybe an OI (Optical Image through the lens)
% thisR.set('object distance', 0.95);
scene = piWRS(thisR,'render flag','hdr');
% piWrite(thisR);
% scene = piRender(thisR);
% sceneWindow(scene);

%% Process the scene through a sensor to the ip 
%
% This isn't great because the sensor is not explicit.
ip = piRadiance2RGB(scene,'etime',1/30,'analoggain',1/5);

rgb = ipGet(ip, 'srgb');
ieNewGraphWin;
imshow(rgb);

