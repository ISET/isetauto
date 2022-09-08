function obj = assemble(obj,varargin)
% Assemble the assets specified in the road class
%
% Synopsis:
%    roadgen.assemble;
%     
% Brief description:
%   We use the road parameters to place the cars, animals and so forth
%   into the scene
%
%   We generate random points on /off the road, on the road, the points are
%   used to place cars or other objects defined by users. off the road we
%   place trees for now, we will add building or other type of objects later.
%
% TODO:
%   Add motion

%% Initialize the onroad and offset components

% Could be obj.initialize('onroad');
% Similarly for offroad.
% obj.onroad.car.placedList = [];
% obj.onroad.animal.placedList = [];
% obj.offroad.animal.placedList = [];
% obj.offroad.tree.placedList = [];
obj.initialize();
%% Generate object lists on the road

% These will be cars and animals and maybe other terms in the future
assetNames = fieldnames(obj.onroad);

% For each type of asset on the road
for ii = 1:numel(assetNames)

    % Depending on the asset name
    switch assetNames{ii}
        case 'car'
            
            % merge car recipes.
            %
            % This merge looks very similar for each of the classes.
            % Maybe it could be a method like
            %
            %   thisRoad.place(location,objects);
            %   thisRoad.place('onroad',thisRoad.onroad.car);
            %   thisRoad.place('offroad',thisRoad.offroad.animal);

            onroadCar = obj.onroad.car;
            for nn = 1:numel(onroadCar.namelist)
                thisName = onroadCar.namelist{nn};
                obj = addOBJ(obj, 'car', thisName);
            end

            % Initialize and then place the objects in each lane.
            positions = cell(size(onroadCar.lane, 1));
            rotations = cell(size(onroadCar.lane, 1));
            objIdList = cell(size(onroadCar.lane, 1));
            for jj = 1:numel(onroadCar.lane)
                [positions{jj}, rotations{jj}] = obj.rrMapPlace(...
                    'laneType',onroadCar.lane{jj},'pos','onroad',...
                    'pointnum',onroadCar.number(jj));

                % Create a object list, number of assets is smaller then
                % the number of objects requested. so object instancing are
                % needed.
                objIdList{jj} = randi(numel(onroadCar.namelist), onroadCar.number(jj), 1);
            end

            % Store the metadata
            obj.onroad.car.placedList.objIdList = objIdList;
            obj.onroad.car.placedList.positions = positions;
            obj.onroad.car.placedList.rotations = rotations;

        case 'animal'
            % merge animal recipes
            onroadAnimal = obj.onroad.animal;
            for nn = 1:numel(onroadAnimal.namelist)
                thisName = onroadAnimal.namelist{nn};
                obj = addOBJ(obj, 'animal', thisName);
            end

            positions = cell(size(onroadAnimal.lane, 1));
            rotations = cell(size(onroadAnimal.lane, 1));
            % Needed, I think
            % objIdList = cell(size(onroadAnimal.lane, 1));

            for jj = 1:numel(onroadAnimal.lane)
                [positions{jj}, rotations{jj}] = obj.rrMapPlace(...
                    'laneType',onroadAnimal.lane{jj},'pos','onroad',...
                    'pointnum',onroadAnimal.number(jj),'rotOffset',pi*0.25);
                
                objIdList{jj} = randi(numel(onroadAnimal.namelist), onroadAnimal.number(jj), 1);
            end
            obj.onroad.animal.placedList.objIdList = objIdList;
            obj.onroad.animal.placedList.positions = positions;
            obj.onroad.animal.placedList.rotations = rotations;
    end
end

