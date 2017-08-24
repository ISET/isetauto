% This script defines some of the constant variable names that are used
% throughout the project.
%
% Copyright, Henryk Blasinski 2017.

[ codePath, parentPath ] = nnGenRootPath();

global assetDir
assetDir = fullfile('/','share','wandell','data','NN_Camera_Generalization','Assets');
global lensDir;
lensDir = fullfile(parentPath,'Parameters');

%% City 1

assets.city(1).path = fullfile(assetDir,'City','City_1a.obj');

assets.city(1).road(1).xrange = [-1.5, 1.5];
assets.city(1).road(1).yrange = [-45.0, 45.0];
assets.city(1).road(1).zrange = [0, 0];
assets.city(1).road(1).centerline.xrange = [0, 0];
assets.city(1).road(1).centerline.yrange = [-45.0, 45.0];
assets.city(1).road(1).centerline.zrange = [0, 0];
assets.city(1).road(1).laneSeparation = 3;
assets.city(1).road(1).lane(1).xrange = [-1.5 -1.500];
assets.city(1).road(1).lane(1).yrange = [-45.000 45.000];
assets.city(1).road(1).lane(1).zrange = [0, 0];
assets.city(1).road(1).lane(1).orientation = 90;
assets.city(1).road(1).lane(2).xrange = [+1.500 +1.500];
assets.city(1).road(1).lane(2).yrange = [-45.000 45.000];
assets.city(1).road(1).lane(2).zrange = [0, 0]; 
assets.city(1).road(1).lane(2).orientation = 270;

assets.city(1).road(2).xrange = [-45.0, 45.0];
assets.city(1).road(2).yrange = [-1.5, 1.5];
assets.city(1).road(2).zrange = [0, 0];
assets.city(1).road(2).centerline.xrange = [-45.0, 45.0];
assets.city(1).road(2).centerline.yrange = [0, 0];
assets.city(1).road(2).centerline.zrange = [0, 0];
assets.city(1).road(2).laneSeparation = 3.0;
assets.city(1).road(2).lane(1).xrange = [-45.000 45.000];
assets.city(1).road(2).lane(1).yrange = [-1.500 -1.500];
assets.city(1).road(2).lane(1).zrange = [0, 0];
assets.city(1).road(2).lane(1).orientation = 0;
assets.city(1).road(2).lane(2).xrange = [-45.000 45.000];
assets.city(1).road(2).lane(2).yrange = [1.500 1.500];
assets.city(1).road(2).lane(2).zrange = [0, 0];
assets.city(1).road(2).lane(2).orientation = 180;

assets.city(1).sidewalk(1).xrange = [-7.297, -3.800];
assets.city(1).sidewalk(1).yrange = [7.312, 39.562];
assets.city(1).sidewalk(1).zrange = [-0.110, -0.110];
assets.city(1).sidewalk(2).xrange = [3.369, 7.035];
assets.city(1).sidewalk(2).yrange = [7.312, 39.562];
assets.city(1).sidewalk(2).zrange = [-.110, -.110];
assets.city(1).sidewalk(3).xrange = [14.202, 21.369];
assets.city(1).sidewalk(3).yrange = [7.312, 14.479];
assets.city(1).sidewalk(3).zrange = [-.110, -.110];
assets.city(1).sidewalk(4).xrange = [21.369, 39.285];
assets.city(1).sidewalk(4).yrange = [3.816, 7.312];
assets.city(1).sidewalk(4).zrange = [-.110, -.110];
assets.city(1).sidewalk(5).xrange = [-39.547, -7.297];
assets.city(1).sidewalk(5).yrange = [-3.524, -1.000];
assets.city(1).sidewalk(5).zrange = [-.110, -.110];
assets.city(1).sidewalk(6).xrange = [-7.297, -3.631];
assets.city(1).sidewalk(6).yrange = [-39.270, -14.187];
assets.city(1).sidewalk(6).zrange = [-.110, -.110];
assets.city(1).sidewalk(7).xrange = [3.539, 7.035];
assets.city(1).sidewalk(7).yrange = [-39.270, -7.020];
assets.city(1).sidewalk(7).zrange = [-.110, -.110];
assets.city(1).sidewalk(8).xrange = [6.952, 39.285];
assets.city(1).sidewalk(8).yrange = [-7.020, -3.524];
assets.city(1).sidewalk(8).zrange = [-.110, -.110];

