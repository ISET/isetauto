function [objectslist,instanceIdMap] = label(obj)
% Generate labels for the objects on the road
%
% Synopsis
%    [objectslist,instanceIdMap] = roadgen.label;
%
% Brief
%   Render an image showing which object at each pixel (instanceId map).
%   For now this only runs on a CPU.  
%
% Inputs
%   obj - roadgen object
% 
% Key-val/Outputs
%   N/A
%
% Outputs
%   objectslist   - List of the objects
%   instanceIdMap - Image with integers at each pixel indicating which
%                   object.
%
% Description
%  For object detection, we often want pixel maps indicating which object
%  is at each pixel. The correspondence between the pixel values and the
%  objects in the returned objectslist. This routine performs that
%  calculation, but it is tuned for isetauto.
% 
%  It only runs on CPU for now. Zhenyi hopes to fix the GPU rendering for
%  this issue, which would let us render once to get all metadata.
%
% See also
%   cocoapi - repository, piAnnotationGet()
%

%% Make a copy of the rendering recipe

% We alter the rendering properties to speed up for just labeling.
% Fewer rays, one bounce, path integrator.
thisR = obj.recipe.copy;

%% Set up the rendering parameters appropriate for a label render

thisR.set('rays per pixel',8);
thisR.set('nbounces',1);
thisR.set('film render type',{'instance'});
thisR.set('integrator','path');

% Add this line: Shape "sphere" "float radius" 500 
% Because of the lighting??
thisR.world(numel(thisR.world)+1) = {'Shape "sphere" "float radius" 5000'};

outputFile = thisR.get('outputfile');
[dir, fname, ext] = fileparts(outputFile);
thisR.set('outputFile',fullfile(dir, [fname, '_instanceID', ext]));

piWrite(thisR);

%% Handle Zhenyi differently from Stanford.
% [~,username] = system('whoami');

% if strncmp(username,'zhenyi',6)
%     if ismac
%         isetStruct = piRenderZhenyi(thisR,'device','cpu');
%     else
%         isetStruct = piRenderServer(thisR,'device','cpu');
%     end
% else
    % use CPU for label generation, will fix this and render along with
    % radiance. --Zhenyi
    
    % This is set up for Stanford.
    % For the moment it is hard-coded torender on the CPU on muxreconrt.  
    % 
    % It would probably be better to run locally and not to have to reset
    % the remote container.
    % 
    % Also, can we just reset the running docker wrapper ?
    
    %{
    % This worked for remote
    dockerWrapper.reset;
    x86Image = 'digitalprodev/pbrt-v4-cpu:latest';
    thisD = dockerWrapper('gpuRendering', false, ...
                          'remoteImage',x86Image);
    %}

    % This seems to work for local.  Not sure why we need the reset.
%     dockerWrapper.reset;
%     thisD = dockerWrapper('gpuRendering', false, ...
%                           'localRender',true);

    % This is the scene or oi with the metadata attached.
%     isetStruct = piRender(thisR,'our docker',thisD);
    isetStruct = piRender(thisR);
% end

% Why is this here?
thisR.world = {'WorldBegin'};

instanceIdMap = isetStruct.metadata;

%% Get object lists from the geometry file.

% Read the contents of the PBRT geometry file to find the Objects.
outputFile = thisR.get('outputfile');
fname = strrep(outputFile,'.pbrt','_geometry.pbrt');
fileID = fopen(fname);
tmp = textscan(fileID,'%s','Delimiter','\n');
txtLines = tmp{1};
fclose(fileID);

% Find all the lines that contain an ObjectInstance
objectslist = txtLines(piContains(txtLines,'ObjectInstance'));

end
