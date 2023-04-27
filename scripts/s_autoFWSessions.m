%% s_autoFWSessions
%
% Move the rendered data into smaller size sessions to make our lives
% simpler.  The download time for 3612 acquisitions, which is what we
% have in some single sessions, is too long. 
%
%
% See also
%   

st = scitran('stanfordlabs');

project = st.lookup('wandell/ISETAutoEval20200108');
sessions = project.sessions();
subjects = project.subjects();

stPrint(sessions,'label');
stPrint(sessions,'subject','label');
stPrint(subjects,'label');

% This is the first one with subject renderings
from = sessions{7};
disp(from.label)
disp(from.subject.label)

%% Create a new session and add 100 acquisitions to it.
%
% Loop
% Maybe session name becomes name_001, name_101, name_201 ...
% There will be a lot of new sessions if it is just 100 at a time
% But so what?

% This is the good basis for a loop.
%{
thisName = sprintf('%s_%03d',from.label,1);

% I just made this use subject.addSession();
id = st.containerCreate(project.group, project.label,...
                'subject','renderings',...
                'session',thisName);

session = st.fw.get(id.session);
st.containerDelete(session);
%}

% There are a lot of acquisitions.
acq = from.acquisitions();
disp(numel(acq));

%% Sessions of 100 scenes.

for ii=201:100:numel(acq)
    thisName = sprintf('%s_%03d',from.label,ii);
    id = st.containerCreate(project.group, project.label,...
                'subject','renderings',...
                'session',thisName);
    for jj=ii:(ii+99)
        disp(acq{jj}.label);
        acq{jj}.update('session',id.session);
    end
end

% Remove the empty acquisitions.  There seem to be a lot of them.
newSession = st.fw.get(id.session);
newAcq = newSession.acquisitions();
for ii=1:numel(newAcq)
    if isempty(newAcq{ii}.files)
        st.containerDelete(newAcq{ii});
    end
end
fprintf('Remaining acq %d\n',numel(newSession.acquisitions()));


%% Move
%{
% Python method from Michael. 

from_session = fw.get_session('625087ba9c92d3627f6a5f86')
to_session = fw.get_session('62508289d123a9402356475f')
for a in from_session.acquisitions():
    print(a.label)
    a.update({'session': to_session.id})
%}