%% City 2

assets.city(2).path = fullfile(assetDir,'City','City_2a.obj');
assets.city(2).road(1).xrange = [-43.117, -18.00];
assets.city(2).road(1).yrange = [5.619, 8.619];
assets.city(2).road(1).zrange = [0, 0];
assets.city(2).road(1).centerline.xrange = [-43.117 -18.000];
assets.city(2).road(1).centerline.yrange = [7.119, 7.119];
assets.city(2).road(1).centerline.zrange = [0, 0];
assets.city(2).road(1).laneSeparation = 3;
assets.city(2).road(1).lane(1).xrange = [-43.117 -18.000];
assets.city(2).road(1).lane(1).yrange = [5.619 5.619];
assets.city(2).road(1).lane(1).zrange = [0, 0];
assets.city(2).road(1).lane(1).orientation = 0;
assets.city(2).road(1).lane(2).xrange = [-43.117 -18.000];
assets.city(2).road(1).lane(2).yrange = [8.619 8.619];
assets.city(2).road(1).lane(2).zrange = [0, 0]; 
assets.city(2).road(1).lane(2).orientation = 180;

assets.city(2).road(2).xrange = [-15,950, -12.950];
assets.city(2).road(2).yrange = [-43.047 43.047];
assets.city(2).road(2).zrange = [0, 0];
assets.city(2).road(2).centerline.xrange = [-14.450, -14.450];
assets.city(2).road(2).centerline.yrange = [-43.047 43.047];
assets.city(2).road(2).centerline.zrange = [0, 0];
assets.city(2).road(2).laneSeparation = 3;
assets.city(2).road(2).lane(1).xrange = [-12.950 -12.950];
assets.city(2).road(2).lane(1).yrange = [-43.047 43.047];
assets.city(2).road(2).lane(1).zrange = [0, 0];
assets.city(2).road(2).lane(1).orientation = 90;
assets.city(2).road(2).lane(2).xrange = [-15.950, -15.950];
assets.city(2).road(2).lane(2).yrange = [-43.047 43.047];
assets.city(2).road(2).lane(2).zrange = [0, 0];
assets.city(2).road(2).lane(2).orientation = 270;

assets.city(2).road(3).xrange = [-10.00 42.884];
assets.city(2).road(3).yrange = [-15.81, -12.881];
assets.city(2).road(3).zrange = [0, 0];
assets.city(2).road(3).centerline.xrange = [-10.00 42.884];
assets.city(2).road(3).centerline.yrange = [-14.31, -14.31];
assets.city(2).road(3).centerline.zrange = [0, 0];
assets.city(2).road(3).laneSeparation = 3;
assets.city(2).road(3).lane(1).xrange = [-10.00 42.884];
assets.city(2).road(3).lane(1).yrange = [-15.81 -15.81];
assets.city(2).road(3).lane(1).zrange = [0, 0];
assets.city(2).road(3).lane(1).orientation = 0;
assets.city(2).road(3).lane(2).xrange = [-10.00 42.884];
assets.city(2).road(3).lane(2).yrange = [-12.881 -12.881];
assets.city(2).road(3).lane(2).zrange = [0, 0];
assets.city(2).road(3).lane(2).orientation = 180;


