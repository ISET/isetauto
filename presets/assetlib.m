%% dataset information
function assetInfo = assetlib()
%% Cars
assetInfo = containers.Map();

car_001.name = 'car_001';
car_001.size = [4.76 2.02 1.41]; %[x, y, z]
car_001.brand = 'Mercedes';
assetInfo('car_001') = car_001;

car_002.name = 'car_002';
car_002.size = [4.25 1.799 1.452]; %[x, y, z]
car_002.brand = 'VW';
assetInfo('car_002') = car_002;

car_003.name = 'car_003';
car_003.size = [4.506 2.024 1.557];
car_003.brand = 'Audi';
assetInfo('car_003') = car_003;

car_004.name = 'car_004';
car_004.size = [4.83 2.08 1.35];
car_004.brand = 'Ford';
assetInfo('car_004') = car_004;

car_004_dirty.name = 'car_004_dirty';
car_004_dirty.size = [4.83 2.08 1.35];
car_004_dirty.brand = 'Ford';
assetInfo('car_004_dirty') = car_004_dirty;

car_005.name = 'car_005';
car_005.size = [5.38 2.18 2.08];
car_005.brand = 'Ford';
assetInfo('car_005') = car_005;

car_006.name = 'car_006';
car_006.size = [4.95 2.08 1.6];
car_006.brand = 'Ford';
assetInfo('car_006') = car_006;

car_007.name = 'car_007';
car_007.size = [4.56 2.08 1.75]; 
car_007.brand = 'Ford';
assetInfo('car_007') = car_007;

% x 4.5m y 2.02m z 1.6m
car_008.name = 'car_008';
car_008.size = [4.5 2.02 1.6]; 
car_008.brand = 'Ford';
assetInfo('car_008') = car_008;

% x 5.71m y 2.39m z 1.95m
car_009.name = 'car_009';
car_009.size = [5.71 2.39 1.95]; 
car_009.brand = 'Ford';
assetInfo('car_009') = car_009;

% x 4.63m 2.12m 1.44m
car_010.name = 'car_010';
car_010.size = [4.63 2.12 1.44]; 
car_010.brand = 'Honda';
assetInfo('car_010') = car_010;

% x 3.4m y 1.85m z 1.73m
car_011.name = 'car_011';
car_011.size = [3.4 1.85 1.73]; 
car_011.brand = 'Honda';
assetInfo('car_011') = car_011;

% x 5m y 2.18m z 1.55m
car_012.name = 'car_012';
car_012.size = [5 2.18 1.55]; 
car_012.brand = 'BMW';
assetInfo('car_012') = car_012;

% x 4.77m y 2.07m z 1.45m
car_013.name = 'car_013';
car_013.size = [4.77 2.07 1.45]; 
car_013.brand = 'BMW';
assetInfo('car_013') = car_013;

car_014.name = 'car_014';
car_014.size = [4.969 2.118 1.422]; 
car_014.brand = 'Audi';
assetInfo('car_014') = car_014;

% x 4.99m y 2.12m z 1.69m
car_015.name = 'car_015';
car_015.size = [4.99 2.12 1.69]; 
car_015.brand = 'Audi';
assetInfo('car_015') = car_015;

car_020.name = 'car_020';
car_020.size = [4.74 2.14 1.40]; 
car_020.brand = 'BMW';
assetInfo('car_020') = car_020;

car_025.name = 'car_025';
car_025.size = [4.78 2.2 1.39]; 
car_025.brand = 'BMW';
assetInfo('car_025') = car_025;

car_026.name = 'car_026';
car_026.size = [5 2.13 1.51]; 
car_026.brand = 'BMW';
assetInfo('car_026') = car_026;

car_027.name = 'car_027';
car_027.size = [5.16 2.2 1.84]; 
car_027.brand = 'BMW';
assetInfo('car_027') = car_027;

car_028.name = 'car_028';
car_028.size = [4.32 2.02 2.36]; 
car_028.brand = 'BMW';
assetInfo('car_028') = car_028;

