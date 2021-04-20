function recipe = piFWRecipeDownload(acq,varargin)


tmpDir = [pwd, '/tmp',num2str(randi(1000))];
mkdir(tmpDir);
tmpRecipe = [tmpDir, '/tmp.json'];
for ii = 1:length(acq.files)
    if contains(acq.files{ii}.name, 'recipe')
        acq.downloadFile(acq.files{ii}.name, tmpRecipe);
        break;
    end
end
recipe = piJson2Recipe(tmpRecipe);
rmdir(tmpDir,'s');
end