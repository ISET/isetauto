function obj = overlappedRemove(obj)
% We check on and off objects, overlapped objects are removed
% On road
assetInfo = assetlib();
onroadClassRank = {'car', 'truck', 'bus', 'pedestrian', 'biker', 'animal'};
offroadClassRank = {'pedestrian','animal','tree'};

onroadClass = fieldnames(obj.onroad);

for ii = 1:numel(onroadClass)
    obj.onroad.(onroadClass{ii}) = overlapCheckOne(assetInfo, obj.onroad.(onroadClass{ii}), 1.5, 1.5);
end

numCheck = 1;
while numCheck < numel(onroadClassRank)-1
    % make sure types of objects on road are in the preset classes array.
    if ~contains(onroadClassRank{numCheck}, onroadClass), numCheck = numCheck+1; continue; end
    for cc = numCheck+1:numel(onroadClassRank)
        class_A = onroadClassRank{numCheck};
        class_B = onroadClassRank{cc};

        if ~contains(class_A, onroadClass) || ~contains(class_B, onroadClass)
            continue; 
        end

        obj.onroad.(class_A) = overlapCheckTwo(assetInfo, obj.onroad.(class_A), obj.onroad.(class_B), [1.5, 1.5],[2, 1.5]);
    end
    numCheck = numCheck+1;
end

offroadClass = fieldnames(obj.offroad);

for ii = 1:numel(offroadClass)
    if contains(offroadClass{ii},{'pedestrian','animal'})
        obj.offroad.(offroadClass{ii}) = overlapCheckOne(assetInfo, obj.offroad.(offroadClass{ii}), 1.5, 1.5);
    end
end

numCheck = 1;
while numCheck < numel(offroadClassRank)-1
    if ~contains(offroadClassRank{numCheck}, offroadClass), numCheck = numCheck+1; continue; end
    for cc = numCheck+1:numel(offroadClassRank)  
        class_A = offroadClassRank{numCheck};
        class_B = offroadClassRank{cc};
        if ~contains(class_A, offroadClass) || ~contains(class_B, offroadClass)
            continue;
        end

        obj.offroad.(class_A) = overlapCheckTwo(assetInfo, obj.offroad.(class_A), obj.offroad.(class_B), [1.5, 1.5], [2, 1.5]);
    end
    numCheck = numCheck+1;
end

end
function S1 = overlapCheckTwo(assetInfo, S1, S,offsetScale_S1,offsetScale_S)
% Check whether the objects in S1 will overlap with S, if it overlaps, the
% object will be deleted.
for ii  = 1:numel(S1.lane)
    if S1.number(ii)==0 ||S.number(ii)==0
        continue
    end
    indexMatched = find(contains(S.lane, S1.lane{ii}),1);
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
        
        [centerX, centerY] = centroid(objPatch_S1);

        if isfield(objInfo_S1, 'frontoverhang')
            objPatch_S1 = translate(objPatch_S1, [- 2*centerX + objInfo_S1.frontoverhang(1), -centerY]);
        else
            objPatch_S1 = translate(objPatch_S1, [- centerX, -centerY]);
        end
        
        % rotate around [0, 0]
        objPatch_S1 = rotate(objPatch_S1, rad2deg(rotList_S1(jj)), [0, 0]);
        % then translate
        objPatch_S1 = translate(objPatch_S1, posList_S1(jj,1), posList_S1(jj,2)); 
      
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

            [centerX, centerY] = centroid(objPatch_S);

            if isfield(objInfo_S, 'frontoverhang')
                objPatch_S = translate(objPatch_S, [- 2*centerX + objInfo_S.frontoverhang(1), -centerY]);
            else
                objPatch_S = translate(objPatch_S, [- centerX, -centerY]);
            end

            objPatch_S = rotate(objPatch_S, rad2deg(rotList_S(ll)), [0, 0]); 

            objPatch_S = translate(objPatch_S, posList_S(ll,1), posList_S(ll,2)); 

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
 
    if ~isfield(S,'number') || S.number(ii) == 0
        continue;
    end
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

        [centerX, centerY] = centroid(objPatch);

        if isfield(objInfo, 'frontoverhang')
            objPatch = translate(objPatch, [- 2*centerX + objInfo.frontoverhang(1), -centerY]);
        else
            objPatch = translate(objPatch, [- centerX, -centerY]);
        end

        objPatch = rotate(objPatch, rad2deg(rotList(jj)), [0, 0]);

        objPatch = translate(objPatch, posList(jj,1), posList(jj,2));

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







