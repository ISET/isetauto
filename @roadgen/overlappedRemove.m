function obj = overlappedRemove(obj)
% We check on and off objects, overlapped objects are removed
% On road
assetInfo = assetlib();
obj.onroad.car = overlapCheckOne(assetInfo, obj.onroad.car, 2, 1.2);
obj.onroad.animal = overlapCheckOne(assetInfo, obj.onroad.animal, 1.5, 1.2);

obj.onroad.animal = overlapCheckTwo(assetInfo, obj.onroad.animal, obj.onroad.car, [1.5, 1.2],[2, 1.2]);

obj.offroad.animal = overlapCheckOne(assetInfo, obj.offroad.animal, 1.2, 1.2);

% remove animal that overlapped with trees.
obj.offroad.animal = overlapCheckTwo(assetInfo, obj.offroad.animal, obj.offroad.tree,[1, 1],[1, 1]);

end

function S1 = overlapCheckTwo(assetInfo, S1, S,offsetScale_S1,offsetScale_S)
% Check whether the objects in S1 will overlap with S, if it overlaps, the
% object will be deleted.
for ii  = 1:numel(S1.lane)
    posList_S1 = S1.placedList.positions{ii};
    posList_x_S1 = posList_S1(:,1);
    posList_y_S1 = posList_S1(:,2);
    rotList_S1   = S1.placedList.rotations{ii};
    if size(rotList_S1, 2)~=1
        rotList_S1   = rotList_S1(:, 3); % take rotation around z axis
    end
    idList_S1    = S1.placedList.objIdList{ii};
    objIndex  = [];
    for jj = 1:size(posList_S1,1)
        objIndex = [objIndex, jj];
    end
    for jj = 1:size(posList_S1,1)
        objInfo_S1 = assetInfo(S1.namelist{idList_S1(jj)});
%         offsetScale = 1.2;  % scale object patch by this scale
        objPatch_S1 = polyshape([0 0 objInfo_S1.size(1)*offsetScale_S1(1) objInfo_S1.size(1)*offsetScale_S1(1)],...
            [objInfo_S1.size(2)*offsetScale_S1(2) 0 0 objInfo_S1.size(2)*offsetScale_S1(2)]);

        objPatch_S1 = translate(objPatch_S1, posList_S1(jj,1), posList_S1(jj,2)); 
        objPatch_S1 = rotate(objPatch_S1, rad2deg(rotList_S1(jj)));
        
        indexMatched = find(contains(S.lane, S1.lane{ii}),1);
        posList_S = S.placedList.positions{indexMatched};   
        rotList_S = S.placedList.rotations{indexMatched};
        if size(rotList_S, 2)~=1
            rotList_S   = rotList_S(:, 3); % take rotation around z axis
        end
        idList_S  = S.placedList.objIdList{indexMatched};
        for ll = 1:size(posList_S,1)
            objInfo_S = assetInfo(S.namelist{idList_S(ll)});
            objPatch_S = polyshape([0 0 objInfo_S.size(1)*offsetScale_S(1) objInfo_S.size(1)*offsetScale_S(1)],...
                [objInfo_S.size(2)*offsetScale_S(2) 0 0 objInfo_S.size(2)*offsetScale_S(2)]);
    
            objPatch_S = translate(objPatch_S, posList_S(ll,1), posList_S(ll,2)); 
            objPatch_S = rotate(objPatch_S, rad2deg(rotList_S(ll)));  
            polyvec = [objPatch_S1 objPatch_S];
            overlapTF = overlaps(polyvec);
            % remove if overlap
            if overlapTF
                objIndex(jj) = 0;
                break;
            end

        end
    end
    objIndex = objIndex(objIndex~=0);
    S1.placedList.positions{ii} = posList_S1(objIndex, :);
    S1.placedList.rotations{ii} = S1.placedList.rotations{ii}(objIndex,:);
    S1.placedList.objIdList{ii} = idList_S1(objIndex);
end

end

function S = overlapCheckOne(assetInfo, S, offsetScaleX, offsetScaleY)
% Check overlap cases inside a list
% S contains following information:
%       S.placedList
%       S.namelist;
%       S.lane;
%

for ii  = 1:numel(S.lane)
    posList = S.placedList.positions{ii};
    posList_x = posList(:, 1);
    posList_y = posList(:, 2);
    rotList   = S.placedList.rotations{ii};
    if size(rotList,2) ~=1
        rotList   = rotList(:, 3); % take rotation around z axis
    end
    idList    = S.placedList.objIdList{ii};
    polyvec   = [];
    objIndex  = [];

    for jj = 1:size(posList,1)
        objInfo = assetInfo(S.namelist{idList(jj)});
%         offsetScale = 1.5;  % scale object patch by this scale
        objPatch = polyshape([0 0 objInfo.size(1) * offsetScaleX objInfo.size(1) * offsetScaleX],...
            [objInfo.size(2) * offsetScaleY 0 0 objInfo.size(2) * offsetScaleY]);

        objPatch = translate(objPatch, posList(jj,1), posList(jj,2)); 
        objPatch = rotate(objPatch, rad2deg(rotList(jj)));
        polyvec = [polyvec objPatch];
        objIndex = [objIndex, jj];
    end

    pass = 0;
    while pass==0
        [polyvec,objIndex,pass] = ListCleanup(polyvec,objIndex);
    end

    S.placedList.positions{ii} = posList(objIndex, :);
    S.placedList.rotations{ii} = S.placedList.rotations{ii}(objIndex, :);
    S.placedList.objIdList{ii} = idList(objIndex);
end


end

function [polyvec,posIndex,pass] = ListCleanup(polyvec,posIndex)
    pass = 0;
    overlapTFs = overlaps(polyvec);
    overlapTFs = overlapTFs - eye(size(overlapTFs,1));
    [r, c]= find(overlapTFs==1);
    
    if isempty(r)
        pass=1; 
        return; 
    end
    
    index = randi(numel(r),1); % random leave one objects

    posIndex(r(index))=[];
    polyvec(r(index)) =[];
end


%{
figure;
plot(polyvec);
xlim([-100,100]);
axis equal;

%}







