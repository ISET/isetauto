%% Create PNG with a rapid rendering of the cars


%% Open scitran
st = scitran('stanfordlabs');
st.verify;

%% Download the recipe and the zip file

%% Find the car session 
h = st.projectHierarchy('Graphics assets');

sLabels = stCarraySlot(h.sessions,'label');
idx = find(strcmp(sLabels,'car'));
thisSession = h.sessions{idx};
sid = st.objectParse(thisSession);

thisAcquisition = h.acquisitions{idx}{1};

%% Download the recipe and resource file
aid = st.objectParse(thisAcquisition);

%%
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
recipeStruct = st.fileRead(recipefile{1});
st.fileDownload(cgfile{1});
thisR = recipe;

% Unzip the resource file
unzip(cgfile{1}.file.name);
% Could delete(cgfile{1}.file.name)

%%  Read the recipe file

%% Invoke piRender



    