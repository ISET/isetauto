%% Create a sub-set from VOC dataset containing only selected classes

close all;
clear all;
clc;

recipe = 'MultiObject-Pinhole';
lightLevels = [0.0, 0.1, 1, 10, 100, 1000, 10000];

expTime = 0.015;

type = 'MC';
mode = sprintf('%s_luxLevel_mix',type);

sourceDir = fullfile('/','scratch','Datasets','MultiObject-Pinhole');
destDir = fullfile('/','scratch','Datasets','MultiObject-Pinhole');

cmap = jet(3);
%These class ids correspond to the ones from PASCAL VOC
labelMap(1).name = 'car';
labelMap(1).id = 7;
labelMap(1).color = cmap(1,:);
labelMap(2).name = 'person';
labelMap(2).id = 15;
labelMap(2).color = cmap(2,:);
labelMap(3).name = 'bus';
labelMap(3).id = 6;
labelMap(3).color = cmap(3,:);

% Prepare the directory structure
xVal = {'trainval','test'};
for i=1:length(xVal)
    dirName = fullfile(destDir,xVal{i},mode,'Annotations');
    if exist(dirName,'dir') == false, mkdir(dirName); end;
    dirName = fullfile(destDir,xVal{i},mode,'JPEGImages');
    if exist(dirName,'dir') == false, mkdir(dirName); end;
    dirName = fullfile(destDir,xVal{i},mode,'ImageSets','Main');
    if exist(dirName,'dir') == false, mkdir(dirName); end;
end

% Prepare files listing which image contains which class
fids = cell(length(xVal),length(labelMap));
for x=1:length(xVal)
    for v=1:length(labelMap)
        
        fName = fullfile(destDir,xVal{x},mode,'ImageSets','Main',sprintf('%s_%s.txt',lower(labelMap(v).name),xVal{x}));
        fids{x,v} = fopen(fName,'w');
        
    end
end
    

for i=1:length(xVal)
   
    fNames = cell(1,length(lightLevels));
    for j=1:length(lightLevels)
        subMode = sprintf('%s_%i_luxLevel_%.1f',type,expTime*1000,lightLevels(j));
        fNames{j} = dir(fullfile(sourceDir,xVal{i},subMode,'JPEGImages','*.png'));
    end
    
    for j=1:length(fNames{1})
        
        id = mod(j-1,length(lightLevels))+1;
        subMode = sprintf('%s_%i_luxLevel_%.1f',type,expTime*1000,lightLevels(id));
        
        inputImageFile = fullfile(sourceDir,xVal{i},subMode,'JPEGImages',fNames{id}(j).name);
        [~, inputFileName] = fileparts(inputImageFile);
        inputLabelFile = fullfile(sourceDir,xVal{i},subMode,'Annotations',sprintf('%s.xml',inputFileName));
        
        destImageFile = fullfile(destDir,xVal{i},mode,'JPEGImages',fNames{id}(j).name);
        destLabelFile = fullfile(destDir,xVal{i},mode,'Annotations',sprintf('%s.xml',inputFileName));
        
        copyfile(inputImageFile,destImageFile);
        copyfile(inputLabelFile,destLabelFile);
        
        data = xml2struct(inputLabelFile);
        annotation = data.annotation;
        
        sel = cellfun(@(x) strcmp(x,xVal{i}),xVal);
       
        for c=1:length(labelMap)
            objectPresence = -1;
            for o=1:length(annotation.object)
                annotation.object = cat(1,{},annotation.object);
                if strcmpi(labelMap(c).name,annotation.object{o}.name)
                    objectPresence = 1;
                end
            end
            fprintf(fids{sel,c},'%s %i\n',inputFileName,objectPresence);
        end
        
    end
end

for i=1:numel(fids)
    fclose(fids{i});
end

%{
for i=1:numTestImages
   
    inputId = mod(i-1,length(lightLevels))+1;
    
    inputImg = 
    
    
    
end







sourceClassFile = fullfile(vocPath,'ImageSets','Main',sprintf('%s_%s.txt',classes{1},mode));
fid = fopen(sourceClassFile,'r');
data = textscan(fid,'%d %d');
fclose(fid);

destClassFile = fullfile(resPath,'ImageSets','Main',sprintf('%s_%s.txt',classes{1},mode));
fid = fopen(destClassFile,'w');

for i=1:length(data{1})
    if (data{2}(i) == -1)
        continue;
    end
    
    fileName = data{1}(i);
    
    srcFile = fullfile(vocPath,'Annotations',sprintf('%06i.xml',fileName));
    destFile = fullfile(resPath,'Annotations',sprintf('%06i.xml',fileName));
    copyfile(srcFile,destFile);
    
    srcFile = fullfile(vocPath,'JPEGImages',sprintf('%06i.jpg',fileName));
    destFile = fullfile(resPath,'JPEGImages',sprintf('%06i.jpg',fileName));
    copyfile(srcFile,destFile);
    
    fprintf(fid,'%06i %06i\n',fileName,data{2}(i));
    
end

fclose(fid);
fprintf('Done!\n');


%}