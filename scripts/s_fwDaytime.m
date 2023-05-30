%% s_fwDaytime
%
% The sceneNames.txt for the daytime scenes exist in the local area.
%
% For each scene name, we assign it to a new session with 'day' appended to
% its current session name.  So 'city2_801' becomes 'city2_801_day'
%
%
%   
% See also
%   s_fwAutoScenesData
%

st = scitran('stanfordlabs');

%% Read the project
pname = 'CameraEval20190626';  % So far, all files were found.
project = st.lookup(sprintf('wandell/%s',pname));
subjects = project.subjects();

renderings = stSelect(subjects,'label','renderings','nocell',true);
allSessions = renderings.sessions();
fprintf('%d sessions for the renderings subject.\n',numel(allSessions));

total = 0;
for ii=1:numel(allSessions)
    n = numel(allSessions{ii}.acquisitions());
    total = total + n;
    fprintf('%d:  acq %d total %d\n',ii,n, total);
end

%%
thisLabel = 'city2';
sessions = stSelect(allSessions,'label',thisLabel,'contains',true);
fprintf('%d sessions with label %s.\n',numel(sessions),thisLabel);

% stPrint(sessions,'label');
% stPrint(sessions,'subject','label');
% stPrint(subjects,'label');

%% Load sceneNames.txt
curdir = pwd;
chdir(fullfile(iaRootPath,'local'));
fid = fopen('sceneNames.txt','r');
C = textscan(fid,'%s');
fclose(fid);

% Strip the jpg extension
fnames = C{1};
nFiles = numel(fnames);
for ii=1:nFiles
    [~,fnames{ii},~] = fileparts(fnames{ii});
    fnames{ii} = [fnames{ii},'.dat'];
end

%% Find an acquisition with a name inside the project

% Seems to be working ok with the CameraEval
thisFile = 'city2_14:58_v12.6_f209.08right_o270.00_201962792132.dat';
thisFile = 'city1_11:43_v6.4_f17.79left_o270.00_2019626205140_depth.dat'
thisFile = 'city1_15:17_v0.0_f51.19front_o270.00_2019626204257_mesh.dat'
thisFile = 'citymix_14:26_v13.0_f55.88front_o270.00_2019626174329_depth.dat';
thisFile = 'citymix_11:20_v13.2_f84.41rear_o270.00_2019626215249_depth.dat'
str = sprintf('file.name = %s AND project.label = %s',thisFile,pname);
srch = struct('structuredQuery', str, 'returnType', 'acquisition','allData',true);
result = st.fw.search(srch);

for ii=1:numel(fnames)
    % fnames{ii}(1:5)
    if contains(fnames{ii},'11:58'), disp(ii); end
end

%{

pname = 'ISETAutoEval20200108';

% This search file works.
fname = 'city1_11_04_hdr_realistic_realisticMat_motion_2020110201016.dat';

% It does not work for these two, even though they exist
fname = 'city2_12_43_simple_pinhole_nocolorMat_static_20201111123_depth.dat';
fname = 'city1_09_46_simple_pinhole_simpleMat_static_202011110252.dat'

str = sprintf('file.name = %s AND project.label = %s',fname,pname);
srch = struct('structuredQuery', str, 'returnType', 'acquisition')
result = st.fw.search(srch);

str = sprintf('file.name = %s',fname);
srch = struct('structuredQuery', str, 'returnType', 'file')
result = st.fw.search(srch);

% Try with CONTAINS.  Also works.
cnt = 'realisticMat_motion_2020110201016.dat';
str = sprintf('file.name CONTAINS %s AND project.label = %s',cnt,pname);
srch = struct('structuredQuery', str, 'returnType', 'file')
result = st.fw.search(srch);

% Testing
cnt = 'city1_09_46'; % _simple_pinhole_simpleMat_static_202011110252
str = sprintf('file.name CONTAINS %s AND project.label = %s',cnt,pname);
srch = struct('structuredQuery', str, 'returnType', 'file')
result = st.fw.search(srch);

% Works
acqLabel = 'city1_17_06_simple_pinhole_simpleMat_static_202011120626';
str = sprintf('acquisition.label = %s AND project.label = %s',acqLabel,pname);
srch = struct('structuredQuery', str, 'returnType', 'acquisition')
result = st.fw.search(srch);

% To get the full structure ...
acq = st.fw.get(result{1}.acquisition.id);

%}
thisStr = 'city2_12_43_simple';
thisFile = 'city2_12_43_simple_pinhole_nocolorMat_static_20201111123_depth.dat';
str = sprintf('file.name = %s AND project.label = %s',thisFile,pname);
str = sprintf('file.name CONTAINS %s AND project.label = %s',thisStr,pname);

