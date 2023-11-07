function [oi_gt,sensor_gt,ip_gt] = GroundTruthGen(scene,oi,sensor,ip,parameters,type)

switch type
    case 'pinhole'
        oi_gt = oiSet(oi,'photons',oiCalculateIrradiance(scene,oi));
    case 'optics'
        fnumber = parameters.fnumber;
        focallength = parameters.focallength*2;
        nsides = parameters.nsides*5;
        imgSize = sceneGet(scene,'size');
        wvf = wvfCreate('spatial samples',ceil(sqrt(imgSize(1)^2+imgSize(2)^2)),'calc wavelengths', [400:10:700]);
        pupilMM = focallength/fnumber * 1e3;
        wvf = wvfSet(wvf,'calc pupil diameter',pupilMM);
        wvf = wvfSet(wvf,'focal length',focallength);

        [aperture] = wvfAperture(wvf,'nsides',nsides,...
            'dot mean',0, 'dot sd',0, 'dot opacity',0.5, 'dot radius',30,...
            'line mean',0, 'line sd', 0, 'line opacity',0.5, 'line width',10);
        wvf = wvfCompute(wvf,'aperture',aperture);
        oi_gt = oiCompute(wvf, scene);
        oi_gt = oiCrop(oi_gt,'border');
        oi_gt.wAngular = 34.2;
    case 'gaussian'
        oiG = oiCreate('shift invariant');
        OTF = oiGet(oiG,'optics OTF');
        nSamples = size(OTF,1);
        nWave    = size(OTF,3);
        sigma = 8;
        g = fspecial('gaussian',[nSamples nSamples],sigma);

        % The (1,1) position is in the upper left corner
        g = fftshift(g);

        % Replicate and set
        gOTF = repmat(g, [1 1 nWave]);
        oiG = oiSet(oiG,'optics OTF',gOTF);
        oiG = oiSet(oiG,'optics fnumber',parameters.fnumber);
        oiG = oiCompute(oiG,scene);
        oi_gt = oiCrop(oiG,'border');
        oi_gt.wAngular = 34.2;
    otherwise
        error('Only pinhole and optics are supported')
end
oi_gt = oiAdjustIlluminance(oi_gt, oiGet(oi, 'mean illuminance'));
sensor_gt = sensorCompute(sensor, oi_gt);
ip_gt = ipCompute(ip, sensor_gt);

end

