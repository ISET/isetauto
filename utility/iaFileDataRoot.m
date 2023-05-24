function dataRoot = iaFileDataRoot(varargin)
%IADATAROOT Get root of our Data Files
%   This is where we look for data that is too large to fit in our
%   repo. Typically it will be on a network file server, although
%   for performance cloning it and setting your pref to use the cloned
%   version is certainly possible.


p = inputParser();
addParameter(p, 'local', false); % Use a local cache for performance
addParameter(p, 'type', 'filedata');

% convert our args to ieStandard and parse
varargin = ieParamFormat(varargin);
p.parse(varargin{:});


dataRoot = getpref('isetauto', 'filedataroot', '');

% These are a bit of a guess, but based on acorn fs
if isempty(dataRoot)
    if ispc
        % Arbitrary mount points
        if p.Results.local == true
            dataDrive = 'v:';
        else
            % so far is D on desktop G on laptop
            % don't know if there is a UNC path
            dataDrive = 'D:\My Drive\Vistalab';
        end
        dataRoot = fullfile(dataDrive, 'data','iset','isetauto');
    else
        dataRoot = fullfile(filesep, 'acorn','data','iset','isetauto');
    end
end

% Check if user wants a sub-folder
switch (p.Results.type)
    case 'PBRT_assets'
        dataRoot = fullfile(dataRoot, 'PBRT_assets');
end
