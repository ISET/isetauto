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

switch (p.Results.type)
    case 'filedata'
        dataRoot = getpref('isetauto', 'filedataroot', '');

        % These are a bit of a guess, but based on acorn fs
        if isempty(dataRoot)
            if ispc
                if p.Results.local == true
                    dataRoot = 'v:\data\iset\isetauto';
                else
                    dataRoot = 'y:\data\iset\isetauto';
                end
            else
                dataRoot = '/acorn/data/iset/isetauto';
            end
        end
    case 'PBRT_assets'
        dataRoot = '/acorn/data/iset/isetauto/PBRT_assets';
end
