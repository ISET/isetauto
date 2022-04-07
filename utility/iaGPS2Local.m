


function [e, n, u] = iaGPS2Local(lat, lon, alt, origin)
%%
%
%{
lon = 0;
lat = 0.0017966305679426294;
alt = 0;
origin = [0,0,0]; % in LLA degree
[e, n, u] = piGPS2Local(lat, lon, alt, origin)
% matlab implementation
[e_m, n_m, u_m] = latlon2local(lat, lon, alt, origin)
%}

ecefPOI = piGPS2ECEF(origin(1),origin(2),origin(3));

ecefUser = piGPS2ECEF(lat,lon, alt);


vector(1)=ecefUser(1)-ecefPOI(1);
vector(2)=ecefUser(2)-ecefPOI(2);
vector(3)=ecefUser(3)-ecefPOI(3);

e = vector(1)*(-sind(lon)) + vector(1)*cosd(lon);
n = vector(1)*(-sind(lat))*cosd(lon) + vector(2)*(-sind(lat))*(sind(lon)) + vector(3)*cosd(lat);
u = vector(1)*(cosd(lat))*cosd(lon) + vector(2)*(cosd(lat))*(sind(lon)) + vector(3)*sind(lat);
end



function ecef = piGPS2ECEF(lat, lon, alt)
a = 6378.1e3;
b = 6356.8e3;

e = 1-b^2/a^2;

N = a/sqrt(1 - e*(sind(lat)^2));

cosLatRad = cosd(lat);
cosLongiRad = cosd(lon);

% LLA to ECEF
ecef(1)= (N + alt)*cosd(lat)*cosd(lon);
ecef(2) = (N + alt)*cosd(lat)*sind(lon);
ecef(3)= ((b^2/a^2)*N + alt)*sind(lat);
end









