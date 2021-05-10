function assetsPlaced = piSidewalkPlace(assetList,assetsPosList)
% Place sidewalk assets exactly by names
%
% Syntax
%
% Description
%
% Inputs
%   assetList
%   AssetsPosList
%
% Key/val pairs
%
% Outputs
%   assetsPlaced
%
%
%
% Zhenyi
%
% See also
%

%%

for ii = 1: length(assetsPosList)
    PosList{ii} = assetsPosList(ii).name;
end

PosListCheck = unique(PosList);
for kk = 1:length(PosListCheck)
    count = 1;
    for jj = 1: length(PosList)
        if isequal(PosListCheck(kk),PosList(jj))
            assetPosList_tmp(kk).name = PosListCheck(kk);
            assetPosList_tmp(kk).count = count;
            count = count+1;
        end
    end
end

%%
for ii = 1: length(assetPosList_tmp)
    n = assetPosList_tmp(ii).count;      
        for dd = 1: length(assetList)
            if isequal(assetList(dd).name,assetPosList_tmp(ii).name{1})
                assets_updated(ii) = assetList(dd);
%                 pos = [0;0;0];
%                 rot = piRotationMatrix;
%                 assetList(dd).position = repmat(pos,1,uint8(assetPosList_tmp(ii).count));
%                 assetList(dd).rotation = repmat(rot,1,uint8(assetPosList_tmp(ii).count));
                position=cell(n,1);
                rotationY=cell(n,1);
                gg=1;
                for jj = 1:length(assetsPosList)
                    if isequal(assetPosList_tmp(ii).name{1},assetsPosList(jj).name)
                        position{gg} = assetsPosList(jj).position;
                        rotationY{gg} = assetsPosList(jj).rotate;
                        gg = gg+1;
                    end
                end
                
                assets_updated(ii).position = position;
                assets_updated(ii).rotation =[];
                for rr = 1:numel(rotationY)
                    assets_updated(ii).rotation{rr} = piRotationMatrix('y',rotationY{rr});
                end
%                 assets_updated(ii).fwInfo   = assetList(dd).fwInfo;
            end
        end
end

assetsPlaced = assets_updated;

end







