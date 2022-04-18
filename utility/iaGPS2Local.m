function [east, north, up] = iaGPS2Local(lat, lon, alt, origin)
%% ISET implementation of latlon2local
% Convert from geographic to local Cartesian coordinates
%   transforms point locations from (lat, lon, alt) in degrees and
%   meters to local Cartesian coordinates (xEast, yNorth, zUp) in meters.
%   The local coordinate system is anchored at origin specified as
%   [latOrigin, lonOrigin, altOrigin] vector. Local x, y, z coordinates 
%   are lined up with east, north and up directions respectively.
%   alt and altOrigin are altitudes as returned by a typical GPS sensor.
%
% Zhenyi, 2022
%{
lon = 0.00001;
lat = 0.0019;
alt = 0;
origin = [0,0,0]; % in LLA degree
[e, n, u] = iaGPS2Local(lat, lon, alt, origin)
% matlab implementation
[e_m, n_m, u_m] = latlon2local(lat, lon, alt, origin)
%}
num_samples = size(lat,1);
east = zeros(num_samples,1);
north = zeros(num_samples,1);
up = zeros(num_samples,1);

for ii = 1:num_samples
    ecefPOI = piGPS2ECEF(origin(1),origin(2),origin(3));

    ecefUser = piGPS2ECEF(lat(ii,1),lon(ii,1), alt(ii,1));


    delta_X=ecefUser(1)-ecefPOI(1);
    delta_Y=ecefUser(2)-ecefPOI(2);
    delta_Z=ecefUser(3)-ecefPOI(3);

    phi   =origin(1);
    lamda =origin(2);

    ECEF2ENU_matrix = [-sind(lamda),cosd(lamda),0;...
        -sind(phi)*cosd(lamda),-sind(phi)*sind(lamda),cosd(phi);...
        cosd(phi)*cosd(lamda),cosd(phi)*sind(lamda),sind(phi)];

    result = ECEF2ENU_matrix*[delta_X;delta_Y;delta_Z];

    east(ii,1)  = result(1);
    north(ii,1) = result(2);
    up(ii,1)    = result(3);
end
end

function ecef = piGPS2ECEF(lat, lon, alt)
a = 6378.137e3;
b = 6356.752314245e3;

e = 1-b^2/a^2;

N = a/sqrt(1 - e*(sind(lat))^2);

% LLA to ECEF
ecef(1)= (N + alt)*cosd(lat)*cosd(lon);
ecef(2) = (N + alt)*cosd(lat)*sind(lon);
ecef(3)= ((b^2/a^2)*N + alt)*sind(lat);
end









