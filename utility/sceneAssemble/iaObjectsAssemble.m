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
%   objects  - isetauto object list, a list example is shown below:
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
        assetlist  = thisObject.recipe.get('assetlist');
        try
            OBJsubtree = thisObject.recipe.get('asset', assetlist{1}.name, 'subtree','false');
        catch
            disp('More than one asset exists, not allowed.')
        end
        % get branch
        OBJsubtree_branch = OBJsubtree.get(1);
        for kk = 1:numel(thisObject.position)
            if kk<3
                [idx,~] = piAssetFind(thisR, 'name', OBJsubtree_branch.name);
            end
            newbranch = OBJsubtree_branch;
            % we do not create instance for the first set of transformations
            if kk==1
                OBJsubtree_branch.translation     = thisObject.position{kk};
                OBJsubtree_branch.rotation        = thisObject.rotation{kk};
                if isfield(thisObject,'motion')
                    OBJsubtree_branch.motion.position = thisObject.motion.position{kk};
                    OBJsubtree_branch.motion.rotation = thisObject.motion.rotation{kk};
                end
                OBJsubtree_branch.class = fdnamelist{ii};
                OBJsubtree = OBJsubtree.set(1, OBJsubtree_branch);
                % graft object tree to scene tree
                thisR.assets = thisR.assets.graft(1, OBJsubtree);
                
                continue
            end
            
            % add (motion) position / rotation list to branch
            if ~isfield(newbranch, 'instanceCount')
                OBJsubtree_branch.instanceCount = 1;
                indexCount = 1;
            else
                if OBJsubtree_branch.instanceCount(end)==numel(OBJsubtree_branch.instanceCount)
                    OBJsubtree_branch.instanceCount = [OBJsubtree_branch.instanceCount,...
                        OBJsubtree_branch.instanceCount(end)+1];
                    indexCount = numel(OBJsubtree_branch.instanceCount);
                else
                    indexCount = 1;
                    while ~isempty(find(OBJsubtree_branch.instanceCount==indexCount,1))
                        indexCount = indexCount+1;
                    end
                    OBJsubtree_branch.instanceCount = sort([OBJsubtree_branch.instanceCount,indexCount]);
                end
            end
            % add instance to parent object
            thisR.assets = thisR.assets.set(idx, OBJsubtree_branch);
            
            % assign position/rotation
            newbranch.translation     = thisObject.position{kk};
            newbranch.rotation        = thisObject.rotation{kk};
            % assgin motion position/rotation
            if isfield(thisObject,'motion')
                newbranch.motion.position = thisObject.motion.position{kk};
                newbranch.motion.rotation = thisObject.motion.rotation{kk};
            end
            
            InstanceSuffix = sprintf('_I_%d',indexCount);
            Instance_subtree = OBJsubtree;
            for ll = 1:numel(OBJsubtree.Node)
                thisNode      = OBJsubtree.Node{ll};
                thisNode.name = strcat(OBJsubtree.Node{ll}.name, InstanceSuffix);
                if strcmp(OBJsubtree.Node{ll}.type,'object')
                    thisNode.type = 'instance';
                    thisNode.referenceObject = OBJsubtree.Node{ll}.name;
                end
                Instance_subtree = Instance_subtree.set(ll, thisNode);
            end
            newbranch.referencebranch = OBJsubtree_branch.name;
            
            newbranch.name  = strcat(OBJsubtree_branch.name, InstanceSuffix);
            % set class name
            newbranch.class = fdnamelist{ii};
            % replace branch
            Instance_subtree = Instance_subtree.set(1, newbranch);
            
            % graft object tree to scene tree
            thisR.assets = thisR.assets.graft(1, Instance_subtree);
        end
        %% Add materials
        if ~isempty(thisR.materials)
            matKeys = keys(thisObject.recipe.materials.list);
            for matIdx = 1:numel(matKeys)
                thisR.materials.list(matKeys{matIdx})=...
                    thisObject.recipe.materials.list(matKeys{matIdx});
            end
        else
            thisR.materials.list = thisObject.recipe.materials.list;
        end
        
        %% Add textures
        if ~isempty(thisR.textures)
            texKeys = keys(thisObject.recipe.textures.list);
            for texIdx = 1:numel(texKeys)
                thisR.textures.list(texKeys{texIdx}) =...
                    thisObject.recipe.textures.list(texKeys{texIdx});
            end
        else
            thisR.textures = thisObject.recipe.textures;
        end
        
    end
    
end
thisR.assets = thisR.assets.uniqueNames;
end

