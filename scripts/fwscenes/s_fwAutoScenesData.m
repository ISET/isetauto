%% Illustrate how to download ISETAuto .dat files and create an ISET scene
%  Maybe an EXR file.

%%
st = scitran('stanfordlabs');

project = st.lookup('wandell/ISETAutoEval20200108');
sessions = project.sessions();
subjects = project.subjects();

%% Try a search
% Search for scenes
res = st.search('acquisition',...
          'project label exact',project.label,...
          'subjectcode','renderings',...
          'fw',true);
%%
stPrint(sessions,'label');
stPrint(subjects,'label');

% Also works.  Maybe more informative
stPrint(sessions,'subject','label');

%% This is a big list - 3612 acquisitions  It takes a while to download.
% We should really reorganize these renderings on Flywheel to, say, no
% more than 500 acquisitions per session.
%

acq = sessions{1}.acquisitions();

%% Download all the files from the first acquisition

chdir(fullfile(iaRootPath,'local','datrenderings'));

baseName = 'city1_11_04_hdr_realistic_realisticMat_motion_2020110201016';
baseName = 'suburb_15_36_hdr_realistic_realisticMat_motion_202011295724';

wave = 400:10:700;
energy = piReadDAT([baseName,'.dat']);
photons = Energy2Quanta(wave,energy);
imagesc(sum(photons,3));
colormap(gray);

depth = piReadDAT([baseName,'_depth.dat']);
imagesc(depth); colormap(gray);
labels = piReadDAT([baseName,'_mesh.dat']);
imagesc(labels); colormap(jet);

scene = sceneCreate('empty');
scene = sceneSet(scene,'wavelength',wave);
scene = sceneSet(scene,'photons',photons);
scene = sceneSet(scene,'depthmap',depth);
scene = sceneSet(scene,'fov',40);
scene = sceneSet(scene,'mean luminance',(0.1*randn(1,1) + 1)*300);
scene.metadata.labels = labels;
sceneWindow(scene);

% Denoise
scene = piAIdenoise(scene);
sceneWindow(scene);


isetObj = piDat2ISET(fullfile(localDirectory,res{i}.label,'renderings',sprintf('%s.dat',res{i}.label)),...
        'label','radiance','recipe',thisR);