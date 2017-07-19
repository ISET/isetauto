function [ scene, mappings ] = MexximpRemodeller( scene, mappings, names, conditionValues, conditionNumber )

shadowDirection = eval(rtbGetNamedValue(names,conditionValues,'shadowDirection',[]));
cameraPosition = eval(rtbGetNamedValue(names,conditionValues,'cameraPosition',[]));
cameraLookAt = eval(rtbGetNamedValue(names,conditionValues,'cameraLookAt',[]));

cameraPan = rtbGetNumericValue(names,conditionValues,'cameraPan',[0]);
cameraTilt = rtbGetNumericValue(names,conditionValues,'cameraTilt',[0]);

% Point the camera towards the scene
% [scene, camera, cameraNode] = mexximpCentralizeCamera(scene,'viewAxis',[0 1 0],...
%                                                            'viewUp',[0 0 -1]);

% This adds a camera
scene = mexximpCentralizeCamera(scene,'viewAxis',[1 0 0],...
                                      'viewUp',[0 0 1]);
              
                                  
m1 = mexximpRotate([0 0 -1],deg2rad(cameraPan));
m2 = mexximpRotate(cross([0 0 -1],cameraLookAt),deg2rad(cameraTilt));
                                  
cameraId = strcmp({scene.rootNode.children.name},'Camera');
scene.rootNode.children(cameraId).transformation = mexximpLookAt(1000*cameraPosition,1000*cameraLookAt,[0 0 -1])*m1*m2;



%scene = mexximpAddLanterns(scene);


ambient = mexximpConstants('light');
ambient.position = [0 0 0]';
ambient.type = 'directional';
ambient.name = 'SunLight';
ambient.lookAtDirection = shadowDirection(:);
ambient.ambientColor = 100000*[1 1 1]';
ambient.diffuseColor = 100000*[1 1 1]';
ambient.specularColor = 100000*[1 1 1]';
ambient.constantAttenuation = 1;
ambient.linearAttenuation = 0;
ambient.quadraticAttenuation = 1;
ambient.innerConeAngle = 0;
ambient.outerConeAngle = 0;

scene.lights = [scene.lights, ambient];

ambientNode = mexximpConstants('node');
ambientNode.name = ambient.name;
ambientNode.transformation = eye(4);

scene.rootNode.children = [scene.rootNode.children, ambientNode];




end