% Generate objects off the road
assetNames_off = fieldnames(obj.offroad);
for ii = 1:numel(assetNames_off)
    switch assetNames_off{ii}
        case 'animal'
            % merge animal recipes
            offroadAnmial = obj.offroad.animal;
            for nn = 1:numel(offroadAnmial.namelist)
                thisName = offroadAnmial.namelist{nn};
                obj = addOBJ(obj, 'animal', thisName);
            end

            positions = cell(size(offroadAnmial.lane, 1));
            rotations = cell(size(offroadAnmial.lane, 1));
            objIdList = cell(size(offroadAnmial.lane, 1));

            for jj = 1:numel(offroadAnmial.lane)
                [positions{jj}, rotations{jj}] = obj.rrMapPlace(...
                    'laneType',offroadAnmial.lane{jj},'pos','offroad',...
                    'pointnum',offroadAnmial.number(jj),'rotOffset',pi*0.25);

                objIdList{jj} = randi(numel(offroadAnmial.namelist), offroadAnmial.number(jj), 1);
            end
            
            obj.offroad.animal.placedList.objIdList = objIdList;
            obj.offroad.animal.placedList.positions = positions;
            obj.offroad.animal.placedList.rotations = rotations;

        case {'tree','rock','grass','streetlight'}
            OBJClass = assetNames_off{ii};
            offroadOBJ = obj.offroad.(OBJClass);
            for nn = 1:numel(offroadOBJ.namelist)
                thisName = offroadOBJ.namelist{nn};
                obj = addOBJ(obj, OBJClass, thisName);
            end
            
            scale = cell(size(offroadOBJ.lane, 1));
            if ~strcmp(OBJClass, 'streetlight')
                for jj = 1:numel(offroadOBJ.lane)
                    [positions{jj}, rotations{jj}] = obj.rrMapPlace(...
                        'laneType',offroadOBJ.lane{jj},'pos','offroad',...
                        'pointnum',offroadOBJ.number,'posOffset',1);

                    scale{jj} = rand(size(positions{jj},1),1)+0.5;

                    objIdList{jj} = randi(numel(offroadOBJ.namelist), size(positions{jj},1), 1);
                end
            else
                for jj = 1:numel(offroadOBJ.lane)
                    [positions{jj}, rotations{jj}] = obj.rrMapPlace(...
                        'laneType',offroadOBJ.lane{jj},'pos','offroad',...
                        'pointnum',offroadOBJ.number(jj),'posOffset',0.1,...
                        'uniformsample',true, 'mindistancetoroad',-2);
                    objIdList{jj} = randi(numel(offroadOBJ.namelist), size(positions{jj},1), 1);
                end                
            end

            % we can add random scale to trees, that's interesting
            obj.offroad.(OBJClass).placedList.objIdList = objIdList;
            obj.offroad.(OBJClass).placedList.positions = positions;
            obj.offroad.(OBJClass).placedList.rotations = rotations;
            obj.offroad.(OBJClass).placedList.scele     = scale;
    end
end
disp('--> AssetsList is generated');
%% Add objects

% check overlap, remove overlapped objects
obj = obj.overlappedRemove();

%% Apply our customized material
iaAutoMaterialGroupAssignV4(obj.recipe, true);
% sceneR.show('materials');
disp('--> Material assigned');

%% Place assets
% on road
assetNames_onroad = fieldnames(obj.onroad);
obj = obj.assetPlace(assetNames_onroad,'onroad');
% off road
assetNames_offroad = fieldnames(obj.offroad);
obj = obj.assetPlace(assetNames_offroad,'offroad');
disp('--> Assets Placed.')
%%
% skyname = obj.skymap;
% Delete any lights that happened to be there
% obj.recipe = piLightDelete(obj.recipe, 'all');
% 
% rotation(:,1) = [0 0 0 1]';
% rotation(:,2) = [45 0 1 0]';
% rotation(:,3) = [-90 1 0 0]';

% skymap = piLightCreate('new skymap', ...
%     'type', 'infinite',...
%     'string mapname', skyname,...
%     'specscale',2.2269e-04);
% to fix, add rotation

% obj.recipe.set('light', skymap, 'add');
% disp('--> Skymap added');

end

function obj = addOBJ(obj, OBJClass, thisName)

id = piAssetFind(obj.recipe.assets, 'name',[thisName,'_m_B']); % check whether it's there already

if isempty(id)
    pbrtFile = fullfile(obj.assetdirectory, OBJClass, thisName, [thisName,'.pbrt']);
    recipeFile = fullfile(obj.assetdirectory, OBJClass, thisName, [thisName,'.mat']);
    if exist(recipeFile,'file')
        thisAssetRecipe = load(recipeFile);
        thisAssetRecipe = thisAssetRecipe.recipe;
    else
        thisAssetRecipe = piRead(pbrtFile);
    end
    obj.recipe = piRecipeMerge(obj.recipe, thisAssetRecipe, 'objectInstance',true);
end

end


