function scene = renderRecipe(scenario, originalOutputFile)

    ourRecipe = scenario.roadData.recipe;
    [pp, nn, ee] = fileparts(originalOutputFile);
    ourRecipe.outputFile = fullfile(pp, [nn '-' sprintf('%03d', scenario.frameNum) ee]);

    % Auto scenes only have radiance in their metadata!
    % We should start adding the others by default, so this section will be
    % moot...
    ourRecipe.metadata.rendertype = {'radiance','depth','albedo'}; % normal

    % This should be redundant?
    ourRecipe.set('rendertype', {'depth', 'radiance', 'albedo'});

    piWrite(ourRecipe);

    % organize this more rationally...
    if isequal(scenario.deNoise, 'exr_all')
        scene = piRender(ourRecipe, 'do_denoise', 'exr_all');
    elseif isequal(scenario.deNoise, 'exr_albedo')
        scene = piRender(ourRecipe, 'do_denoise', 'exr_albedo');
    elseif isequal(scenario.deNoise, 'exr_radiance')
        scene = piRender(ourRecipe, 'do_denoise', 'exr_radiance');
    elseif isequal(scenario.deNoise, 'scene')
        scene = piRender(ourRecipe);
        scene = piAIdenoise(scene,'quiet', true, 'batch', true);
    else % no denoise or denoise later after rgb
        scene = piRender(ourRecipe);
    end

    if isempty(scene)
        error("Failed to render scene. dockerWrapper.reset() might help\n");
    end

    % add to our scene list for logging
    scenario.sceneList{end+1} = scene;

end