car_029.name = 'car_029';
car_029.size = [6.41 2.46 2.43]; 
car_029.brand = 'Mercedes';
assetInfo('car_029') = car_029;

car_030.name = 'car_030';
car_030.size = [3.85 2.02 1.61]; 
car_030.brand = 'Mercedes';
assetInfo('car_030') = car_030;

car_035.name = 'car_035';
car_035.size = [5.52 2.35 1.62]; 
car_035.brand = 'Mercedes';
assetInfo('car_035') = car_035;

car_036.name = 'car_036';
car_036.size = [5.26 2.46 2.25]; 
car_036.brand = 'Mercedes';
assetInfo('car_036') = car_036;

car_037.name = 'car_037';
car_037.size = [4.74 2.17 1.69]; 
car_037.brand = 'Mercedes';
assetInfo('car_037') = car_037;

car_038.name = 'car_038';
car_038.size = [4.75 2.11 1.73]; 
car_038.brand = 'Mercedes';
assetInfo('car_038') = car_038;

car_039.name = 'car_039';
car_039.size = [5.21 2.17 1.83]; 
car_039.brand = 'Mercedes';
assetInfo('car_039') = car_039;

car_040.name = 'car_040';
car_040.size = [6.21 2.93 2.68]; 
car_040.brand = 'Mercedes';
assetInfo('car_040') = car_040;

car_041.name = 'car_041';
car_041.size = [4.63 2.08 1.26]; 
car_041.brand = 'Mercedes';
assetInfo('car_041') = car_041;

car_042.name = 'car_042';
car_042.size = [6.7 2.34 2.78]; 
car_042.brand = 'Mercedes';
assetInfo('car_042') = car_042;

car_044.name = 'car_044';
car_044.size = [4.47 2.12 1.46]; 
car_044.brand = 'honda';
assetInfo('car_044') = car_044;

car_045.name = 'car_045';
car_045.size = [4.48 2.24 2.33]; 
car_045.brand = 'coffee';
assetInfo('car_045') = car_045;

car_046.name = 'car_046';
car_046.size = [4.38 1.71 1.46]; 
car_046.brand = 'vintage';
assetInfo('car_046') = car_046;

car_047.name = 'car_047';
car_047.size = [4.26 1.89 1.49]; 
car_047.brand = 'coffee';
assetInfo('car_047') = car_047;

car_048.name = 'car_048';
car_048.size = [6.0 2.7 2.74]; 
car_048.brand = 'vw';
assetInfo('car_048') = car_048;

car_049.name = 'car_049';
car_049.size = [3.93 1.98 1.35]; 
car_049.brand = 'vw';
assetInfo('car_049') = car_049;

car_050.name = 'car_050';
car_050.size = [4.26 2.07 1.56]; 
car_050.brand = 'vw_id3';
assetInfo('car_050') = car_050;

car_051.name = 'car_051';
car_051.size = [5.74 2.64 2.59]; 
car_051.brand = 'vw_vintage';
assetInfo('car_051') = car_051;

car_052.name = 'car_052';
car_052.size = [4.75 2.1 1.41]; 
car_052.brand = 'vw';
assetInfo('car_052') = car_052;

car_053.name = 'car_053';
car_053.size = [4.53 1.97 1.42]; 
car_053.brand = 'vw';
assetInfo('car_053') = car_053;

car_054.name = 'car_054';
car_054.size = [4.25 1.98 1.45]; 
car_054.brand = 'vw';
assetInfo('car_054') = car_054;

car_055.name = 'car_055';
car_055.size = [4.84 2.15 1.42]; 
car_055.brand = 'vw';
assetInfo('car_055') = car_055;

car_057.name = 'car_057';
car_057.size = [5.26 2.09 1.59]; 
car_057.brand = 'ford_taxi';
assetInfo('car_057') = car_057;

car_058.name = 'car_058';
car_058.size = [5.81 2.48 1.98]; 
car_058.brand = 'ford_pickup';
assetInfo('car_058') = car_058;

