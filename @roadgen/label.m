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

%% Make a copy
thisR = obj.recipe.copy;

%% Set up the rendering parameters appropriate for a label render

thisR.set('rays per pixel',8);
thisR.set('nbounces',1);
thisR.set('film render type',{'instance'});
thisR.set('integrator','path');

% Add this line: Shape "sphere" "float radius" 500 
thisR.world(numel(thisR.world)+1) = {'Shape "sphere" "float radius" 5000'};

outputFile = thisR.get('outputfile');
[dir, fname, ext] = fileparts(outputFile);
thisR.set('outputFile',fullfile(dir, [fname, '_instanceID', ext]));

piWrite(thisR);

[~,username] = system('whoami');

if strncmp(username,'zhenyi',6)
    if ismac
        oiInstance = piRenderZhenyi(thisR,'device','cpu');
    else
        oiInstance = piRenderServer(thisR,'device','cpu');
    end
else
    % use CPU for label generation, will fix this and render along with
    % radiance. --Zhenyi

    % This is how we set up for a local CPU device at Stanford.
    thisD = dockerWrapper;
    thisD.localRender = true;
    thisD.getRenderer;
    oiInstance = piRender(thisR,'our docker',thisD);
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
