function [ classMap, instanceMap ] = mergeMetadata( fileName, labelMap, varargin )

% [ classMap, instanceMap ] = mergeMetadata( fileName, labelMap, ... )
%
% This function accepts a path to a .dat file that represents the output
% from a 'mesh' or 'material' metadata PBRT renderer. It outputs a
% simplified map with fewer meshes or materials than in the original file.
% The classes are groupped accoridng the field 'class' in labelMap. For example if
% labelMap(1).class = 'car' and labelMap(2).class = 'city', then all class 
% names contaning the substring 'car' will be assigned one class and all 
% class names containing the substring 'city' the other. 
%
% The function returns a classMap, where each pixel is labeled according to
% the class it belongs to, and an instanceMap, where each pixel represents
% object instance it belongs to. These two are necessary to automatically
% draw bounding boxes.
%
% Copyright, Henryk Blasinski 2018


p = inputParser;
p.addRequired('fileName');
p.addRequired('labelMap');
p.addOptional('mode','mesh');

p.parse(fileName,labelMap,varargin{:});
mode = p.Results.mode;

% load(fileName);
% map = uint32(img/radiometricScaleFactor);

multispectralImage = piReadDAT(fileName, 'maxPlanes', 31);
img = multispectralImage(:,:,1);
map = uint32(img);

[path, fName] = fileparts(fileName);
switch mode
    case 'mesh'
        textFile = fullfile(path,sprintf('%s_mesh.txt',fName));
    case 'texture'
        textFile = fullfile(path,sprintf('%s_texture.txt',fName));
end

classMap = zeros(size(map));
instanceMap = zeros(size(map));

fid = fopen(textFile,'r');
if fid == -1
    return;
end
mappings = textscan(fid,'%u %s');
fclose(fid);
nSimplified = length(labelMap);
   

for i=1:nSimplified

    % Find all the meshes that contain the class in their name
    loc = cellfun(@(x) isempty(x)==false, (strfind(lower(mappings{2}),sprintf('_%s_',lower(labelMap(i).name)))));
    classMap(ismember(map,mappings{1}(loc))) = labelMap(i).id;
    
    meshNames = mappings{2}(loc);
    meshIds = mappings{1}(loc);
    
    % Find all instances belonging to the category
    posA = strfind(lower(meshNames),lower('_inst_'));
    
    
    % but if we find the keyword _inst_ then we have different
    % instances
    posB = cellfun(@(x,y) strfind(y(x(1)+length('_inst_'):end),'_'),posA,meshNames,'UniformOutput',false);
    posB = cellfun(@(x) x(1),posB,'UniformOutput',false);
    
    instances = cellfun(@(x,y,z) str2double(z(x+length('_inst_'):(x+length('_inst_')+y-2))),posA,posB,meshNames);
    instances = unique(instances);
    nInstances = length(instances);
    
    for j=1:nInstances
        loc = cellfun(@(x) isempty(strfind(lower(x),sprintf('_inst_%i_',instances(j))))==false,meshNames);
        
        instanceMap(ismember(map,meshIds(loc))) = instances(j);
    end
    
end

classMap = uint8(classMap);
instanceMap = uint8(instanceMap);

end

