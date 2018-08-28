%% Shanghai auto talk
%
% This runs OK

d = '/Users/wandell/Google Drive/Talks/SCIEN/20180814 Shanghai (Deng SAE)/Brian_shanghai/newimages';
chdir(d);

img = exrread('scene180_1920.exr');
img = tonemap(img,'AdjustSaturation',2);
vcNewGraphWin; imshow(img);

s = sceneFromFile(img,'rgb',100,displayCreate('LCD-Apple',400:10:700));
s = sceneAdjustIlluminant(s,'D65.mat');
s = sceneSet(s,'fov',45);
ieAddObject(s); sceneWindow;

%%
oi = oiCreate;
oi = oiCompute(oi,s);
ieAddObject(oi); oiWindow;

%%
sensor = sensorCreate;
sensor = sensorSetSizeToFOV(sensor,sceneGet(s,'fov'));
sensor = sensorCompute(sensor,oi);
ieAddObject(sensor); sensorWindow;

%% 
ip = ipCreate;
ip = ipCompute(ip,sensor);
ieAddObject(ip); ipWindow;

%%  STOP

img = double(imread('pinhole_5.png'));
img = ieScale(img,0,1);
imtool(img.^0.5);

s = sceneFromFile(img,'rgb',100,displayCreate('LCD-Apple'));
s = sceneAdjustIlluminant(s,'D65.mat');
ieAddObject(s); sceneWindow;

%%
foo = load('pinholes2images1024.mat');
scene = foo.pinholes{1};
ieAddObject(scene); sceneWindow;
