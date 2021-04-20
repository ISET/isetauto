function piFWResourceDownload(acq, dstDir)

if ~exist(dstDir,'dir'), mkdir(dstDir);end
dstFile = fullfile(dstDir, 'tmp.zip');
for ii = 1:length(acq.files)
    if strcmpi(acq.files{ii}.type,'CG Resource')
        acq.downloadFile(acq.files{ii}.name, dstFile);
    end
end
unzip(dstFile, dstDir);
% addpath(genpath(dstDir))
delete(dstFile);
end