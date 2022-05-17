%% dataset information
function assetInfo = assetlib()
%% Cars
assetInfo = containers.Map();

car_001.name = 'car_001';
car_001.size = [4.76 2.02 1.41]; %[x, y, z]
assetInfo('car_001') = car_001;

car_002.name = 'car_002';
car_002.size = [4.25 1.799 1.452]; %[x, y, z]
assetInfo('car_002') = car_002;

car_003.name = 'car_003';
car_003.size = [4.506 2.024 1.557];
assetInfo('car_003') = car_003;

car_004.name = 'car_004';
car_004.size = [4.83 2.08 1.35];
assetInfo('car_004') = car_004;

car_005.name = 'car_005';
car_005.size = [5.38 2.18 2.08];
assetInfo('car_005') = car_005;

car_006.name = 'car_006';
car_006.size = [4.95 2.08 1.6];
assetInfo('car_006') = car_006;

car_007.name = 'car_007';
car_007.size = [4.56 2.08 1.75]; 
assetInfo('car_007') = car_007;

% x 4.5m y 2.02m z 1.6m
car_008.name = 'car_008';
car_008.size = [4.5 2.02 1.6]; 
assetInfo('car_008') = car_008;

% x 5.71m y 2.39m z 1.95m
car_009.name = 'car_009';
car_009.size = [5.71 2.39 1.95]; 
assetInfo('car_009') = car_009;

% x 4.63m 2.12m 1.44m
car_010.name = 'car_010';
car_010.size = [4.63 2.12 1.44]; 
assetInfo('car_010') = car_010;

% x 3.4m y 1.85m z 1.73m
car_011.name = 'car_011';
car_011.size = [3.4 1.85 1.73]; 
assetInfo('car_011') = car_011;

% x 5m y 2.18m z 1.55m
car_012.name = 'car_012';
car_012.size = [5 2.18 1.55]; 
assetInfo('car_012') = car_012;

% x 4.77m y 2.07m z 1.45m
car_013.name = 'car_013';
car_013.size = [4.77 2.07 1.45]; 
assetInfo('car_013') = car_013;

car_014.name = 'car_014';
car_014.size = [4.969 2.118 1.422]; 
assetInfo('car_014') = car_014;

% x 4.99m y 2.12m z 1.69m
car_015.name = 'car_015';
car_015.size = [4.99 2.12 1.69]; 
assetInfo('car_015') = car_015;
%% animals

deer_001.name = 'deer_001';
deer_001.size = [1.21, 0.566, 1.36]; %[x, y, z]
assetInfo('deer_001') = deer_001;

deer_002.name = 'deer_002';
deer_002.size = [1.39, 0.632, 1.3]; %[x, y, z]
assetInfo('deer_002') = deer_002;

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



