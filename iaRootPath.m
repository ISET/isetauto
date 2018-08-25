function rootPath=iaRootPath()
% Return the path to the root iset directory
%
% This function must reside in the directory at the base of the
% ISETAUTO directory structure.  It is used to determine the location
% of various sub-directories.
% 

rootPath=which('iaRootPath');

[rootPath,fName,ext]=fileparts(rootPath);

return
