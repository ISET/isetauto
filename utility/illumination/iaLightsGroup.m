function recipeList = iaLightsGroup(thisR, skymap)
% A complex driving scene contains a large number of lights, this function 
% group different type of lights, allow us to dynamically control the
% lighting without rendering afterwards. We group the lights by three major
% categories: 1. skylight; 2. headlights; 3. otherlights; we create one
% light group for skylight alone, several light groups for the other two
% type of lights.
% 
% Inputs: render recipe of the scene.
% 
% Ouputs: a list of recipes for light groups.
%
%
% Zhenyi, 2022

% lightNames = thisR.get('lights','namesid'); % long name

[outputDir,scenename] = fileparts(thisR.get('outputfile'));

recipeSkymap = piRecipeCopy(thisR);
recipeSkymap.set('outputFile',fullfile(outputDir, [scenename, '_skymap.pbrt']));

recipeHeadLights = piRecipeCopy(thisR);
recipeHeadLights.set('outputFile',fullfile(outputDir, [scenename, '_headlights.pbrt']));

recipeStreetLights = piRecipeCopy(thisR);
recipeStreetLights.set('outputFile',fullfile(outputDir, [scenename, '_streetlights.pbrt']));

recipeOtherLights = piRecipeCopy(thisR);
recipeOtherLights.set('outputFile',fullfile(outputDir, [scenename, '_otherlights.pbrt']));
ss = 1;
hh = 1;
ee = 1;
ll = 1;
%{
for ii =  1:numel(lightNames)
    light = lightNames{ii};
    % keep only skymap
    if ~contains(light, skymap)
        ssCounts{ss} = light;
        try
            recipeSkymap = piAssetDelete(recipeSkymap, light(8:end));
        catch
            recipeSkymap.assets  = recipeSkymap.assets.uniqueNames;
            recipeSkymap = piAssetDelete(recipeSkymap, light(8:end));
        end
        ss = ss+1;
    end
    % keep headlights
    if ~contains(light, {'headlamp','headlight'})
        hhCounts{hh} = light;
        try
            recipeHeadLights = piAssetDelete(recipeHeadLights, light(8:end));
        catch
            recipeHeadLights.assets  = recipeHeadLights.assets.uniqueNames;
            recipeHeadLights = piAssetDelete(recipeHeadLights, light(8:end));
        end
        hh = hh+1;
    end
    % remove all headlights and skymap
    if contains(light, {'headlamp','headlight'}) ||...
            contains(light, skymap) ||...
            contains(light, {'streetlight','streelight'})

        eeCounts{ee} = light;
        try
        recipeOtherLights = piAssetDelete(recipeOtherLights, light(8:end));
        catch
        recipeOtherLights.assets  = recipeOtherLights.assets.uniqueNames;
        recipeOtherLights = piAssetDelete(recipeOtherLights, light(8:end));
        end
        ee = ee+1;
    end 

    if ~contains(light, {'streetlight','streelight'})
        llCounts{ll} = light;
        try
            recipeStreetLights = piAssetDelete(recipeStreetLights, light(8:end));
        catch
            recipeStreetLights.assets  = recipeStreetLights.assets.uniqueNames;
            recipeStreetLights = piAssetDelete(recipeStreetLights, light(8:end));
        end
        ll = ll+1;
    else
        disp(light);
    end
    
end
%}

nNodes = numel(thisR.assets.Node);
NodeList = thisR.assets.Node;

for nn = nNodes:-1:1
    thisNode =  NodeList{nn};
    if strcmp(thisNode.type,'light')
        light = thisNode.name;
        if ~contains(light, skymap)
            recipeSkymap.assets = recipeSkymap.assets.chop(nn); 
        end
        if ~contains(light, 'headlight') && ~contains(light, 'headlamp')
            recipeHeadLights.assets = recipeHeadLights.assets.chop(nn); 
        end
        if ~contains(light, 'streetlight')
            recipeStreetLights.assets = recipeStreetLights.assets.chop(nn); 
        end
        if contains(light, {'headlamp','headlight'}) ||...
                contains(light, skymap) ||...
                contains(light, {'streetlight','streelight'})
            recipeOtherLights.assets = recipeOtherLights.assets.chop(nn);
        end
    end
end

% fprintf('Skylight group remove %d lights. \n', numel(ssCounts));
% fprintf('Headlight group remove %d lights. \n', numel(hhCounts));
% fprintf('Streetlight group remove %d lights. \n', numel(llCounts));
% fprintf('Otherlight group remove %d lights. \n', numel(eeCounts));

recipeSkymap.assets  = recipeSkymap.assets.uniqueNames;
recipeHeadLights.assets  = recipeHeadLights.assets.uniqueNames;
recipeStreetLights.assets  = recipeStreetLights.assets.uniqueNames;
recipeOtherLights.assets  = recipeOtherLights.assets.uniqueNames;

recipeList{1} = recipeSkymap;
recipeList{2} = recipeHeadLights;
recipeList{3} = recipeStreetLights;
recipeList{4} = recipeOtherLights;
end