car_061.name = 'car_061';
car_061.size = [6.56 3.46 3.97]; 
car_061.brand = 'unkown';
assetInfo('car_051') = car_061;

%% bus
bus_001.name = 'bus_001';
bus_001.size = [12.3 2.86 3.23]; 
bus_001.brand = 'Mercedes';
assetInfo('bus_001') = bus_001;

bus_002.name = 'bus_002';
bus_002.size = [15.7 3.36 4.41]; 
bus_002.brand = 'Scania';
assetInfo('bus_002') = bus_002;

bus_003.name = 'bus_003';
bus_003.size = [7.17 2.56 2.69]; 
bus_003.brand = 'Toyota';
assetInfo('bus_003') = bus_003;

bus_004.name = 'bus_004';
bus_004.size = [11.2 3.04 4.41]; 
bus_004.brand = 'Mercedes';
assetInfo('bus_004') = bus_004;

bus_005.name = 'bus_005';
bus_005.size = [21.7 3.13 3.29]; 
bus_005.brand = 'Mercedes';
assetInfo('bus_005') = bus_005;

bus_006.name = 'bus_006';
bus_006.size = [12.3 2.99 3.77]; 
bus_006.brand = 'unkown';
assetInfo('bus_004') = bus_006;

bus_007.name = 'bus_007';
bus_007.size = [9.61 2.45 2.64]; 
bus_007.brand = 'schoolbus';
assetInfo('bus_007') = bus_007;

%% truck
truck_001.name = 'truck_001';
truck_001.size = [7.94 2.85 3.44]; 
truck_001.brand = 'Mercedes';
assetInfo('truck_001') = truck_001;

truck_002.name = 'truck_002';
truck_002.size = [11.8 4.37 5.53]; 
truck_002.brand = 'Mercedes';
assetInfo('truck_002') = truck_002;

truck_003.name = 'truck_003';
truck_003.size = [6.80 3.46 3.56]; 
truck_003.brand = 'honda';
assetInfo('truck_003') = truck_003;

truck_004.name = 'truck_004';
truck_004.size = [14.6 4.55 6.29]; 
truck_004.brand = 'Mercedes';
assetInfo('truck_004') = truck_004;

truck_005.name = 'truck_005';
truck_005.size = [9.95 3.18 4.23]; 
truck_005.brand = 'volvo';
assetInfo('truck_005') = truck_005;

truck_006.name = 'truck_006';
truck_006.size = [8.44 3.08 4.08]; 
truck_006.brand = 'scania';
assetInfo('truck_006') = truck_006;

truck_007.name = 'truck_007';
truck_007.size = [16.5 2.95 4.15]; 
truck_007.brand = 'scania';
assetInfo('truck_001') = truck_007;

truck_008.name = 'truck_008';
truck_008.size = [11.3 2.82 3.85]; 
truck_008.brand = 'volvo';
assetInfo('truck_008') = truck_008;

truck_009.name = 'truck_009';
truck_009.size = [10.8 3.48 3.48]; 
truck_009.brand = 'firetruck';
assetInfo('truck_009') = truck_009;

truck_010.name = 'truck_010';
truck_010.size = [8.11 3.42 3.9]; 
truck_010.brand = 'unkown';
assetInfo('truck_010') = truck_010;

truck_011.name = 'truck_011';
truck_011.size = [6.19 2.48 2.48]; 
truck_011.brand = 'Renault';
assetInfo('truck_011') = truck_011;

truck_012.name = 'truck_012';
truck_012.size = [4.43 1.62 1.88]; 
truck_012.brand = 'Toyota';
assetInfo('truck_012') = truck_012;

truck_013.name = 'truck_013';
truck_013.size = [9.75 2.87 3.77]; 
truck_013.brand = 'scania';
assetInfo('truck_013') = truck_013;
%% animals

deer_001.name = 'deer_001';
deer_001.size = [1.21, 0.566, 1.36]; %[x, y, z]
assetInfo('deer_001') = deer_001;

deer_002.name = 'deer_002';
deer_002.size = [1.39, 0.632, 1.3]; %[x, y, z]
assetInfo('deer_002') = deer_002;

