close all;
clear all;
clc;

imgFile = '/scratch/voc07/images/export-image-0.png';
jsonFile = '/scratch/voc07/images/export-image-0.json';

img = imread(imgFile);
imshow(img);

data = loadjson(jsonFile,'ArrayToStruct',1);

scores = zeros(length(data),1);
for i=1:length(data.objects)
    scores(i) = data.objects{i}.score;
end


[val, indx] = sort(scores);
for i=1:length(indx)
    
    if val(i) > 0.5
    
    rect = [data.objects{indx(i)}.bndbox.xmin, ...
            data.objects{indx(i)}.bndbox.ymin, ...
            data.objects{indx(i)}.bndbox.xmax - data.objects{indx(i)}.bndbox.xmin, ...
            data.objects{indx(i)}.bndbox.ymax - data.objects{indx(i)}.bndbox.ymin];
    
      
        
    rectangle('Position',rect,'edgecolor','red');
    pause;
    end
end