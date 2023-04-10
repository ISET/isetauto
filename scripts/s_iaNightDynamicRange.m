%% s_iaNightScenes
%
% 
%
% Examine some of the night time scenes acquired with bracketed exposure on
% the Google Pixel 4a
%
% Currently assumes we change directory to the location of the images
%{
% location on orange and mux
chdir('/acorn/data/iset/source_images/pixel4a/night_images/20221106');
% Legacy
% chdir('/Volumes/Wandell/nightscenes/20221106')
%}
%{
ddir = '/Volumes/GoogleDrive/My Drive/Data/Natural spectra dynamic range/night camera images (google pixel 4a)/20221106';
chdir(ddir)
%}

%% Camera was using speed of 437 for some reason
% Maybe we should set the speed to 55, which is unity gain.

% fname = 'IMG_20221106_180748';
% roinames = {'sky','lamp','road'};

basename = 'IMG_20221106_175143';
roinames = {'stop','sky','road'};

fname = sprintf('%s_%0d.dng',basename,4);
[sensor,info] = sensorDNGRead(fname);

roi = cell(3,1);
for ii=1:3
    roi{ii} = ieROISelect(sensor);
end


%%
ieNewGraphWin;
val = zeros(5,3);
t = zeros(5,1);
for jj=1:3
    for ii=0:4
        fname = sprintf('%s_%0d.dng',basename,ii);
        [sensor,info] = sensorDNGRead(fname);
        sensor = sensorSet(sensor,'roi',round(roi{jj}));
        dv = sensorGet(sensor,'roi dv');
        val(ii+1,:) = round(mean(dv,'omitnan'));
        t(ii+1) = info.ExposureTime;
    end
    plot(t,val(:,2),'go-','LineWidth',2); grid on;
    xlabel('Time (s)'); ylabel('DV'); hold on;
end


% for ii=0:4
%     fname = sprintf('%s_%0d.dng',basename,ii);
%     [sensor,info] = ieDNGRead(fname,'simple info',true,'only info',true);
% end



