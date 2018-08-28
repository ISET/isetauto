%% Find and remove white points in the image
%
% The rendering algorithm sometimes produces these unwanted white spots
% just, well, because of ray tracing.

%% Here is an image that has a bunch
foo = load('oi_fisheye_2048.mat');
oi = foo.oi_fisheye_2048psamples;

ieAddObject(oi); oiWindow;

%% Have a look.  I think you can see a bunch of white pixels
illuminance = oiGet(oi,'illuminance');
illuminance = ieScale(illuminance,0,1);
logIlluminance = log10(illuminance);
vcNewGraphWin;
imagesc(logIlluminance);
colorbar;

% Compute the local derivative, comparing each point to its neighbors
g = -1*ones(3,3)/8;
g(2,2) = 1;
sum(g(:))
dLogIlluminance = conv2(logIlluminance,g,'same');

%% Replace the Inf points with the average of their neighbors


vcNewGraphWin;
imagesc(dLogIlluminance);
colorbar;
hist(dLogIlluminance(:),100);


%% Find points  more than XX larger than the average of their neighbors 
brightSpots = (dLogIlluminance > log10(5));
[r,c] = find(brightSpots);

vcNewGraphWin;
imagesc(brightSpots);

g = ones(3,3)/9;
isolatedBrightSpots = conv2(brightSpots,g);
sum(isolatedBrightSpots(:))

% Sometimes we have white points within the local neighborhood, which
% limits the effectiveness
multipleSpots = (isolatedBrightSpots > 1);
% Good when this is zero
sum(multipleSpots(:))

%% Calculate the illuminance around the bright spots

g = ones(3,3)/8;
g(2,2) = 0;
photons = oiGet(oi,'photons');
localSurround = zeros(size(photons));
for ii=1:nWave
    localSurround(:,:,ii) = conv2(photons(:,:,ii),g,'same');
end

%%
correctedPhotons = photons;
for ii = 1:length(r)
    correctedPhotons(r(ii),c(ii),:) = localSurround(r(ii),c(ii),:);
end

%% It seems like the photons have the wrong spectrum
% They are white, and thus not matched in color to the surrounding pixels
% We need to replace the full spectrum of the white points with the average
% spectrum of the surrounding points, not just scale the white pixels


oi = oiSet(oi,'photons',correctedPhotons);
ieAddObject(oi); oiWindow;


%%


%%