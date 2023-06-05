function actors = ia_paebNHTSA(recipe, testScenario)
%IA_PAEBNHTSA Load NHTSA test scenario into a recipe
% ?? Should there be a "meta-recipe" like we have for bio?
%   
% D. Cardinal, Stanford University, June, 2023

% Caller will want an Actors collection populated
actors = []; % Static assets simply live in the @recipe

switch testScenario
    case 'pedRoadsideRight'
    case 'pedRoadsideLeft'
    case 'pedBehindCars'
    % etc
end

