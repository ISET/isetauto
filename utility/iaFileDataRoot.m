function dataRoot = iaFileDataRoot()
%IADATAROOT Get root of our Data Files
%   This is where we look for data that is too large to fit in our
%   repo. Typically it will be on a network file server, although
%   for performance cloning it and setting your pref to use the cloned
%   version is certainly possible.

dataRoot = getpref('isetauto', 'filedataroot', '');

% These are a bit of a guess, but based on acorn fs
if isempty(dataRoot)
    if ispc
        dataRoot = "y:\data\iset\isetauto";
    else
        dataRoot = '/acorn/data/iset/isetauto';
    end
end

