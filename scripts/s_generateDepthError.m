%% Visulization of pile-up efffect of single photon detection
% ref: Photon-Flooded Single-Photon 3D Cameras
function estimateDistance = generateDepthError(varargin)
p=inputParser;
varargin = ieParamFormat(varargin);
p.addParameter('distance',20);% distance in meters of the scene point from the sensor;
p.addParameter('signalmean',1);
p.addParameter('bkgmean',3e-3);
p.addParameter('maxDistance',80);
p.addParameter('correction',true);

p.parse(varargin{:});
distance = p.Results.distance;
maxDistance = p.Results.maxDistance;
Phi_signal_mean = p.Results.signalmean;
Phi_bkg_mean = p.Results.bkgmean;
correction = p.Results.correction;
SNR = 20*log10(Phi_signal_mean/Phi_bkg_mean);
%% laser pulse
c = ieConstants('c'); % m/s
% laser pulse
tau = 2*distance/c;
period = maxDistance*2/c;

delta = 200*1e-12;% seconds; resolution
B = ceil(period/delta); % total number of time bins
dead_time = 200*1e-9;% seconds

%%

N = 1500;% number of laser cycles

% P = zeros(1,B);
r = zeros(1,B);
r(1:B) = Phi_bkg_mean;
index = floor(tau/delta);
if index==0
    estimateDistance = 0;
    return
end
r(index) = Phi_signal_mean + Phi_bkg_mean;
sum_r_k = zeros(B,1);
sum_r_k(1) = 0;
sum_r_k(2:end) = cumsum(r(1:(B-1)));
sum_r_k = sum_r_k';
P = (1 - exp(-r)).*exp(-sum_r_k);
photon_tmp = binornd(1,P);
detection_index = find(photon_tmp>0);
for d_i = 1:length(detection_index)
    if (B-detection_index(d_i))*delta<dead_time
        P(detection_index+1:end)=0;
    end
end

%%
%{
for ii = 1:B
    if tau>ii*delta && tau<(ii+1)*delta
        r(ii) = Phi_signal_mean + Phi_bkg_mean;
    else
        r(ii) = Phi_bkg_mean;
    end
    if ii == 1
        sum_r_k = r(ii);
    else
        sum_r_k = sum(r(1:(ii-1)));
    end
    % Probablity of detecting a photon in the ii-th bin;
    P(1,ii) = (1 - exp(-r(ii)))*exp(-sum_r_k);
    
    if P(1,ii)>0
        photon = binornd(1,P(1,ii));
        if photon(1)>0 && (B-ii)*delta<dead_time
            break % dead time
        end
    end
end
%}
%%
P_m = P;
P_m(1,B+1)=1-sum(P);
measuredPhotonsHist = mnrnd(N,P_m);

% figure;plot(measuredPhotonsHist(1:B)/N,'-s','LineWidth',2);
% title('multinomial distribution: measured histogram')
%% coates's correction
if correction
    r_est = zeros(1,B+1);
    N_c = sum(measuredPhotonsHist(:));
    sum_k = cumsum(measuredPhotonsHist(1:B));
    r_est(2:end) = log((N_c-sum_k)./(N_c-sum_k-measuredPhotonsHist(2:end)));
    %{
    figure;
    plot(r_est(1:B),'-s','LineWidth',2);
    title('Coates corrected.')
    %}
    r_est=r_est(1:B);
    indices_coates = find(r_est==max(r_est(~isinf(r_est))));
    estimateDistance = delta*indices_coates(randi(length(indices_coates)))*c/2;
%     fprintf('Coates approach estimation: %.4f \n',d_est_coates);
else
    %% naive approach
    indices=find(measuredPhotonsHist==max(measuredPhotonsHist));
    estimateDistance = delta*indices(randi(length(indices)))*c/2; 
end

end
%% Optimal Flux Criterion
% bin receptivity coefficient C_i of the i-th histogram bin:
% C_i = P(i)*sum(r(1:B))/r(i);








