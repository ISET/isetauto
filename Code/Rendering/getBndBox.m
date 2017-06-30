function [bndbox, occluded, truncated] = getBndBox(labelImage, label)

h = size(labelImage,1);
w = size(labelImage,2);

indicator = labelImage == label;

vert = find(sum(indicator) > 0);
horz = find(sum(indicator,2) > 0);

xmin = min(vert);
xmax = max(vert);

ymin = min(horz);
ymax = max(horz);

bndbox = [xmin, xmax, ymin, ymax];

truncated = 0;
if sum(bndbox == 1 | bndbox == h | bndbox == w) ~= 0
    truncated = 1;
end

cc = bwconncomp(indicator);

occluded = 0;
if cc.NumObjects >= 2
    occluded = 1;
end


