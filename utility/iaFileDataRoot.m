function dataRoot = iaFileDataRoot(varargin)
%IADATAROOT Get root of our Data Files
%   This is where we look for data that is too large to fit in our
%   repo. Typically it will be on a network file server, although
%   for performance cloning it and setting your pref to use the cloned
%   version is certainly possible.

p = inputParser();
addParameter(p, 'local', false); % Use a local cache for performance

% convert our args to ieStandard and parse
varargin = ieParamFormat(varargin);
p.parse(varargin{:});

% For custom locations set this preference:
if ~isempty(getpref('isetauto','dataDrive',''))        
    dataRoot = getpref('isetauto', 'filedataroot', '');
elseif ispc
    % Arbitrary mount points
    if p.Results.local == true
        dataDrive = 'v:';
    else
        dataRoot = '/acorn/data/iset/isetauto';
    end
elseif ismac
    dataDrive = '/volumes/acorn.stanford.edu';
else
    dataDrive = '/acorn';
end

switch (p.Results.type)
    case 'filedata'
        dataRoot = fullfile(dataDrive, 'data','iset','isetauto');
    case 'PBRT_assets'
        dataRoot = fullfile(dataDrive, 'data', 'iset','isetauto', 'PBRT_assets');
end
