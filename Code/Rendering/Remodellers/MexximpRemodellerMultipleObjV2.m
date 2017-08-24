function [ scene, mappings ] = MexximpRemodellerMultipleObjV2( scene, mappings, names, conditionValues, conditionNumber )

cameraPosition = rtbGetNamedNumericValue(names,conditionValues,'position',[]);
cameraLookAt = rtbGetNamedNumericValue(names,conditionValues,'lookAt',[]);
cameraPTR = rtbGetNamedNumericValue(names,conditionValues,'PTR',[0 0 0]);

objMovementFile = rtbGetNamedValue(names,conditionValues,'objPosFile','');


%% Add a camera
scene = mexximpCentralizeCamera(scene);
lookUp = [0 0 -1];
cameraLookDir = cameraLookAt - cameraPosition;
cameraPTR = deg2rad(cameraPTR);

transformation = mexximpLookAt(1000*cameraPosition,1000*cameraLookAt,lookUp);
ptrTransform = mexximpPTR(cameraPTR(1), cameraPTR(2), cameraPTR(3), cameraLookDir, lookUp);


cameraId = strcmp({scene.rootNode.children.name},'Camera');
scene.rootNode.children(cameraId).transformation = transformation*mexximpTranslate(-1000*cameraPosition)*ptrTransform*mexximpTranslate(1000*cameraPosition);


%% Translate the objects

objects = loadjson(objMovementFile,'SimplifyCell',1);

for i=1:length(scene.rootNode.children)
    for o=1:length(objects)
        if isempty(strfind(scene.rootNode.children(i).name,objects(o).prefix)) == false
    
            position = objects(o).position*1000;
            orientation = objects(o).orientation;
            
            scene.rootNode.children(i).transformation = scene.rootNode.children(i).transformation*...
           mexximpRotate([0 0 -1],deg2rad(orientation))*mexximpTranslate(position);
        end
       
   end
end

end