assets.city(2).sidewalk(1).xrange = [-10.779, -7.325];
assets.city(2).sidewalk(1).yrange = [-7.214, 35.785];
assets.city(2).sidewalk(1).zrange = [-0.120, -0.120];
assets.city(2).sidewalk(2).xrange = [-21.617, -18.120];
assets.city(2).sidewalk(2).yrange = [14.285, 39.369];
assets.city(2).sidewalk(2).zrange = [-0.120, -0.120];
assets.city(2).sidewalk(3).xrange = [-39.534, -21.534];
assets.city(2).sidewalk(3).yrange = [10.789, 14.285];
assets.city(2).sidewalk(3).zrange = [-0.120, -0.120];
assets.city(2).sidewalk(4).xrange = [-39.534, -21.575];
assets.city(2).sidewalk(4).yrange = [-0.47, 3.448];
assets.city(2).sidewalk(4).zrange = [-0.120, -0.120];
assets.city(2).sidewalk(5).xrange = [-21.575, -17.950];
assets.city(2).sidewalk(5).yrange = [-0.047, -39.464];
assets.city(2).sidewalk(5).zrange = [-0.120, -0.120];
assets.city(2).sidewalk(6).xrange = [-7.367, 21.385];
assets.city(2).sidewalk(6).yrange = [-25.000, -18.051];
assets.city(2).sidewalk(6).zrange = [-0.120, -0.120];
assets.city(2).sidewalk(7).xrange = [-7.325, 39.790];
assets.city(2).sidewalk(7).yrange = [-10.732, -7.214];
assets.city(2).sidewalk(7).zrange = [-0.120, -0.120];

%% City 3

assets.city(3).path = fullfile(assetDir,'City','City_3a.obj');
assets.city(2).road(1).xrange = [-15.950, -12.950];
assets.city(2).road(1).yrange = [-43.047, 42.952];
assets.city(2).road(1).zrange = [0, 0];
assets.city(2).road(1).centerline.xrange = [-14.45, -14.45];
assets.city(2).road(1).centerline.yrange = [-43.047, 42.952];
assets.city(2).road(1).centerline.zrange = [0, 0];
assets.city(2).road(1).laneSeparation = 3;
assets.city(3).road(1).lane(1).xrange = [-15.950 -15.950];
assets.city(3).road(1).lane(1).yrange = [-43.047, 42.952];
assets.city(3).road(1).lane(1).zrange = [0, 0];
assets.city(3).road(1).lane(1).orientation = 90;
assets.city(3).road(1).lane(2).xrange = [-12.950 -12.950];
assets.city(3).road(1).lane(2).yrange = [-43.047, 42.952];
assets.city(3).road(1).lane(2).zrange = [0, 0]; 
assets.city(3).road(1).lane(2).orientation = 270;


assets.city(3).sidewalk(1).xrange = [-35.948,-18.120];
assets.city(3).sidewalk(1).yrange = [28.619, 42.782];
assets.city(3).sidewalk(1).zrange = [-0.120, -0.120];
assets.city(3).sidewalk(2).xrange = [-28.781, -17.950];
assets.city(3).sidewalk(2).yrange = [-39.464, 7.119];
assets.city(3).sidewalk(2).zrange = [-0.120, -0.120];
assets.city(3).sidewalk(3).xrange = [-10.779, -7.283];
assets.city(3).sidewalk(3).yrange = [-43.047, 39.369];
assets.city(3).sidewalk(3).zrange = [-0.120, -0.120];

%% City 4

assets.city(4).path = fullfile(assetDir,'City','City_4a.obj');
assets.city(2).road(1).xrange = [-43.115, -2.000];
assets.city(2).road(1).yrange = [-1.5, 1.5];
assets.city(2).road(1).zrange = [0, 0];
assets.city(2).road(1).centerline.xrange = [-43.115, -2.000];
assets.city(2).road(1).centerline.yrange = [0, 0];
assets.city(2).road(1).centerline.zrange = [0, 0];
assets.city(2).road(1).laneSeparation = 3;
assets.city(4).road(1).lane(1).xrange = [-43.115, -2.000];
assets.city(4).road(1).lane(1).yrange = [1.550 1.550];
assets.city(4).road(1).lane(1).zrange = [0, 0];
assets.city(4).road(1).lane(1).orientation = 180;
assets.city(4).road(1).lane(2).xrange = [-43.115, -2.000];
assets.city(4).road(1).lane(2).yrange = [-1.50, -1.50];
assets.city(4).road(1).lane(2).zrange = [0, 0]; 
assets.city(4).road(1).lane(2).orientation = 0;

