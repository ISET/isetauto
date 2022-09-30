function obj = assetPlace(obj, assetNames, roadtype)
for ii = 1:numel(assetNames)
    % merge recipes
    thisPlacedList = obj.(roadtype).(assetNames{ii}).placedList;
    thisNameList = obj.(roadtype).(assetNames{ii}).namelist;
    
    % Hope this can save some time
    if contains(assetNames{ii},{'grass','tree','rock'}) && strcmp(roadtype,'offroad')
        graftNow = false;
        tmpTree = tree();
        n = piAssetCreate('type', 'branch');
        n.name = sprintf('%s_branch',assetNames{ii});
        tmpTree = tmpTree.set(1, n);
    else
        graftNow = true;
    end
    for nn = 1:numel(thisPlacedList.positions) % lane number
        lanePositions = thisPlacedList.positions{nn};
        laneRotations = thisPlacedList.rotations{nn};
        laneIds       = thisPlacedList.objIdList{nn};
        for mm = 1:size(thisPlacedList.positions{nn},1)
            positions = lanePositions;
            rotations = laneRotations;
            thisId    = laneIds(mm);
            thisName  = thisNameList{thisId};
            thisBranch = [thisName,'_m_B'];

            if size(rotations, 2) > 1
                rotationMatrix = piRotationMatrix('xrot', rad2deg(rotations(mm,1)),...
                    'yrot', rad2deg(rotations(mm,2)),...
                    'zrot', rad2deg(rotations(mm,3)));
            else
                rotationMatrix = piRotationMatrix('zrot', rad2deg(rotations(mm,1)));
            end
            if graftNow
                obj.recipe   = piObjectInstanceCreate(obj.recipe, thisBranch, ...
                    'position', positions(mm,:),...
                    'rotation',rotationMatrix);
            else
                [obj.recipe,~,objectInstanceNode]   = piObjectInstanceCreate(obj.recipe, thisBranch, ...
                    'position', positions(mm,:),'rotation',rotationMatrix,...
                    'graftNow', false);
                tmpTree = tmpTree.append(1, objectInstanceNode);
            end

        end
    end

    if ~graftNow
        obj.recipe.assets = obj.recipe.assets.append(1, tmpTree);
        obj.recipe.assets = obj.recipe.assets.uniqueNames;
    end

end

obj.recipe.assets = obj.recipe.assets.uniqueNames;
end