function [obj,objectslist,instanceIdMap] = label(obj)
% Generate the labels for the road
%
% Synopsis
%    roadgen.label
%
% Decription
%   Render an instanceId map.  For now this only runs on a CPU. Maybe
%   Zhenyi can fix the GPU rendering for this issue, which would let us
%   render once to get all metadata. 
%
%

%% Set up the rendering parameters appropriate for a label render

obj.recipe.set('rays per pixel',8);
obj.recipe.set('nbounces',1);
obj.recipe.set('film render type',{'instance'});
obj.recipe.set('integrator','path');
% Add this line: Shape "sphere" "float radius" 500 
obj.recipe.world(numel(obj.recipe.world)+1) = {'Shape "sphere" "float radius" 5000'};

outputFile = obj.recipe.get('outputfile');
[dir, fname, ext] = fileparts(outputFile);
obj.recipe.set('outputFile',fullfile(dir, [fname, '_instanceID', ext]));

piWrite(obj.recipe);

[~,username] = system('whoami');

if strncmp(username,'zhenyi',6)
    if ismac
        oiInstance = piRenderZhenyi(obj.recipe,'device','cpu');
    else
        oiInstance = piRenderServer(obj.recipe,'device','cpu');
    end
else
    % use CPU for label generation
    ourDocker = dockerWrapper('gpuRendering', false);
    ourDocker.relativeScenePath = fullfile(iaRootPath,'local/');
    
    forceLocal = getpref('docker','forceLocal');
    setpref('docker','forceLocal',1);
    oiInstance = piRender(obj.recipe, 'ourdocker',ourDocker');
    setpref('docker','forceLocal',forceLocal);
    
end

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