assets.city(4).road(2).xrange = [-1.6, 1.6];
assets.city(4).road(2).yrange = [-43.00 40.00];
assets.city(4).road(2).zrange = [0, 0];
assets.city(4).road(2).centerline.xrange = [0, 0];
assets.city(4).road(2).centerline.yrange = [-43.00 40.00];
assets.city(4).road(2).centerline.zrange = [0, 0];
assets.city(4).road(2).laneSeparation = 3;
assets.city(4).road(2).lane(1).xrange = [1.60 1.60];
assets.city(4).road(2).lane(1).yrange = [-43.00 40.00];
assets.city(4).road(2).lane(1).zrange = [0, 0];
assets.city(4).road(2).lane(1).orientation = 270;
assets.city(4).road(2).lane(2).xrange = [-1.60 -1.60];
assets.city(4).road(2).lane(2).yrange = [-43.00 40.00];
assets.city(4).road(2).lane(2).zrange = [0, 0]; 
assets.city(4).road(2).lane(2).orientation = 90;

assets.city(4).sidewalk(1).xrange = [-7.282, -3.785];
assets.city(4).sidewalk(1).yrange = [-7.119, 39.369];
assets.city(4).sidewalk(1).zrange = [-0.110, -0.110];
assets.city(4).sidewalk(2).xrange = [-39.532, -7.198];
assets.city(4).sidewalk(2).yrange = [3.622, 7.119];
assets.city(4).sidewalk(2).zrange = [-0.110, -0.110];
assets.city(4).sidewalk(3).xrange = [-39.532, -3.785];
assets.city(4).sidewalk(3).yrange = [-14.381, -3.718];
assets.city(4).sidewalk(3).zrange = [-0.110, -0.110];
assets.city(4).sidewalk(4).xrange = [-7.282, -3.615];
assets.city(4).sidewalk(4).yrange = [-39.464, -14.381];
assets.city(4).sidewalk(4).zrange = [-0.110, -0.110];
assets.city(4).sidewalk(5).xrange = [3.555, 7.051];
assets.city(4).sidewalk(5).yrange = [-39.464, 39.364];
assets.city(4).sidewalk(5).zrange = [-0.110, -0.110];




assets.car(1).path = fullfile(assetDir,'MercedesCClass','Car_1.obj');
assets.car(1).model = [];
assets.car(2).path = fullfile(assetDir,'Fiat500','Car_2.obj');
assets.car(2).model = [];
assets.car(3).path = fullfile(assetDir,'MercedesSprinter','Car_3.obj');
assets.car(3).model = [];
assets.car(4).path = fullfile(assetDir,'ToyotaCamry','Car_4.obj');
assets.car(4).model = [];
assets.car(5).path = fullfile(assetDir,'DodgeCharger','Car_5.obj');
assets.car(5).model = [];
assets.car(6).path = fullfile(assetDir,'JeepWrangler','Car_6.obj');
assets.car(6).model = [];
assets.car(7).path = fullfile(assetDir,'SubaruXV','Car_7.obj');
assets.car(7).model = [];
assets.car(8).path = fullfile(assetDir,'ToyotaPrius','Car_8.obj');
assets.car(8).model = [];
assets.car(9).path = fullfile(assetDir,'AudiS7','Car_9.obj');
assets.car(9).model = [];
assets.car(10).path = fullfile(assetDir,'MercedesML','Car_10.obj');
assets.car(10).model = [];
assets.car(11).path = fullfile(assetDir,'MercedesSLS','Car_11.obj');
assets.car(11).model = [];
assets.car(12).path = fullfile(assetDir,'Ferarri599','Car_12.obj');
assets.car(12).model = [];
assets.car(13).path = fullfile(assetDir,'NissanTitan','Car_13.obj');
assets.car(13).model = [];

