function sceneR = iaObjectsAssemble(sceneR, objects, varargin)
% Add objects information to scene recipe
%
% Synopsis:
%   sceneR = iaObjectsAdd(sceneR, objects, varargin)
% 
% Brief description:
%   Add objects information (material, texture, assets) to a scene recipe.
%
% Inputs:
%   sceneR   - scene recipe
%   objects  - isetauo object list, a list example showed below: 
%
%              tree: [1×8 struct]
%         billboard: [1×2 struct]
%           callbox: [1×1 struct]
%             bench: [1×1 struct]
%          trashcan: [1×3 struct]
%           station: [1×1 struct]
%          bikerack: [1×2 struct]
%       streetlight: [1×1 struct]
%          building: [1×16 struct]
%    
%   An object example:          
%             name: 'bus_001'
%        material: [1×1 struct]
%        geometry: [1×1 tree]
%    geometryPath: '~/scene/PBRT/pbrt-geometry'
%            size: [1×1 struct]
%        position: {2×1 cell}
%        rotation: [4×3 double]
%          fwInfo: 'thisAcquisitionID bus_001.cgresource.zip'
%           count: 2
%          motion: [1×1 struct]
%
%   
% Returns:
%   sceneR   - scene recipe with added objects.
% 
% See also: piRecipeMerge

%% Parse input
p = inputParser;
p.addRequired('sceneR', @(x)isequal(class(x),'recipe'));

p.parse(sceneR, varargin{:});

sceneR        = p.Results.sceneR;

%%
% get all filednames
fdnamelist = fieldnames(objects);
for ii = 1:numel(fdnamelist)
    objectlist = objects.(fdnamelist{ii});
    for jj = 1:numel(objectlist)
        
        %% Add objects
        thisObject                        = objectlist(jj);
        try
        names                             = thisObject.recipe.get('asset names');
        catch
            disp('catch');
        end
        objectBranchName                  = names{2};
        thisOBJsubtree                    = thisObject.recipe.get('asset', objectBranchName, 'subtree');
        % get branch
        thisOBJsubtree_branch             = thisOBJsubtree.get(1);
        % add (motion) position / rotation list to branch
        thisOBJsubtree_branch.translation = thisObject.position;
        thisOBJsubtree_branch.rotation    = thisObject.rotation;
        
        if isfield(thisObject, 'motion')
            thisOBJsubtree_branch.motion  = thisObject.motion;
        end
        % replace branch
        thisOBJsubtree = thisOBJsubtree.set(1, thisOBJsubtree_branch);
        % graft object tree to scene tree
        sceneR.set('asset', 'root', 'graft', thisOBJsubtree);

        %% Add materials
        sceneMatListlength = length(sceneR.materials.list);
        if ~isempty(sceneR.materials)
            for matIdx = 1:length(thisObject.recipe.materials.list)
                sceneR.materials.list{sceneMatListlength + matIdx} =...
                    thisObject.recipe.materials.list{matIdx};
            end
        else
            sceneR.materials.list = thisObject.recipe.materials.list;
        end
        
        %% Add textures
        sceneTexListlength = length(sceneR.textures.list);
        if ~isempty(sceneR.textures)
            for texIdx = 1:length(thisObject.recipe.textures.list)
                sceneR.textures.list{sceneTexListlength + texIdx} =...
                    thisObject.recipe.textures.list{texIdx};
            end
        else
            sceneR.textures = thisObject.recipe.textures;
        end
        
    end
    
end

end

