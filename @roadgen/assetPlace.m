function obj = assetPlace(obj, assetNames, roadtype)
for ii = 1:numel(assetNames)
    % merge car recipes
    thisPlacedList = obj.(roadtype).(assetNames{ii}).placedList;
    for nn = 1:numel(thisPlacedList.positions) % lane number
        for mm = 1:size(thisPlacedList.positions{nn},1)
            positions = thisPlacedList.positions{nn};
            rotations = thisPlacedList.rotations{nn};
            thisId    = thisPlacedList.objIdList{nn}(mm);
            thisName  = obj.(roadtype).(assetNames{ii}).namelist{thisId};
            thisBranch = [thisName,'_m_B'];

            if size(rotations, 2)>1
                rotationMatrix = piRotationMatrix('xrot', rad2deg(rotations(mm,1)),...
                    'yrot', rad2deg(rotations(mm,2)),...
                    'zrot', rad2deg(rotations(mm,3)));
            else
                rotationMatrix = piRotationMatrix('zrot', rad2deg(rotations(mm,1)));
            end
            try
            obj.recipe   = piObjectInstanceCreate(obj.recipe, thisBranch, ...
                'position', positions(mm,:),...
                'rotation',rotationMatrix);
            catch
                disp('DEBUG!');
            end
        end
    end
end
obj.recipe.assets = obj.recipe.assets.uniqueNames;
end