srch = struct('structuredQuery', str, 'returnType', 'file')
result = st.fw.search(srch);

tmp = 'static_20201111123_mesh';
str = sprintf('file.name CONTAINS %s AND project.label = %s',tmp,pname);
srch = struct('structuredQuery', str, 'returnType', 'file');
result = st.fw.search(srch);

%% Try a search
%{
Search is one of the quickest ways: 

% Python
result = fw.search({'structured_query': 'file.name = Filename.dat', 'return_type': 'acquisition'})
result[0].acquisition.id

% Matlab translation by ChatGPT
result = fw.search(struct('structured_query', 'file.name = Filename.dat', 'return_type', 'acquisition'));

And if you know the project label

result = fw.search({'structured_query': 'file.name = Filename.dat AND project.label = <PROJECT_LABEL', 'return_type': 'acquisition'})
result[0].acquisition.id

% Translated to Matlab
% I need to re-write st.search for this new method
%
% result = fw.search(struct('structured_query', 'file.name = Filename.dat AND project.label = <PROJECT_LABEL', 'return_type', 'acquisition')
fname = 'city1_11_04_hdr_realistic_realisticMat_motion_2020110201016.dat';
pname = 'ISETAutoEval20200108';
str = sprintf('file.name = %s AND project.label = %s',fname,pname);
srch = struct('structuredQuery', str, 'returnType', 'acquisition')
result = st.fw.search(srch);


%}
%% Create a new session and add 100 acquisitions to it.
%
% Loop
% Maybe session name becomes name_001, name_101, name_201 ...
% There will be a lot of new sessions if it is just 100 at a time
% But so what?

% This is the good basis for a loop.
%{
thisName = sprintf('%s_%03d',from.label,1);

% I just made this routine use subject.addSession(); because it didn't work
% for project.addSession
% https://docs.flywheel.io/hc/en-us/requests/14282
%

id = st.containerCreate(project.group, project.label,...
                'subject','renderings',...
                'session',thisName);

session = st.fw.get(id.session);
st.containerDelete(session);
%}

% There are a lot of acquisitions.
acq = from.acquisitions();
disp(numel(acq));

%% Attach the acquisitions to a different session

for ii=1:100:numel(acq)
    thisName = sprintf('%s_%03d',from.label,ii);
    id = st.containerCreate(project.group, project.label,...
                'subject','renderings',...
                'session',thisName);
    for jj=ii:min(numel(acq),(ii+99))
        disp(acq{jj}.label);
        acq{jj}.update('session',id.session);
    end
end


%% Delete the empty acquisitions
sessions = project.sessions();
subSessions = stSelect(sessions,'label','city2_');
% stPrint(subSessions,'label');

for jj=1:numel(subSessions)
    thisS = subSessions{jj};
    % Remove the empty acquisitions.  There seem to be a lot of them.
    acqs = thisS.acquisitions();
    for ii=1:numel(acqs)
        if isempty(acqs{ii}.files)
            disp(acqs{ii}.label);
            st.containerDelete(acqs{ii});
        end
    end
end


%% Move
%
% 
%{
% Python method from Michael. 

from_session = fw.get_session('625087ba9c92d3627f6a5f86')
to_session = fw.get_session('62508289d123a9402356475f')
for a in from_session.acquisitions():
    print(a.label)
    a.update({'session': to_session.id})
%}