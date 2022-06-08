assetdirectory = '/Volumes/SSDZhenyi/Ford Project/PBRT_assets';
assetTypeList = {'road','cars','animal','trees'};
for aa = 1:numel(assetTypeList)
    assetType = assetTypeList{aa};
    assetList = dir(fullfile(assetdirectory, assetType));
    assetList = assetList(3:end);
    %%
    for ii = 1:numel(assetList)
        if assetList(ii).isdir
            [~, thisName] = fileparts(assetList(ii).name);
            if strcmp(assetType,'road')
                pbrtFile = fullfile(assetdirectory,assetType,thisName,thisName,[thisName,'.pbrt']);
                recipeMat = fullfile(assetdirectory,assetType,thisName,thisName,[thisName,'.mat']);
            else
                pbrtFile = fullfile(assetdirectory,assetType,thisName,[thisName,'.pbrt']);
                recipeMat = fullfile(assetdirectory,assetType,thisName,[thisName,'.mat']);
            end

            if exist(pbrtFile,'file')
                recipe = piRead(pbrtFile);
                save(recipeMat,'recipe');
            end
        end
    end
end
disp('DONE!')