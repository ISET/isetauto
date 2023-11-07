% generate light mask on optical images
pinhole_mask = dir('/acorn/data/iset/isetauto/Ford/Flare_paper/Flare_free/lightmask/*.png');
p4a = dir('/acorn/data/iset/isetauto/Ford/Flare_paper/Flare_free/pixel4a/*.png');

parfor ii = 1:numel(p4a)
    img = imread(fullfile(p4a(ii).folder, p4a(ii).name));
    img = double(rgb2gray(img))/255;
    img = img/max(img(:));
    mask = zeros(size(img));
    mask(img>0.7)=1;

    ph_mask =imread(fullfile(pinhole_mask(1).folder, p4a(ii).name));

    ccomp = bwconncomp(ph_mask);
    newmask = zeros(size(img));

    for mm = 1:ccomp.NumObjects
        [rows,cols] = ind2sub(size(mask), ccomp.PixelIdxList{mm});
        lightPos= round([mean(rows), mean(cols)]);
        pixels = findnearbypixels(mask, lightPos, 30);
        for rr = 1:size(pixels,1)
            newmask(pixels(rr,1),pixels(rr,2)) = 1;
        end
    end
    imwrite(newmask, sprintf('/acorn/data/iset/isetauto/Ford/Flare_paper/Flare_free/pixel4a_lightmask/%s',p4a(ii).name));
    disp(ii)
end

function pixels = findnearbypixels(img, pos, nsize)

% Define the pixel coordinates
x = pos(2);
y = pos(1);

% Define the size of the neighboring region
neighborhood_size = nsize;

% Get the neighborhood around the pixel
x_min = max(1, x-neighborhood_size);
x_max = min(size(img,2), x+neighborhood_size);
y_min = max(1, y-neighborhood_size);
y_max = min(size(img,1), y+neighborhood_size);
neighborhood = img(y_min:y_max, x_min:x_max);

% Find the pixels with values equal to 1
[r, c] = find(neighborhood == 1);

% Print the coordinates of the pixels with values greater than 1
for i = 1:length(r)
%     fprintf('Pixel (%d, %d) has value %d\n', x_min+c(i)-1, y_min+r(i)-1, neighborhood(r(i), c(i)));
    pixels(i,1) = y_min+r(i)-1;
    pixels(i,2) = x_min+c(i)-1;
end

end