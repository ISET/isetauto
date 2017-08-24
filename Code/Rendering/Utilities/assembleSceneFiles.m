function [ sceneFiles ] = assembleSceneFiles( dataFiles )

loc = cellfun(@(x) strfind(x,'_frame_'),dataFiles,'UniformOutput',false);
frames = cellfun(@(x,y) sscanf(x(y+length('_frame_'):end),'%i'),dataFiles,loc);
frameIds = unique(frames);

sceneFiles = [];
for f=1:length(frameIds)
    
    frameId = cellfun(@(x) ~isempty(strfind(x,sprintf('_frame_%i_',f))),dataFiles);
    
    subDataFiles = dataFiles(frameId);
    
    depthFile = subDataFiles(cellfun(@(x) ~isempty(strfind(x,'depth')),subDataFiles));
    if isempty(depthFile), depthFile = []; else depthFile=depthFile{1}; end
    meshFile =  subDataFiles(cellfun(@(x) ~isempty(strfind(x,'mesh')),subDataFiles));
    if isempty(meshFile), meshFile = []; else meshFile=meshFile{1}; end
    materialFile = subDataFiles(cellfun(@(x) ~isempty(strfind(x,'material')),subDataFiles));
    if isempty(materialFile), materialFile = []; else materialFile=materialFile{1}; end

    
    radianceFiles = subDataFiles(cellfun(@(x) ~isempty(strfind(x,'radiance')),subDataFiles));
    for j=1:length(radianceFiles);
       
        subScene.radiance = radianceFiles{j};
        subScene.depth = depthFile;
        subScene.mesh = meshFile;
        subScene.material = materialFile;
        
        sceneFiles = cat(1,sceneFiles,subScene);
    end
end



end

