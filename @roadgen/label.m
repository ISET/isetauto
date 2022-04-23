function [obj,objectslist,instanceIdMap] = label(obj)
<<<<<<< Updated upstream
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
=======
% Render a pixel map of each object in the image
%   (instanceId map)
%
%
% TODO:
%   Maybe we can fix the GPU rendering for this issue,then we only
%   need to render once to get all metadata.
% 
% Description
%  Generate an object list, its sequential position number maps the instance
%  ID in instanceIdMap
%
% See also
%   cocoapi - repository, piAnnotationGet()
%

%%
thisR = obj.copy;

thisR.set('rays per pixel',8);
thisR.set('nbounces',1);
thisR.set('film render type',{'instance'});
thisR.set('integrator','path');
>>>>>>> Stashed changes
% Add this line: Shape "sphere" "float radius" 500 
thisR.world(numel(thisR.world)+1) = {'Shape "sphere" "float radius" 5000'};

<<<<<<< Updated upstream
outputFile = obj.recipe.get('outputfile');
[dir, fname, ext] = fileparts(outputFile);
obj.recipe.set('outputFile',fullfile(dir, [fname, '_instanceID', ext]));
=======
outputFile = thisR.get('outputfile');
[dir, fname, ext]=fileparts(outputFile);
thisR.set('outputFile',fullfile(dir, [fname, '_instanceID', ext]));
>>>>>>> Stashed changes

piWrite(thisR);

[~,username] = system('whoami');

if strncmp(username,'zhenyi',6)
    if ismac
        oiInstance = piRenderZhenyi(thisR,'device','cpu');
    else
        oiInstance = piRenderServer(thisR,'device','cpu');
    end
else
<<<<<<< Updated upstream
    % use CPU for label generation
    ourDocker = dockerWrapper('gpuRendering', false);
    ourDocker.relativeScenePath = fullfile(iaRootPath,'local/');
    
    forceLocal = getpref('docker','forceLocal');
    setpref('docker','forceLocal',1);
    oiInstance = piRender(obj.recipe, 'ourdocker',ourDocker');
    setpref('docker','forceLocal',forceLocal);
    
=======
    % use CPU for label generation, will fix this and render along with
    % radiance. --Zhenyi
    oiInstance = piRender(thisR);
>>>>>>> Stashed changes
end

thisR.world = {'WorldBegin'};

instanceIdMap = oiInstance.metadata.instanceID;

%% Get object lists

outputFile = thisR.get('outputfile');
fname = strrep(outputFile,'.pbrt','_geometry.pbrt');
fileID = fopen(fname);
tmp = textscan(fileID,'%s','Delimiter','\n');
txtLines = tmp{1};
fclose(fileID);
objectslist = txtLines(piContains(txtLines,'ObjectInstance'));

end