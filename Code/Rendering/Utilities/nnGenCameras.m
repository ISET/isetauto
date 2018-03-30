function [ camera ] = nnGenCameras( varargin )

% Generate a structure describing a camera. If arrays of values are passed
% as inputs, then cameras are generated for each combination of paramters
% that 'make sense.' For example, there is no notion of defocus for a
% pinhole camera, so a pinhole camera will always be generated with
% defocus=0. 
%
% Copyright, Henryk Blasinski 2018

p = inputParser;
p.addOptional('type',{'pinhole'});              % Camera type: pinhole, lens or lightfield
p.addOptional('lens',{'dgauss.22deg.6.0mm'});   % Lens model used. If a pinhole camera is specified, the lens model is used to compute FOV.
p.addOptional('mode',{'radiance'});             % Rendering type: radiance, mesh, material, depth
p.addOptional('pixelSamples',128);
p.addOptional('distance',10);                   % Distance between the camera and the reference object
p.addOptional('orientation',0);                 % Orientation of the lookAt vector projected onto the xy plane
p.addOptional('orientationRange',[]);           % If specified orientation is randomly drawn from the range.
p.addOptional('height',-1.5);                   % Hight of the camera above ground
p.addOptional('PTR',{[0,0,0]});                 % The pan, tilt, roll of the lookAt vector
p.addOptional('PTRrange',[]);
p.addOptional('defocus',0);
p.addOptional('diffraction',{'false'});
p.addOptional('chromaticAberration',{'false'});
p.addOptional('fNumber',2.8);
p.addOptional('filmDiagonal',1/6.4*25.4);
p.addOptional('microlens',{[0,0]});
p.addOptional('lookAtObject',1);                % Index of the object towards which the camera is pointing.
p.addOptional('upDir',[0 0 -1]);

p.parse(varargin{:});
inputs = p.Results;

%% Checks
assert(length(inputs.type)==length(inputs.lens) || length(inputs.type)==1 || length(inputs.lens)==1);
assert(length(inputs.diffraction)==length(inputs.chromaticAberration) || length(inputs.diffraction)==1 || length(inputs.chromaticAberration)==1);
assert(length(inputs.microlens)==length(inputs.lens) || length(inputs.microlens) == 1 || length(inputs.lens)==1);

%% Loop

cntr = 1;
viewpointCntr = 1;

for c=1:length(inputs.distance)
for d=1:length(inputs.orientation)
for e=1:length(inputs.height)
for f=1:length(inputs.PTR)
for l=1:length(inputs.lookAtObject)
 
    % We need to preserve random parameters across different camera modes,
    % lens types etc., hence we generate them here.
    
    randptr = rand(1,3);
    randOrientation = rand(1,1);
for j=1:length(inputs.filmDiagonal)
    
for a=1:max([length(inputs.type), length(inputs.lens), length(inputs.microlens)]) 
for i=1:length(inputs.fNumber)
for b=1:length(inputs.pixelSamples)
for k=1:length(inputs.mode)
    
    % Prune some combinations that don't make any sense:
    % 1. A pinhole camera does not have parameters that specify diffraction
    % or chromatic aberration
    
    % 2. A lens camera in a non-radiance mode requires diffraction and
    % chromatic aberration to be switched off
    
    % 3. There is no notion of defocus for pinhole cameras.
    
    if strcmp(inputs.type{a},'pinhole') || ~strcmp(inputs.mode{k},'radiance')
        diffractionVec = {'false'};
        chromaticAberrationVec = {'false'};
        defocusVec = [0];
    else
        diffractionVec = inputs.diffraction;
        chromaticAberrationVec = inputs.chromaticAberration; 
        defocusVec = inputs.defocus;
    end
    
for g=1:length(defocusVec)  
for h=1:max([length(diffractionVec), length(chromaticAberrationVec)])
    
    
    
    if length(diffractionVec) == 1
        diffr = diffractionVec{1};
    else
        diffr = diffractionVec{h};
    end
    if length(chromaticAberrationVec) == 1
        chrAber = chromaticAberrationVec{1};
    else
        chrAber = chromaticAberrationVec{h};
    end
        
    
    
    
    if length(inputs.type) == 1
        camera(cntr).type = inputs.type{1};
    else
        camera(cntr).type = inputs.type{a};
    end
    if length(inputs.lens) == 1
        camera(cntr).lens = inputs.lens{1};
    else
        camera(cntr).lens = inputs.lens{a};
    end
    if length(inputs.microlens) == 1
        camera(cntr).microlens = inputs.microlens{1};
    else
        camera(cntr).microlens = inputs.microlens{a};
    end
    camera(cntr).mode = inputs.mode{k};
    camera(cntr).pixelSamples = inputs.pixelSamples(b);
    camera(cntr).fNumber = inputs.fNumber(i);
    camera(cntr).filmDiagonal = inputs.filmDiagonal(j);
    camera(cntr).distance = inputs.distance(c);
    camera(cntr).orientation = inputs.orientation(d);
    if ~isempty(inputs.orientationRange)
        camera(cntr).orientation = randOrientation*(inputs.orientationRange(2)-inputs.orientationRange(1)) + inputs.orientationRange(1);
    end
    
    camera(cntr).height = inputs.height(e);
    camera(cntr).PTR = inputs.PTR{f};
    if ~isempty(inputs.PTRrange)
        % We are generating random pan-til-roll for every camera from a
        % given range
        
        ptr = randptr.*abs(diff(inputs.PTRrange)) + min(inputs.PTRrange);
        camera(cntr).PTR = ptr;
    end
        
    
    camera(cntr).defocus = defocusVec(g);
    camera(cntr).diffraction = diffr;
    camera(cntr).chromaticAberration = chrAber;
    camera(cntr).lookAtObject = inputs.lookAtObject(l);
    
    camera(cntr).viewpointId = viewpointCntr;
    camera(cntr).description = sprintf('View_%i_%s',viewpointCntr,inputs.mode{k});
    camera(cntr).upDir = inputs.upDir;
    
    % These get filled in once we define a scene.
    camera(cntr).filmDistance = [];
    camera(cntr).lookAt = [];
    camera(cntr).position = [];
    
    cntr = cntr+1;
end
end
end
end
end
end

viewpointCntr = viewpointCntr+1;

end
end
end
end
end
end

