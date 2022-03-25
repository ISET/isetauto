%% dataset information
function assetInfo = assetlib()
%% Cars
assetInfo = containers.Map();

car_001.name = 'car_001';
car_001.size = [4.7842, 1.961, 1.391]; %[x, y, z]

car_002.name = 'car_002';
car_002.size = [4.989, 1.960, 1.742]; %[x, y, z]

assetInfo('car_001') = car_001;
assetInfo('car_002') = car_002;
%% animals

deer_001.name = 'deer_001';
deer_001.size = [1.21, 0.566, 1.36]; %[x, y, z]

deer_002.name = 'deer_002';
deer_002.size = [1.39, 0.632, 1.3]; %[x, y, z]

assetInfo('deer_001') = deer_001;
assetInfo('deer_002') = deer_002;

%% trees

tree_short_001.name = 'tree_short_001';
tree_short_001.size = [2.51, 2.41, 1.99]; %[x, y, z]

tree_mid_001.name = 'tree_mid_001';
tree_mid_001.size = [2.52, 2.48, 3.47]; %[x, y, z]

tree_mid_002.name = 'tree_mid_002';
tree_mid_002.size = [2.72, 2.73, 4.71]; %[x, y, z]

tree_tall_001.name = 'tree_tall_001';
tree_tall_001.size = [6.25, 6.71, 8.86]; %[x, y, z]

assetInfo('tree_short_001') = tree_short_001;
assetInfo('tree_mid_001') = tree_mid_001;
assetInfo('tree_mid_002') = tree_mid_002;
assetInfo('tree_tall_001') = tree_tall_001;
end