deer_003.name = 'deer_003';
deer_003.size = [1.66, 0.815, 1.87]; %[x, y, z]
assetInfo('deer_003') = deer_003;

deer_004.name = 'deer_004';
deer_004.size = [2.06, 1.06, 2.12]; %[x, y, z]
assetInfo('deer_004') = deer_004;

deer_005.name = 'deer_005';
deer_005.size = [1.66, 0.583, 1.21]; %[x, y, z]
assetInfo('deer_005') = deer_005;

deer_006.name = 'deer_006';
deer_006.size = [1.35, 0.412, 1.22]; %[x, y, z]
assetInfo('deer_006') = deer_006;

deer_007.name = 'deer_007';
deer_007.size = [1.98, 0.751, 1.54]; %[x, y, z]
assetInfo('deer_007') = deer_007;

deer_008.name = 'deer_008';
deer_008.size = [0.854, 0.379, 0.797]; %[x, y, z]
assetInfo('deer_008') = deer_008;

deer_009.name = 'deer_009';
deer_009.size = [2.24, 1.21, 2.04]; %[x, y, z]
assetInfo('deer_009') = deer_009;
%% trees

tree_short_001.name = 'tree_short_001';
tree_short_001.size = [2.51, 2.41, 1.99]; %[x, y, z]
assetInfo('tree_short_001') = tree_short_001;

tree_mid_001.name = 'tree_mid_001';
tree_mid_001.size = [2.52, 2.48, 3.47]; %[x, y, z]
assetInfo('tree_mid_001') = tree_mid_001;

tree_mid_002.name = 'tree_mid_002';
tree_mid_002.size = [2.72, 2.73, 4.71]; %[x, y, z]
assetInfo('tree_mid_002') = tree_mid_002;

tree_tall_001.name = 'tree_tall_001';
tree_tall_001.size = [6.25, 6.71, 8.86]; %[x, y, z]
assetInfo('tree_tall_001') = tree_tall_001;

% x 5m y 5.33m z 8.49m
tree_001.name = 'tree_001';
tree_001.size = [5 5.33 8.49]; 
assetInfo('tree_001') = tree_001;

% x 3.6m y 3.56m z 6.88m
tree_002.name = 'tree_002';
tree_002.size = [3.6 3.56 6.88]; 
assetInfo('tree_002') = tree_002;

% x 4.35m y 4.3m z 6.08m
tree_003.name = 'tree_003';
tree_003.size = [4.35 4.3 6.08]; 
assetInfo('tree_003') = tree_003;

% x 4.88m y 5.06m z 5.04m
tree_004.name = 'tree_004';
tree_004.size = [4.88 5.06 5.04]; 
assetInfo('tree_004') = tree_004;

% x 6.3m y 5.74m z 5.72m
tree_005.name = 'tree_005';
tree_005.size = [6.3 5.74 5.72]; 
assetInfo('tree_005') = tree_005;

% x 5.53m y 4.59m z 5.64m
tree_006.name = 'tree_006';
tree_006.size = [5.5 4.59 5.64]; 
assetInfo('tree_006') = tree_006;

% x 3.81m y 3,65m z 5.04m
tree_007.name = 'tree_007';
tree_007.size = [3.81 3.65 5.04]; 
assetInfo('tree_007') = tree_007;

% 3.99m y 3,73m z 4.83m
tree_008.name = 'tree_008';
tree_008.size = [3.99 3.73 4.83]; 
assetInfo('tree_008') = tree_008;

% 3.35m y 3,45m z 4.42m
tree_009.name = 'tree_009';
tree_009.size = [3.35 3.45 4.42]; 
assetInfo('tree_009') = tree_009;

% 7.77m y 7.03m z 9.92m
tree_010.name = 'tree_010';
tree_010.size = [7.77 7.03 9.92]; 
assetInfo('tree_010') = tree_010;

% 8.2m y 8,17m z 9.95m
tree_011.name = 'tree_011';
tree_011.size = [8.2 8,17 9.95]; 
assetInfo('tree_011') = tree_011;

