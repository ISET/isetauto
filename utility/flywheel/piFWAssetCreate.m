function recipe = piFWAssetCreate(acq, varargin)
% Create a flywheel asset
%
% Syntax:
%  recipe = piFWAssetCreate(acq, varargin)
% 
% Required:
%  acq    - a Flywheel acquisition container which stores an asset and the
%           recipe and CG resources (textures, meshes) necessary to render
%           the asset 
% 
% Optional key/val pairs
%  resources  - a flag decides whether download reciepe and CG resources or 
%              recipe only
%  dstDir     - destination directory where CG resources will be saved,
%        default directory is created at isetauto/local.
%
% Return:
%  recipe    - asset recipe
% 

%%
p = inputParser;
p.addParameter('resources',false,@islogical);
p.addParameter('dstDir','',@ischar);

p.parse(varargin{:});

resourcesFlag = p.Results.resources;
dstDir = p.Results.dstDir;

%%  We download the json file for the recipe
tmpDir = [pwd, '/tmp',num2str(randi(1000))];
mkdir(tmpDir);
tmpRecipe = [tmpDir, '/tmp.json'];
for ii = 1:length(acq.files)
    if ieContains(acq.files{ii}.name, 'recipe')
        acq.downloadFile(acq.files{ii}.name, tmpRecipe);
        break;
    end
end

%% Read and convert the json recipe into a ISET3d recipe
recipe = piJson2Recipe(tmpRecipe);

% remove tmp dir
rmdir(tmpDir,'s');

if resourcesFlag
    % create destination directory
    if isempty(dstDir)
        [~, fname, ~] = fileparts(recipe.outputfile);
        dstDir = fullfile(iaRootPath, 'local', fname);
    end
    
    if ~exist(dstDir,'dir'), mkdir(dstDir);end
    dstFile = fullfile(dstDir, 'tmp.zip');
    for ii = 1:length(acq.files)
        if strcmpi(acq.files{ii}.type,'CG Resource')
            acq.downloadFile(acq.files{ii}.name, dstFile);
        end
    end
    unzip(dstFile, dstDir);
    % addpath(genpath(dstDir))
    delete(dstFile);
end

end