assets.truck(1).path = fullfile(assetDir,'MercedesSantos','Truck_1.obj');
assets.truck(1).model = [];
assets.truck(2).path = fullfile(assetDir,'ActrosGarbage','Truck_2.obj');
assets.truck(2).model = [];
assets.truck(3).path = fullfile(assetDir,'FireTruck','Truck_3.obj');
assets.truck(3).model = [];


assets.bus(1).path = fullfile(assetDir,'MercedesCitaro','Bus_1.obj');
assets.bus(1).model = [];
assets.bus(2).path = fullfile(assetDir,'SchoolBus','Bus_2.obj');
assets.bus(2).model = [];

assets.person(1).path = fullfile(assetDir,'Males','Scan1','Scan1.obj');
assets.person(1).model = [];
assets.person(2).path = fullfile(assetDir,'Males','Scan3','Scan3.obj');
assets.person(2).model = [];
assets.person(3).path = fullfile(assetDir,'Males','Scan4','Scan4.obj');
assets.person(3).model = [];
assets.person(4).path = fullfile(assetDir,'Males','Scan8','Scan8.obj');
assets.person(4).model = [];
assets.person(5).path = fullfile(assetDir,'Males','Scan9','Scan9.obj');
assets.person(5).model = [];
assets.person(6).path = fullfile(assetDir,'Males','Scan10','Scan10.obj');
assets.person(6).model = [];
assets.person(7).path = fullfile(assetDir,'Males','Scan11','Scan11.obj');
assets.person(7).model = [];
assets.person(8).path = fullfile(assetDir,'Males','Scan14','Scan14.obj');
assets.person(8).model = [];
assets.person(9).path = fullfile(assetDir,'Males','Scan15','Scan15.obj');
assets.person(9).model = [];
assets.person(10).path = fullfile(assetDir,'Males','Scan16','Scan16.obj');
assets.person(10).model = [];
assets.person(11).path = fullfile(assetDir,'Males','Scan19','Scan19.obj');
assets.person(11).model = [];
assets.person(12).path = fullfile(assetDir,'Males','Scan22','Scan22.obj');
assets.person(12).model = [];

assets.person(13).path = fullfile(assetDir,'Females','1','Scan-1.obj');
assets.person(13).model = [];
assets.person(14).path = fullfile(assetDir,'Females','2','Scan-2.obj');
assets.person(14).model = [];
assets.person(15).path = fullfile(assetDir,'Females','3','Scan-3.obj');
assets.person(15).model = [];
assets.person(16).path = fullfile(assetDir,'Females','4','Scan-4.obj');
assets.person(16).model = [];
assets.person(17).path = fullfile(assetDir,'Females','5','Scan-5.obj');
assets.person(17).model = [];
assets.person(18).path = fullfile(assetDir,'Females','6','Scan-6.obj');
assets.person(18).model = [];
assets.person(19).path = fullfile(assetDir,'Females','7','Scan-7.obj');
assets.person(19).model = [];
assets.person(20).path = fullfile(assetDir,'Females','8','Scan-8.obj');
assets.person(20).model = [];
assets.person(21).path = fullfile(assetDir,'Females','9','Scan-9.obj');
assets.person(21).model = [];
assets.person(22).path = fullfile(assetDir,'Females','10','Scan-10.obj');
assets.person(22).model = [];
assets.person(23).path = fullfile(assetDir,'Females','11','Scan-11.obj');
assets.person(23).model = [];
assets.person(24).path = fullfile(assetDir,'Females','12','Scan-12.obj');
assets.person(24).model = [];


car2directory = {'MercedesCClass',...
    'Fiat500',...
    'MercedesSprinter',...
    'ToyotaCamry',...
    'DodgeCharger',...
    'JeepWrangler',...
    'SubaruXV',...
    'ToyotaPrius',...
    'AudiS7',...
    'MercedesML',...
    'MercedesSLS',...
    'Ferarri599',...
    'NissanTitan'};

truck2directory={'MercedesSantos',...
    'ActrosGarbage',...
    'FireTruck'};

bus2directory={'MercedesCitaro',...
    'SchoolBus'};




