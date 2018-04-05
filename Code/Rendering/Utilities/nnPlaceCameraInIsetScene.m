function [ scene ] = nnPlaceCameraInIsetScene( scene, camera )

global lensDir;

switch camera.type
    case 'lens'
        scene.camera.subtype = 'realisticDiffraction';
        scene.set('lensfile',fullfile(lensDir,sprintf('%s.dat',camera.lens)));
        scene.set('diffraction',camera.diffraction);
        scene.set('chromatic aberration',camera.chromaticAberration);
        scene.set('nmicrolens',eval(sprintf('[%s]',camera.microlens)));
        scene.set('microlens',0);
        
    case 'pinhole'
        scene.camera.subtype = 'pinhole';
end


camPos = eval(sprintf('[%s]*1000',camera.position));
lookAt = eval(sprintf('[%s]*1000',camera.lookAt));
ptr = eval(sprintf('deg2rad([%s])',camera.PTR));

lookDir = lookAt-camPos;
upDir = [0 0 -1];


tr2 = mexximpPTR(ptr(1),ptr(2),ptr(3),lookDir,upDir);


newLookAt = mexximpApplyTransform(lookDir',tr2)+camPos';
newUpDir = mexximpApplyTransform(upDir',tr2);

scene.set('film diagonal',eval(camera.filmDiagonal));
scene.set('focal distance',eval(camera.filmDistance));
scene.set('pixel samples',eval(camera.pixelSamples));
scene.set('from',camPos);
scene.set('to',newLookAt');
scene.set('up',newUpDir');
scene.set('film resolution',eval(sprintf('[%s]',camera.filmResolution)));





end