% 6.76m y 5.71m z 9.22m
tree_012.name = 'tree_012';
tree_012.size = [6.76 5.71 9.22]; 
assetInfo('tree_012') = tree_012;

% x 7.27m y 7.51m z 10.4m
tree_013.name = 'tree_013';
tree_013.size = [7.27 7.51 10.4]; 
assetInfo('tree_013') = tree_013;

% 6.02m y 5.05m z 8.37m
tree_014.name = 'tree_014';
tree_014.size = [6.02 5.05 8.37]; 
assetInfo('tree_014') = tree_014;

% 6.9m y 7.06m z 9.2
tree_015.name = 'tree_015';
tree_015.size = [6.02 5.05 8.37]; 
assetInfo('tree_015') = tree_015;

% 7.32m y 6.96m z 10.3
tree_016.name = 'tree_016';
tree_016.size = [7.3 6.96 10.3]; 
assetInfo('tree_016') = tree_016;

% 4.54m y 6.58m z 9.85
tree_017.name = 'tree_017';
tree_017.size = [4.54 6.58 9.85]; 
assetInfo('tree_017') = tree_017;

% 5.64m y 5.64m z 10.1
tree_018.name = 'tree_018';
tree_018.size = [5.64 5.64 10.1]; 
assetInfo('tree_018') = tree_018;

% 15.1m y 13.7m z 17.8
tree_019.name = 'tree_019';
tree_019.size = [15.1 13.7 17.8]; 
assetInfo('tree_019') = tree_019;

% 10.7m y 13.3m z 17.3
tree_020.name = 'tree_020';
tree_020.size = [10.7 13.3 17.3]; 
assetInfo('tree_020') = tree_020;

% 11m y 11m z 19.1
tree_021.name = 'tree_021';
tree_021.size = [11 11 19.1]; 
assetInfo('tree_021') = tree_021;

% 5.85m y 5.92m z 8.07
tree_022.name = 'tree_022';
tree_022.size = [11 11 19.1]; 
assetInfo('tree_022') = tree_022;

% 5.31m y 5.39m z 6.89
tree_023.name = 'tree_023';
tree_023.size = [5.31 5.39 6.89]; 
assetInfo('tree_023') = tree_023;

% 5.55m y 5.6m z 7.99
tree_024.name = 'tree_024';
tree_024.size = [5.55 5.6 7.99]; 
assetInfo('tree_024') = tree_024;

% 9.55m y 10.2m z 19.3
tree_025.name = 'tree_025';
tree_025.size = [9.55 10.2 19.3]; 
assetInfo('tree_025') = tree_025;

% 11.9m y 10.5m z 23.3
tree_026.name = 'tree_026';
tree_026.size = [11.9 10.5 23.3]; 
assetInfo('tree_026') = tree_026;

% 6.59m y 7.73m z 19.4
tree_027.name = 'tree_027';
tree_027.size = [6.59 7.73 19.4]; 
assetInfo('tree_027') = tree_027;

% 5.82m y 5.98m z 9.5
tree_028.name = 'tree_028';
tree_028.size = [5.82 5.98 9.5]; 
assetInfo('tree_028') = tree_028;

% 6.3m y 5.52m z 10.4
tree_029.name = 'tree_029';
tree_029.size = [6.3 5.52 10.4]; 
assetInfo('tree_029') = tree_029;

% 7.61m y 7.72m z 10.6
tree_030.name = 'tree_030';
tree_030.size = [7.61 7.72 10.6]; 
assetInfo('tree_030') = tree_030;

% 8.28m y 7.98m z 10.5
tree_031.name = 'tree_031';
tree_031.size = [8.28 7.98 10.5]; 
assetInfo('tree_031') = tree_031;

% 9.55m y 9.31m z 13.1
tree_032.name = 'tree_032';
tree_032.size = [9.55 9.31 13.1]; 
assetInfo('tree_032') = tree_032;

