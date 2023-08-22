function resourceDir = iaDirGet(resourceType)
% Returns default directory of a resource type.
%
% Synopsis
%   resourceDir = iaDirGet(resourceType)
%
% Input
%   resourceType - One of
%     {'data','assets', 'scenes','local'}
%
% Output
%   resourceDir
%
% Description:
%   Most of these resources are in directories within isetauto.
%
%
% D.Cardinal -- Stanford University -- May, 2023
% See also
%

% Example:
%{
  iaDirGet('assets')
%}

%% Parse
valid = {'data','assets', 'asset', ...
    'scenes','scene','local'};

if isequal(resourceType,'help')
    disp(valid);
    return;
end

if isempty(resourceType) || ~ischar(resourceType) || ~ismember(resourceType,valid)
    fprintf('Valid resources are\n\n');
    disp(valid);
    error("%s is not a valid resource type",resourceType);
end

%% Set these resource directories once, here, in case we ever need to change them

ourRoot = iaRootPath();
ourData = fullfile(ourRoot,'data');

% Now we can locate specific types of resources
switch (resourceType)
    case 'data'
        resourceDir = ourData;
    case {'assets','asset'}
        resourceDir = fullfile(ourData,'assets');
    case {'scenes','scene'}
        resourceDir = fullfile(ourData,'scenes');
    case 'local'
        resourceDir = fullfile(ourRoot,'local');
end


end
