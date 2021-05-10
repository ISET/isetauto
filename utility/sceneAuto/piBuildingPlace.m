function assetsPlaced = piBuildingPlace(assetsList,buildingPosList)
% For building assets, place the assets exactly by names (same with piSidewalkPlace.m)
%
% Syntax
%   piBuildingPlace(assetsList,buildingPosList)
%
% Description
%  Part of the SUSO code that positions the buildings onto the road.  
%
% Inputs
%  assetList       - The building assets
%  buildingPosList - Building positions
% Key/val
%  N/A
%
% Return
%  assetsPlaced
%
% Zhenyi Liu
%
% See also
%

%% Make a cell array of the names associated with each position
for ii = 1: length(buildingPosList)
    PosList{ii} = buildingPosList(ii).name;
end

% Check that are unique
PosListCheck = unique(PosList);
for kk = 1:length(PosListCheck)
    count = 1;
    for jj = 1: length(PosList)
        if isequal(PosListCheck(kk),PosList(jj))
            buildingPosList_tmp(kk).name = PosListCheck(kk);
            buildingPosList_tmp(kk).count = count;
            count = count+1;
        end
    end
end

%% 
asset = assetsList;
for ii = 1: length(buildingPosList_tmp)
%     gg=1;
    n = buildingPosList_tmp(ii).count;        
        for dd = 1: length(asset)
            if isequal(asset(dd).name,buildingPosList_tmp(ii).name{1})
                assets_updated(ii) = asset(dd);
%                 pos = asset(dd).position;
%                 rot = asset(dd).rotate;
%                 asset(dd).position = repmat(pos,1,uint8(buildingPosList_tmp(ii).count));
%                 asset(dd).rotate = repmat(rot,1,uint8(buildingPosList_tmp(ii).count));
                position=cell(n,1);
                rotationY=cell(n,1);
                gg=1;
                for jj = 1:length(buildingPosList)
                    if isequal(buildingPosList_tmp(ii).name{1},buildingPosList(jj).name)
                        position{gg} = buildingPosList(jj).position;
                        rotationY{gg} = buildingPosList(jj).rotate;
                        gg = gg+1;
                    end
                end
                assets_updated(ii).position = position;
                assets_updated(ii).rotation =[];
                for rr = 1:numel(rotationY)
                    assets_updated(ii).rotation{rr} = piRotationMatrix('y',rotationY{rr});
                end
            end
        end
end

assetsPlaced = assets_updated;

% the reason why we keep this part seperate is that when we need to check which
% buidling does not look correct in rendered image, we want to know the
% exact asset name, instead of the class name ---zhenyi
% debug --09/30
%{
for jj = 1:length(assetsPlaced)
    if ~isequal(lower(assetsPlaced(jj).name),'camera') && ...
            ~piContains(lower(assetsPlaced(jj).name),'light')
        name = assetsPlaced(jj).name;
        assetsPlaced(jj).name = sprintf('building_%s',name);
    end
end
%}
end