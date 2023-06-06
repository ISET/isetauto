function actors = paebNHTSA(recipe, testScenario)
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

switch testScenario.testName
    case 'pedRoadsideRight'
    case 'pedRoadsideLeft'
    case 'pedBehindCars'
    % etc
end

