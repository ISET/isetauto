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
obj.initialize();
%% Generate object lists on the road

% These will be cars and animals and maybe other terms in the future
assetNames = fieldnames(obj.onroad);

% For each type of asset on the road
for ii = 1:numel(assetNames)
    OBJClass = assetNames{ii};
    onroadOBJ = obj.onroad.(OBJClass);
    namelist = [];

    % Initialize and then place the objects in each lane.
    positions = cell(size(onroadOBJ.lane, 1));
    rotations = cell(size(onroadOBJ.lane, 1));
    objIdList = cell(size(onroadOBJ.lane, 1));
    % Depending on the asset name
    switch assetNames{ii}
        case {'car','bus', 'truck', 'biker'}
            sumo=false;randomseed = 1;
            period= 1.0;
            maxVNum = 10;            
            if isfield(onroadOBJ,'sumo')
                sumo = onroadOBJ.sumo;
                if isfield(onroadOBJ,'randomseed')
                    randomseed = onroadOBJ.randomseed;
                else
                    randomseed = randi([1,221013]);
                end
                if isfield(onroadOBJ,'maxnum')
                    maxVNum = onroadOBJ.maxnum;end
                if isfield(onroadOBJ,'period')
                    period = onroadOBJ.period;end
            end
            for jj = 1:numel(onroadOBJ.lane)
                if onroadOBJ.number(jj) == 0, continue; end
                [positions{jj}, rotations{jj}] = obj.rrMapPlace(...
                    'laneType',onroadOBJ.lane{jj},'pos','onroad',...
                    'pointnum',onroadOBJ.number(jj),'sumo',sumo, ...
                    'randomseed',randomseed,'period',period, ...
                    'maxVNum',maxVNum);
                % Create a object list, number of assets is smaller then
                % the number of objects requested. so object instancing are
                % needed.
                objIdList{jj} = randi(numel(onroadOBJ.namelist), onroadOBJ.number(jj), 1);
                namelist = vertcat(namelist,objIdList{jj});
            end

        case {'animal', 'pedestrian'}
            for jj = 1:numel(onroadOBJ.lane)
                if onroadOBJ.number(jj) == 0, continue; end
                [positions{jj}, rotations{jj}] = obj.rrMapPlace(...
                    'laneType',onroadOBJ.lane{jj},'pos','onroad',...
                    'pointnum',onroadOBJ.number(jj),'rotOffset',pi*0.25);

                objIdList{jj} = randi(numel(onroadOBJ.namelist), onroadOBJ.number(jj), 1);
                namelist = vertcat(namelist,objIdList{jj});
            end

    end

    namelist = unique(namelist);

    for nn = 1:numel(namelist)
        thisName = onroadOBJ.namelist{namelist(nn)};
        obj = addOBJ(obj, OBJClass, thisName);
    end

    obj.onroad.(OBJClass).placedList.objIdList = objIdList;
    obj.onroad.(OBJClass).placedList.positions = positions;
    obj.onroad.(OBJClass).placedList.rotations = rotations;
end

% Generate objects off the road
assetNames_off = fieldnames(obj.offroad);
for ii = 1:numel(assetNames_off)
    OBJClass = assetNames_off{ii};
    offroadOBJ = obj.offroad.(OBJClass);
    namelist = [];
    positions = cell(size(offroadOBJ.lane, 1));
    rotations = cell(size(offroadOBJ.lane, 1));
    objIdList = cell(size(offroadOBJ.lane, 1));

    switch assetNames_off{ii}
        case {'animal', 'pedestrian'}
            for jj = 1:numel(offroadOBJ.lane)
                if offroadOBJ.number(jj) == 0, continue; end
                [positions{jj}, rotations{jj}] = obj.rrMapPlace(...
                    'laneType',offroadOBJ.lane{jj},'pos','offroad',...
                    'pointnum',offroadOBJ.number(jj),'rotOffset',pi*0.25);

                objIdList{jj} = randi(numel(offroadOBJ.namelist), offroadOBJ.number(jj), 1);
                namelist = vertcat(namelist,objIdList{jj});
            end
        case {'tree', 'rock', 'grass', 'streetlight'}
            OBJClass = assetNames_off{ii};
            offroadOBJ = obj.offroad.(OBJClass);
            namelist = [];

            scale = cell(size(offroadOBJ.lane, 1));
            if ~strcmp(OBJClass, 'streetlight')
                for jj = 1:numel(offroadOBJ.lane)
                    if offroadOBJ.number(jj) == 0, continue; end
                    [positions{jj}, rotations{jj}] = obj.rrMapPlace(...
                        'laneType',offroadOBJ.lane{jj},'pos','offroad',...
                        'pointnum',offroadOBJ.number,'posOffset',1);

                    scale{jj} = rand(size(positions{jj},1),1)+0.5;

                    objIdList{jj} = randi(numel(offroadOBJ.namelist), size(positions{jj},1), 1);
                    namelist = vertcat(namelist,objIdList{jj});
                end
            else
                for jj = 1:numel(offroadOBJ.lane)
                    [positions{jj}, rotations{jj}] = obj.rrMapPlace(...
                        'laneType',offroadOBJ.lane{jj},'pos','offroad',...
                        'pointnum',offroadOBJ.number(jj),'posOffset',0.1,...
                        'uniformsample',true, 'mindistancetoroad',-2);
                    objIdList{jj} = randi(numel(offroadOBJ.namelist), size(positions{jj},1), 1);
                    namelist = vertcat(namelist,objIdList{jj});
                end
            end
    end

    namelist = unique(namelist);
    for nn = 1:numel(namelist)
        thisName = offroadOBJ.namelist{namelist(nn)};
        obj = addOBJ(obj, OBJClass, thisName);
    end

    obj.offroad.(OBJClass).placedList.objIdList = objIdList;
    obj.offroad.(OBJClass).placedList.positions = positions;
    obj.offroad.(OBJClass).placedList.rotations = rotations;

end
disp('--> AssetsList is generated');
%% Add objects

% check overlap, remove overlapped objects
obj = obj.overlappedRemove();
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