% 10.8m y 11.4m z 12.2
tree_033.name = 'tree_033';
tree_033.size = [10.8 11.4 12.2]; 
assetInfo('tree_033') = tree_033;

% 10.1m y 10.4m z 32
tree_034.name = 'tree_034';
tree_034.size = [10.1 10.4 32]; 
assetInfo('tree_034') = tree_034;

% 16m y 15.3m z 25.8
tree_035.name = 'tree_035';
tree_035.size = [16 15.3 25.8]; 
assetInfo('tree_035') = tree_035;

% 12.7m y 14.5m z 37.3
tree_036.name = 'tree_036';
tree_036.size = [12.7 14.5 37.3]; 
assetInfo('tree_036') = tree_036;

% 7.13m y 7.06m z 10.6
tree_037.name = 'tree_037';
tree_037.size = [7.13 7.06 10.6]; 
assetInfo('tree_037') = tree_037;


% 8.2m y 7.34m z 10.8
tree_038.name = 'tree_038';
tree_038.size = [8.2 7.34 10.8]; 
assetInfo('tree_038') = tree_038;

% 8.18m y 8.31m z 12
tree_039.name = 'tree_039';
tree_039.size = [8.18 8.31 12]; 
assetInfo('tree_039') = tree_039;

% 4.97m y 5.23m z 6.76
tree_040.name = 'tree_040';
tree_040.size = [4.97 5.23 6.76]; 
assetInfo('tree_040') = tree_040;

% 7.43m y 7.11m z 7.91
tree_041.name = 'tree_041';
tree_041.size = [7.43 7.11 7.91]; 
assetInfo('tree_041') = tree_041;

% 4.35m y 4.25m z 6.98
tree_042.name = 'tree_042';
tree_042.size = [4.35 4.25 6.98]; 
assetInfo('tree_042') = tree_042;


% 8.98m y 9.19m z 34.4
tree_043.name = 'tree_043';
tree_043.size = [8.98 9.19 34.4]; 
assetInfo('tree_043') = tree_043;

% 19.7m y 21.8m z 31.4
tree_044.name = 'tree_044';
tree_044.size = [19.7 21.8 31.4]; 
assetInfo('tree_044') = tree_044;

% 13.7m y 15.9m z 37.5
tree_045.name = 'tree_045';
tree_045.size = [13.7 15.9 37.5]; 
assetInfo('tree_045') = tree_045;

% 8.29m y 8.17m z 12.2
tree_046.name = 'tree_046';
tree_046.size = [8.29 8.17 12.2]; 
assetInfo('tree_046') = tree_046;

% 8.36m y 7.39m z 13.1
tree_047.name = 'tree_047';
tree_047.size = [8.36 7.39 13.1]; 
assetInfo('tree_047') = tree_047;

% 9.15m y 8.14m z 13.6
tree_048.name = 'tree_048';
tree_048.size = [9.15 8.14 13.6]; 
assetInfo('tree_048') = tree_048;

% 7.67m y 7.37m z 9.46
tree_049.name = 'tree_049';
tree_049.size = [7.67 7.37 9.46]; 
assetInfo('tree_049') = tree_049;

% 7.96m y 8.32m z 9.65
tree_050.name = 'tree_050';
tree_050.size = [7.96 8.32 9.65]; 
assetInfo('tree_050') = tree_050;

% 8.46m y 8.27m z 10.7
tree_051.name = 'tree_051';
tree_051.size = [8.46 8.27 10.7]; 
assetInfo('tree_051') = tree_051;

% 7.39m y 8.42m z 13.1
tree_052.name = 'tree_052';
tree_052.size = [7.39 8.42 13.1]; 
assetInfo('tree_052') = tree_052;

% 6.46m y 6.73m z 10.3
tree_053.name = 'tree_053';
tree_053.size = [6.46 6.73 10.3]; 
assetInfo('tree_053') = tree_053;

% 5.05m y 5.11m z 9.9m
tree_054.name = 'tree_054';
tree_054.size = [5.05 5.11 9.9]; 
assetInfo('tree_054') = tree_054;

end



