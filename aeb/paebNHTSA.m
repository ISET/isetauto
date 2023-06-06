function actors = paebNHTSA(ourScene, testScenario, varargin)
%IA_PAEBNHTSA Load NHTSA test scenario into a recipe
% ?? Should there be a "meta-recipe" like we have for bio?
%   
% D. Cardinal, Stanford University, June, 2023

% Caller will want an Actors collection populated
actors = []; % Static assets simply live in the @recipe

% There are "base" scenarios that are run with different speeds
% and different lighting. We can probably make those either
% varargs or properties

% lightLevel; % .2 lux or daylight
% vehicleSpeed; % 10-60 kph
% pedestrianSpeed; % 5-8 kph
% pedestrianVariant; % man or child

varargin = ieParamFormat(varargin);
p = inputParser;

p.addRequired('ourscene', @(x)isequal(class(x),'roadgen'));
p.addRequired('testscenario', @ischar);

% Settings used by all NHTSA PAEB test cases
p.addParameter('carspeed',17); % m/s, 17 == 60kph
p.addParameter('lighting','nighttime'); % or daytime
p.addParameter('mannequin', 'man'); % or child
p.addParameter('testdurationinitial', 4); % seconds to target without brakes
p.addParameter('overlap', .25); % how far pedestrian is timed to cross car

%% Additional settings
p.addParameter('cartype', 'car_004'); % Shelby
p.addParameter('carname', 'Shelby'); 

%% Additional complicating factors
% Here is where we would place additional vehicles or obstacles

p.parse(ourScene, testScenario, varargin{:});

% This is our test vehicle
ourScene = p.Results.ourscene; % the overall roadScene
carSpeed = p.Results.carspeed;
testDuration = p.Results.testdurationinitial;
targetDistance = testDuration * carSpeed; % tests start 4 seconds away

ourCar = actor();
ourCar.position = [0 0 0]; % e.g. uss
ourCar.rotation = [0 0 180]; % facing forward
ourCar.assetType = p.Results.cartype;
ourCar.name = p.Results.carname;

ourCar.velocity = [carSpeed 0 0]; % moving forward at 10 m/s
ourCar.hasCamera = true; % move camera with us
ourCar.place(ourScene.recipe);

% Add our car to the actors in our scenario and set as target vehicle
ourScene.targetVehicleNumber = numel(ourScene.actors) + 1;
ourScene.actors{end+1} = ourCar;

switch testScenario
    case 'pedRoadsideRight' % stationary at .25 across car

    case 'pedRoadsideLeft'
    
    case 'pedBehindCars'
    % etc
end

