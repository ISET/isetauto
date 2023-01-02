%% Relate the fnumber/MTF issues to system performance for the auto case
%
% Illustrate the MTF through the diffraction-limited lens and a sensor with
% different pixel sizes.  Then use these same sensors and lenses with the
% metric scenes.
%
% This issue relates to the use of the MTF for autonomous driving.
% Remember the abstract that includes Alexander Braun and the work of the
% automobile committee.
%
% The final graph at the bottom compares the MTF 50 for an array of f/# and
% pixel sizes.  There are several
%
% See also
%   s_eiOpticsFnumber
%

%%
ieInit;

%% Multiple sensor pixel sizes from very small to very large

% Pixel sizes from ridiculously small to current large
% pSize = [1 2.1]*1e-6;
pSize = [1, 1.4, 2.1, 2.8, 3.5, 4.2]*1e-6;  % Meters
fov   = [2,  2,   3,   4,   5,   6];

% rect = [14 6 23 31;
%     30 10 34 62;
%     26 7 43 68;
%     29 12 40 63;
%     29 7 42 70;
%     28 5 43 72];     % 4.2 micron sensor
fnums = (1:0.5:12);

scene  = sceneCreate('slanted edge',1024);
oi     = oiCreate('diffraction limited');
sensor = sensorCreate;
sensor = sensorSet(sensor,'auto exposure',true);
ip     = ipCreate;

%% Loop over sensor sizes
for SS = 1:numel(pSize)

    thisFOV   = fov(SS);
    thisRect  = rect(SS,:);
    thisPsize = pSize(SS);
    fprintf('Pixel size %.2f\n',thisPsize*1e6);

    % Set a realistic light level
    scene = sceneSet(scene,'fov',thisFOV);
    % sceneWindow(scene);

    % Always set the pixel size prior to the field of view
    sensor = sensorSet(sensor,'pixel size constant fill factor',thisPsize);
    sensor = sensorSet(sensor,'fov',1.5*thisFOV,oi);

    %  Loop through the fnumbers for this sensor
    mtfHalf = zeros(numel(fnums),1);
    for ii = 1:numel(fnums)
        fprintf('%0.2f ',fnums(ii));

        oi = oiSet(oi,'fnumber',fnums(ii));
        oi = oiCompute(oi,scene);
        oi = oiSet(oi,'name',sprintf('%02.2f',fnums(ii)));
        % oiWindow(oi);

        sensor = sensorCompute(sensor,oi);
        sensorWindow(sensor);

        % Check ip properties
        ip = ipCompute(ip,sensor);
        % ipWindow(ip);

        mtfData = ieISO12233(ip,sensor,'none');

        if ii == 1
            freq = mtfData.freq;
            mtf = zeros(numel(freq),numel(fnums));
        end
        mtf(:,ii) = mtfData.mtf(:,4);
        mtfHalf(ii) = mtfData.mtf50;
    end
    % Save in a sensor file sensor-rounded(Psize)
    fname = sprintf('sensor-%02d',round(thisPsize*1e7));
    save(fname,'fnums','freq','mtf',"mtfHalf");

    fprintf('done with this sensor\n');

end

%%
SS = 1;
thisPsize = pSize(SS);
fname = sprintf('sensor-%d',round(thisPsize*1e7));
load(fname);

%%
ieNewGraphWin;
surf(fnums,freq,mtf);
set(gca,'ylim',[0 250])
grid on;
xlabel('f/#'); ylabel('Spatial frequency (c/mm)'); zlabel('SFR');
title(sprintf('Sensor: %0.1f',round(thisPsize*1e6,1)));

%%
ieNewGraphWin;
plot(freq,mtf);
grid on;
xlabel('Spatial frequency (c/mm)'); ylabel('Amplitude');
set(gca,'xlim',[0 400])

title(sprintf('Sensor: %0.1f',round(thisPsize*1e6,1)));

%%
ieNewGraphWin;
plot(fnums,mtfHalf);
xlabel('f/#'); ylabel('MTF 50 (c/mm)'); grid on;
title(sprintf('Sensor: %0.1f',round(thisPsize*1e6,1)));

%%
ieNewGraphWin;
[X,Y] = meshgrid(fnums,freq);
contourf(fnums,freq,mtf);
xlabel('f/#'); ylabel('Cyc/mm'); grid on;
title(sprintf('Sensor: %0.1f',round(thisPsize*1e6,1)));

%%
chdir(fullfile(iaRootPath,'papers','EI2023'));

ieNewGraphWin;
lgnd = cell(size(pSize));
for SS=1:numel(pSize)
    thisPsize = pSize(SS);
    fname = sprintf('sensor-%d',round(thisPsize*1e7));
    load(fname,'mtfHalf');
    hold on;
    lgnd{SS} = sprintf(' %0.1f um',round(thisPsize*1e6,1));
    plot(fnums,mtfHalf,'LineWidth',2);
end
xlabel('f/#'); ylabel('MTF 50 (c/mm)'); grid on;
legend(lgnd);


%% END
