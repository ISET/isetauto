%% Create PNG with a rapid rendering of the cars


%% Open scitran
st = scitran('stanfordlabs');
st.verify;

%% Download the recipe and the zip file

%% Find the car session
%
% thisSession = st.acquisitionGet('project label',Xxx,'session label',sLabel);
h = st.projectHierarchy('Graphics assets');

sLabels = stCarraySlot(h.sessions,'label');
idx = find(strcmp(sLabels,'car'));
thisSession = h.sessions{idx};

%%
sid = st.objectParse(thisSession);

thisAcquisition = h.acquisitions{idx}{1};
aid = st.objectParse(thisAcquisition);

%% Download the recipe and resource file

recipefile = st.search('file',...
    'project label exact','Graphics assets', ...
    'session id',sid,...
    'acquisition id',aid,...
    'file type', 'source code');

cgfile = st.search('file',...
    'project label exact','Graphics assets', ...
    'session id',sid,...
    'acquisition id',aid,...
    'file type', 'CG Resource');

%% Get the two files

chdir(fullfile(iaRootPath,'local'));
thisR = st.fileRead(recipefile{1},'file type','recipe'); % ,'file type','recipe');

st.fileDownload(cgfile{1});

% Unzip the resource file
unzip(cgfile{1}.file.name);
delete(cgfile{1}.file.name)
%%  We have what we need to create the Car_001 pbrt file
%
% We create it using piWrite with the recipe and pointers to the
% location of the scene and texture directories.

inputFile = fullfile(pwd,[thisAcquisition.label,'.pbrt']);
thisR.set('input file',inputFile);

if ~exist(thisAcquisition.label,'dir')
    mkdir(thisAcquisition.label);
end

outputFile = fullfile(tempdir,thisAcquisition.label,[thisAcquisition.label,'.pbrt']);
thisR.set('output file',outputFile);

%%  Read the recipe file

% This will be updated to replace as well as add
% piSkymapAdd(thisR,'sunset');

%% Invoke piRender
piWrite(thisR);




    