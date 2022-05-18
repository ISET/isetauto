function road = roadSet(road, param, val, varargin)
% Set a roadgen class value
%
% Syntax
%   roadSet(road, param, val, varargin)
%     Sets a road parameter.
%
% Description:
%   The roadgen class manages the PBRT rendering parameters.  The class
%   has many fields specifying camera and rendering parameters. This
%   method is only capable of setting one parameter at a time.
%
% Parameter list (in progress, many more to be added)
%
% Inputs
%   road - a roadgen object
%   param -
%   val -
%
% Optional key/val pairs
%
% Outputs
%   road - modified roadgen object
%
% See also
%


%%
if isequal(param,'help')
    doc('roadgen.recipeSet');
    return;
end

%% Parse
p = inputParser;
p.KeepUnmatched = true;

vFunc = @(x)(isequal(class(x),'roadgen'));
p.addRequired('road',vFunc);
p.addRequired('param',@ischar);
p.addRequired('val');

p.parse(road, param, val);
param = ieParamFormat(p.Results.param);

%% Act

switch param
    case 'scenename'
        road.sceneName = val;

    case 'onroadcarnames'
        road.onroad.car.namelist = val;
    case 'onroadcarlanes'
        road.onroad.car.lane   = val;
    case 'onroadncars'
        % Number of cars on each lane.  
        assert(numel(val) == numel(road.onroad.car.lane));
        road.onroad.car.number = val;

    case 'onroadanimalnames'
        road.onroad.animal.namelist = val;
    case 'onroadnanimals'
        road.onroad.animal.number= val;
    case 'onroadanimallane'
        road.onroad.animal.lane  = val;

    case 'offroadanimalnames'
        road.offroad.animal.namelist = val;
    case 'offroadnanimals'
        road.offroad.animal.number= val;
    case 'offroadanimallane'
        road.offroad.animal.lane  = val;

    case 'offroadanimalmindistance'
        % What are these units?   Meters?
        road.offroad.animal.minDistanceToRoad = val;
    case 'offroadanimallayerwidth'
        road.offroad.animal.layerWidth = val;

    case 'offroadtreenames'
        road.offroad.tree.namelist = val;
    case 'offroadntrees'
        road.offroad.tree.number= val;
    case 'offroadtreelane'
        road.offroad.tree.lane  = val;

    otherwise
        error('Param %s not found',param);
end
