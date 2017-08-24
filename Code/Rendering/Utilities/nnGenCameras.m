function [ camera ] = nnGenCameras( varargin )

p = inputParser;
p.addOptional('type',{'pinhole'});
p.addOptional('lens',{'dgauss.22deg.6.0mm'});
p.addOptional('mode',{'radiance'});
p.addOptional('pixelSamples',128);
p.addOptional('distance',10);
p.addOptional('orientation',0);
p.addOptional('orientationRange',[]);
p.addOptional('height',-1.5);
p.addOptional('PTR',{[0,0,0]});
p.addOptional('PTRrange',[]);
p.addOptional('defocus',0);
p.addOptional('diffraction',{'false'});
p.addOptional('chromaticAberration',{'false'});
p.addOptional('fNumber',2.8);
p.addOptional('filmDiagonal',1/6.4*25.4);
p.addOptional('microlens',{[0,0]});
p.addOptional('lookAtObject',1);

p.parse(varargin{:});
inputs = p.Results;

%% Checks
assert(length(inputs.type)==length(inputs.lens) || length(inputs.type)==1 || length(inputs.lens)==1);
assert(length(inputs.diffraction)==length(inputs.chromaticAberration) || length(inputs.diffraction)==1 || length(inputs.chromaticAberration)==1);
assert(length(inputs.microlens)==length(inputs.lens) || length(inputs.microlens) == 1 || length(inputs.lens)==1);

%% Loop

cntr = 1;
viewpointCntr = 1;
frameCntr = 1;

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
    
for g=1:length(inputs.defocus)
for a=1:max([length(inputs.type), length(inputs.lens), length(inputs.microlens)]) 
for i=1:length(inputs.fNumber)
for b=1:length(inputs.pixelSamples)
for k=1:length(inputs.mode)
    
     % Prune some combinations that don't make any sense:
    % 1. A pinhole camera does not have parameters that specify diffraction
    % or chromatic aberration
    
     % 2. A lens camera in a non-radiance mode requires diffraction and
    % chromatic aberration to be switched off
    if strcmp(inputs.type{a},'pinhole') || ~strcmp(inputs.mode{k},'radiance')
        diffractionVec = {'false'};
        chromaticAberrationVec = {'false'};
    else
        diffractionVec = inputs.diffraction;
        chromaticAberrationVec = inputs.chromaticAberration;        
    end
    
    
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
        
    
    camera(cntr).defocus = inputs.defocus(g);
    camera(cntr).diffraction = diffr;
    camera(cntr).chromaticAberration = chrAber;
    camera(cntr).lookAtObject = inputs.lookAtObject(l);
    
    camera(cntr).viewpointId = viewpointCntr;
    camera(cntr).frameId = frameCntr;
    camera(cntr).description = sprintf('frame_%i_view_%i_%s',frameCntr,viewpointCntr,inputs.mode{k});
    
    % These get filled in once we define a scene.
    camera(cntr).filmDistance = [];
    camera(cntr).lookAt = [];
    camera(cntr).position = [];
    
    cntr = cntr+1;
end
end
frameCntr = frameCntr + 1;
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

