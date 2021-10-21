% clear, clc, close all
% %data_location='Data\180615';
% data_location='Data\180824';
% data_file='Cut31_S9000_N2_F2000_ap1p7_ae20_D20';
% %   get the test information from the data file name
% Test=read_test_info(data_file); %   Read the test info of file name

function [out] = energybased(data, properties, param)
% isDebugingOn = 1;


if ~isfield(param, 'sigName') % deafualt sigName
    param.SigName = 'Spindle Current';%del
end
%%
Test.SF = properties.S/60; % [rev/s - Hz] Spindle frequency [not sure]
Test.TPE = Test.SF/properties.numFlutes; % tooth passing frequency [Hz] 
%%
EN_RATIO_LIMIT = param.EN_RATIO_LIMIT;
SigName = param.SigName;


% TPE KALMAN

n_tpe = param.n_tpe;
lambda = param.lambda;
%%
Ts = 1/properties.sampling;           % Sampling time

%%  Signal That is to be analyzised
IS.signals.values = data;
IS.time = (0:Ts:Ts*(length(data)-1))';

%%  TPE KALMAN
flute = properties.numFlutes;
wH = Test.SF*2*pi;      % Spindle Frequency and its harmonics [rad/s] %*needChange*
%TP_R = cov((IS.signals.values(100:700,1))*pi/30);  % Measurement Covariance
TP_R = 8.539750000056574E-6;
%TP_Q = TP_R*1e-6*eye(2*n_tpe);                     % Coefficient Cov
TP_Q = TP_R*lambda;                                 % Coefficient Cov

%   Calculate the state and measurement matrix
% TP_PHI = zeros(2*n_tpe, 2*n_tpe);
% TP_H = zeros(1, 2*n_tpe);
% for i=1:n_tpe
%     TP_PHI(2*i-1:2*i, 2*i-1:2*i) = [cos(i*wH*Ts) -sin(i*wH*Ts); sin(i*wH*Ts) cos(i*wH*Ts)];
%     TP_H(1, 2*i-1) = 1;
% end

TP_PHI = zeros(2*n_tpe, 1);
for i=1:n_tpe
    TP_PHI(2*i-1, 1) = cos(i*wH*Ts);
    TP_PHI(2*i, 1) = sin(i*wH*Ts);
end
%   Initial State Estimate (2*n)
TP_q0 = zeros(2*n_tpe, 1);
%    Inital Estimate Error Cov
TP_P0 = 1e1*eye(2*n_tpe);

Tsim = round(IS.time(end)/Ts)*Ts;
nd_mean = round((1/Test.SF)/Ts); % for block after kaiser
num_delay = round((1/Test.SF)/Ts/2) * 5 ;

% [En_Threshold,w_BOL] = echd.thresholdSet(SigName);
% above line replacment
w_BOL=1;
En_Threshold = 1e-8;
if isfield(param, 'En_Threshold')
    En_Threshold = param.En_Threshold;
end

%%  DISPLAY THE IMPORTANT PARAMETERS

% disp('********************************************')
% disp(['>>>> ','WhatEv','<<<<'])
% disp (['wS :', num2str(Test.SF,'%3.2f'), ' Hz, wT= ', num2str(Test.TPE,'%3.2f'), ' Hz'])
% disp (['Kalman N :', num2str(n_tpe,'%3.0f'), ' upto wS*N = ', num2str(n_tpe*Test.SF,'%3.0f'), ' Hz'])
% disp (['Kalman lambda :', num2str(TP_Q(1,1)/TP_R,'%3.2e')])
% disp (['Kalman R :', num2str(TP_R,'%3.3e')])
% disp (['Kalman Q :', num2str(TP_Q(1,1),'%3.3e')])
% disp (['Energy Ratio Limit :', num2str(EN_RATIO_LIMIT, '%.2f')])
% disp('********************************************')

%%  Filter Design
Freq_start0 = Test.SF;
Freq_stop0 = Freq_start0*n_tpe;
fT = Test.TPE;

m1 = ceil(Freq_start0/fT);% Start Band
if(Freq_stop0 <= fT)
    m = 1;
else
    m = ceil(Freq_stop0/Test.TPE)*Test.TPE/fT-m1;% Number of filter- CHOOSE THIS ONE AS MULTIPLE OF FLUTES Test.N
end

StpBand_Mag = 5;%[dB] 2 original 5
Ripple_Mag = 2; %[dB] 1.1

n = 4; % constant order(4) of butterworth
m = floor(m);
n = floor(n);
B = zeros(m,2*n+1);
A = zeros(m, 2*n);
for i=1:m
    wn=m1+i-1;
    dt=0.05;
    pass_band = [wn, wn+1]*fT;
    [num, den] = echd.band_pass_chatter(pass_band, Ts);
    
    B(i,:)= num;
    A(i,:)= den(2:2*n+1);
end

%% EQUATION 27
% Lag parameter FOR EACH FREQ INTERVAL
M = ones(1,m);
for i=1:m
    M(i)=round(properties.sampling/(4*(m1+i)*fT+fT/2)+0.5);
end
nd = max(M);% number of delays for kaiser 4*nd
%%  RUN SIMULATION
% sim('yudi_KLM_simplified_Kalman')
% simPath = util.dirManipulator(mfilename('fullpath'),'..','energybasedHosseinEd.slx');
simPath = util.dirManipulator(mfilename('fullpath'),'..','improvedEnergyBased.slx');
% simPath = util.dirManipulator(mfilename('fullpath'),'..','yudi_KLM_simplified_Kalman.slx');
options = simset('SrcWorkspace','current');
sim(simPath,[],options);
out.detected = {ChatterDetected.signals.values};
out.ratio = {energyRatio.signals.values};
out.priodicEn = {priodicEn.signals.values};
% out.bandpassFiltersOut = {bandpassFiltersOut.signals.values};
out.kalmanOut =  {kalmanOut.signals.values};



if isfield(param, 'isDebugingOn') & param.isDebugingOn % debugging zone
    plot(data)
%     length(data)
    hold on
    plot(max(data)*out.detected{:})
%     length(output{:})
    hold off
%     disp(properties.Label{1})
    legend('Signal', '1: Chatter');
    disp([properties.Label{1},'->',num2str(properties.No)])
end
end