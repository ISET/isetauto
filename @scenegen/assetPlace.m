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

            rotationMatrix = piRotationMatrix('z',rad2deg(rotations(mm)));
            thisBranch = [thisName,'_m_B'];

            obj.recipe   = piObjectInstanceCreate(obj.recipe, thisBranch, ...
                'position', [positions(mm,1), positions(mm,2), 0],...
                'rotation',rotationMatrix);
        end
    end
end
end