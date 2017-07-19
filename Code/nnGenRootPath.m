function [ codePath, parentPath ] = nnGenRootPath()

rootPath = which('nnGenRootPath');
codePath = fileparts(rootPath);

id = strfind(codePath,'/');
parentPath = rootPath(1:(id(end)-1));

end

