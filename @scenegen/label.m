function [obj,objectslist,instanceIdMap] = label(obj)
% Render instanceId map, maybe I can fix the GPU rendering for this issue,
% then we only need to render once to get all metadata.
% Generate an object list, its sequential position number maps the instance
% ID in instanceIdMap
obj.recipe.set('rays per pixel',16);
obj.recipe.set('nbounces',1);
obj.recipe.set('film render type',{'instance'});

% Add this line: Shape "sphere" "float radius" 500 
obj.recipe.world(numel(obj.recipe.world)+1) = {'Shape "sphere" "float radius" 5000'};

outputFile = obj.recipe.get('outputfile');
[dir, fname, ext]=fileparts(outputFile);
obj.recipe.set('outputFile',fullfile(dir, [fname, '_instanceID', ext]));

piWrite(obj.recipe);

oiInstance = piRenderZhenyi(obj.recipe,'device','cpu');

obj.recipe.world = {'WorldBegin'};

instanceIdMap = oiInstance.metadata.instanceID;

%% get object lists
outputFile = obj.recipe.get('outputfile');
fname = strrep(outputFile,'.pbrt','_geometry.pbrt');
fileID = fopen(fname);
tmp = textscan(fileID,'%s','Delimiter','\n');
txtLines = tmp{1};
fclose(fileID);
objectslist = txtLines(piContains(txtLines,'ObjectInstance'));

end