function sceneR = piRecipeMerge(sceneR, objectRs, varargin)
% Add objects information to scene recipe
%
% Synopsis:
%   sceneR = piRecipeMerge(sceneR, objects, varargin)
% 
% Brief description:
%   Add objects information (material, texture, assets) to a scene recipe.
%
% Inputs:
%   sceneR   - scene recipe
%   objectRs  - object recipe/ recipe list
%   
% Returns:
%   sceneR   - scene recipe with added objects.
%
%% Parse input
p = inputParser;
p.addRequired('sceneR', @(x)isequal(class(x),'recipe'));
p.addParameter('material',true);
p.addParameter('texture',true);
p.addParameter('asset',true);

p.parse(sceneR, varargin{:});

sceneR        = p.Results.sceneR;
materialFlag = p.Results.material;
textureFlag  = p.Results.texture;
assetFlag    = p.Results.asset;

%%
if ~iscell(objectRs)
    recipelist{1} = objectRs;
else
    recipelist = objectRs;
end
for ii = 1:length(recipelist)
    thisR = recipelist{ii};
    if assetFlag
        names = thisR.get('assetnames');
        thisOBJsubtree = thisR.get('asset', names{2}, 'subtree');
        [~,addedSubtree1] = sceneR.set('asset', 'root', 'graft', thisOBJsubtree);
        
        % copy meshes from objects folder to scene folder here?
        [sourceDir, ~, ~]=fileparts(thisR.outputFile);
        [dstDir, ~, ~]=fileparts(sceneR.outputFile);
        sourceAssets = fullfile(sourceDir, 'scene/PBRT/pbrt-geometry');
        dstAssets    = fullfile(dstDir,    'scene/PBRT/pbrt-geometry');
        try
            copyfile(sourceAssets, dstAssets);
        catch
            warning('Copying assets is failed.');
        end
    end
    
    if materialFlag
        sceneMatListlength = length(sceneR.materials.list);
        if ~isempty(sceneR.materials)
        for matIdx = 1:length(thisR.materials.list)
            sceneR.materials.list{sceneMatListlength+matIdx} = thisR.materials.list{matIdx};
        end
        else
            sceneR.materials.list = thisR.materials.list;
        end
    end
    
    if textureFlag
        sceneTexListlength = length(sceneR.textures.list);
        if ~isempty(sceneR.textures)
            for texIdx = 1:length(thisR.textures.list)
                sceneR.textures.list{sceneTexListlength+texIdx} = thisR.textures.list{texIdx};
            end
        else
            sceneR.textures = thisR.textures;
        end
        [sourceDir, ~, ~]=fileparts(thisR.outputFile);
        [dstDir, ~, ~]=fileparts(sceneR.outputFile);
        sourceTexures = fullfile(sourceDir, 'textures');
        try
            copyfile(sourceTexures, dstDir);
        catch
            warning('Copying texture is failed.');
        end
    end
end
end

