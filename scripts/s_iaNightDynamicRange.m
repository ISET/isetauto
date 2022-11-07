%% s_iaNightScenes
%
% 
%
% Examine some of the night time scenes acquired with bracketed exposure on
% the Google Pixel 4a
%
%{
chdir('/Volumes/Wandell/nightscenes/20221106')
%}
%{
ddir = '/Volumes/GoogleDrive/My Drive/Data/Natural spectra dynamic range/night camera images (google pixel 4a)/20221106';
chdir(ddir)
%}

%% Camera was using speed of 437 for some reason
% Maybe we should set the speed to 55, which is unity gain.

fname = 'IMG_20221106_180748';
fname = [fname,'_4.dng'];

exist(fname,'file')

[sensor,info] = sensorDNGRead(fname);
sensorWindow(sensor);

roi = cell(3,1);
names = {'sky','lamp','road'};
for ii=1:3
    roi{ii} = ieROISelect(sensor);
end

sensor = sensorSet(sensor,'roi',round(rect.Position));
dv = sensorGet(sensor,'roi dv');
mean(dv,'omitnan')

%%
basename = 'IMG_20221106_180748';

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
    plot(t,val(:,3),'go-'); grid on;
    xlabel('Time (s)'); ylabel('DV'); hold on;
end


% for ii=0:4
%     fname = sprintf('%s_%0d.dng',basename,ii);
%     [sensor,info] = ieDNGRead(fname,'simple info',true,'only info',true);
% end



