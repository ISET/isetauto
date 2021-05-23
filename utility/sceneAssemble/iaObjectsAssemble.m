function thisR = iaObjectsAssemble(thisR, objects, varargin)
% Add objects information to scene recipe
%
% Synopsis:
%   thisR = iaObjectsAdd(thisR, objects, varargin)
% 
% Brief description:
%   Add objects information (material, texture, assets) to a scene recipe.
%
% Inputs:
%   thisR   - scene recipe
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
%   thisR   - scene recipe with added objects.
% 
% See also: piRecipeMerge

%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x),'recipe'));

p.parse(thisR, varargin{:});

thisR        = p.Results.thisR;

%%
% get all filednames
fdnamelist = fieldnames(objects);
for ii = 1:numel(fdnamelist)
    objectlist = objects.(fdnamelist{ii});
    for jj = 1:numel(objectlist)
        
        %% Add objects
        thisObject = objectlist(jj);
        % get subtree and do not replace stripID
        thisOBJsubtree = thisObject.recipe.get('asset', 2, 'subtree','false');
        % get branch
        thisOBJsubtree_branch = thisOBJsubtree.get(1);
        
        for kk = 1:numel(thisObject.position)
            
            % add (motion) position / rotation list to branch
            thisOBJsubtree_branch.translation = thisObject.position{kk};
            thisOBJsubtree_branch.rotation = thisObject.rotation{kk};
            
            if isfield(thisObject, 'motion')
                thisOBJsubtree_branch.motion.position = thisObject.motion.position{kk};
                thisOBJsubtree_branch.motion.rotation = thisObject.motion.rotation{kk};
            end
            % add label
            thisOBJsubtree_branch.class = fdnamelist{ii};
            if kk > 1
                thisOBJsubtree_branch.name  = strcat(thisOBJsubtree_branch.name, '_I');
            end
            % replace branch
            thisOBJsubtree = thisOBJsubtree.set(1, thisOBJsubtree_branch);
            
            % graft object tree to scene tree
            thisR.assets = thisR.assets.graft(1, thisOBJsubtree);
        end
        %% Add materials
        sceneMatListlength = length(thisR.materials.list);
        if ~isempty(thisR.materials)
            for matIdx = 1:length(thisObject.recipe.materials.list)
                thisR.materials.list{sceneMatListlength + matIdx} =...
                    thisObject.recipe.materials.list{matIdx};
            end
        else
            thisR.materials.list = thisObject.recipe.materials.list;
        end
        
        %% Add textures
        sceneTexListlength = length(thisR.textures.list);
        if ~isempty(thisR.textures)
            for texIdx = 1:length(thisObject.recipe.textures.list)
                thisR.textures.list{sceneTexListlength + texIdx} =...
                    thisObject.recipe.textures.list{texIdx};
            end
        else
            thisR.textures = thisObject.recipe.textures;
        end
        
    end
    
end
thisR.assets = thisR.assets.uniqueNames;
end

