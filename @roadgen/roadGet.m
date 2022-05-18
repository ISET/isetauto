function val = roadGet(road, param, varargin)
% Derive parameters from the recipe class
%
% Syntax:
%     val = roadGet(thisR, param, ...)
%
% Inputs:
%     thisR - a roadgen object
%     param - a parameter (string)
%
% Returns
%     val - Stored or derived parameter from the recipe
%


if isequal(param,'help')
    doc('roadgen.roadGet');
    return;
end

p = inputParser;
vFunc = @(x)(isequal(class(x),'roadgen'));
p.addRequired('road',vFunc);
p.addRequired('param',@ischar);

p.parse(road,param);

val = [];

%%

switch ieParamFormat(param)  % lower case, no spaces
    case 'scenename'
        val = road.sceneName;
    otherwise
        disp('NYI')
end

end
