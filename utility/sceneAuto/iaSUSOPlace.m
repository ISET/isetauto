function assetsPlaced = iaSUSOPlace(assetList,assetsPosList)
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
% Zhenyi updated 2021.
%
% See also
%

%%
% Get asset names list, so that we can check the uniqueness of the assets being
% used.
PosList = cell(numel(assetsPosList),1);
for ii = 1: numel(assetsPosList)
    PosList{ii} = assetsPosList(ii).name;
end

PosListCheck = unique(PosList);
assetPosList_tmp = struct();

for kk = 1:numel(PosListCheck)
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
    nInstance = assetPosList_tmp(ii).count;      
        for dd = 1: length(assetList)
            if isequal(assetList(dd).name,assetPosList_tmp(ii).name{1})
                assetsPlaced(ii) = assetList(dd);
                position         = cell(nInstance,1);
                rotationY        = cell(nInstance,1);
                gg=1;
                for jj = 1:length(assetsPosList)
                    if isequal(assetPosList_tmp(ii).name{1}, assetsPosList(jj).name)
                        position{gg}  = assetsPosList(jj).position;
                        rotationY{gg} = assetsPosList(jj).rotate;
                        gg = gg+1;
                    end
                end
                assetsPlaced(ii).position = position;
                assetsPlaced(ii).rotation = [];
                for rr = 1:numel(rotationY)
                    assetsPlaced(ii).rotation{rr} = piRotationMatrix('y',rotationY{rr});
                end
                assetPlaced(ii).count = nInstance;
            end
        end
end

end







