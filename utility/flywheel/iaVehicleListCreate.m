function asset = iaVehicleListCreate(varargin)
% Create a struct of Flywheel assets 
%
% Description
%  The assets are found on Flywheel.  Each asset is stored with a
%  generic recipe that defines how to render it. The information about
%  all of the assets in the scene are placed in the returned asset
%  struct. This has slots like asset.bicycle()
%
% Inputs
%   N/A
%
% Optional key/value parameters
%   ncars
%   ntrucks
%   nped
%   nbuses
%   ncyclist
%   scitran
%
% Returns
%   assets - Struct with the asset geometries and materials
%
% Zhenyi, Vistasoft Team, 2018
% Zhenyi, updated, 2021

%% Parse input parameters
varargin =ieParamFormat(varargin);

p = inputParser;

p.addParameter('ncars',0);
p.addParameter('ntrucks',0);
p.addParameter('nped',0);
p.addParameter('nbuses',0);
p.addParameter('nbikes',0); % Cyclist contains two class: rider and bike.
p.addParameter('scitran','',@(x)(isa(x,'scitran')));

p.parse(varargin{:});

inputs = p.Results;
st     = p.Results.scitran;

if isempty(st), st = scitran('stanfordlabs'); end

%%  Store up the asset information
asset = [];
asset.car        = iaAssetListCreate('session', 'car',       'nassets', inputs.ncars,   'scitran', st);
asset.bus        = iaAssetListCreate('session', 'bus',       'nassets', inputs.nbuses,  'scitran', st);
asset.truck      = iaAssetListCreate('session', 'truck',     'nassets', inputs.ntrucks, 'scitran', st);
asset.pedestrian = iaAssetListCreate('session', 'pedestrian','nassets', inputs.nped,    'scitran', st);
asset.bicycle    = iaAssetListCreate('session', 'bike',      'nassets', inputs.nbikes,  'scitran', st);



%%
disp('Vehicle lists are created!')
end