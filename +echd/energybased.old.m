% clear, clc, close all
%data_location='Data\180615';
% data_location='Data\180824';
% data_file='Cut31_S9000_N2_F2000_ap1p7_ae20_D20';
%   get the test information from the data file name
% Test=mal.echd.read_test_info(data_file); %   Read the test info of file name
function output = energybasedNotWOrking(data, properties)
%%
sampling = properties.sampling;
Ts = 1/sampling;
% Read input from text
% HK = dlmread([data_location,'\',data_file,'.txt']);
EN_RATIO_LIMIT=0.3; %*P*

%%  Signal That is to be analyzised
SigName ='Spindle Current';

%Select input
% data = HK(:,8);
IS.signals.values = data;

IS.time = (0:Ts:Ts*(length(data)-1))';
Fs = sampling;
% Test.SF = machining.toothPassingCalc(properties.S, properties.numFlutes)*properties.numFlutes;
% Test.TPE = machining.toothPassingCalc(properties.S, properties.numFlutes);
Test.SF = 150;
Test.TPE = 300;
%%  TPE KALMAN
n_tpe=20; %*P*

flute = 2; %*P*
lambda = 1e-6; %*P*
wH = Test.SF*2*pi;      % Spindle Frequency and its harmonics [rad/s]
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
    TP_PHI(2*i-1, 1) = cos(i*wH*sampling);
    TP_PHI(2*i, 1) = sin(i*wH*sampling);
end
%   Initial State Estimate (2*n)
TP_q0 = zeros(2*n_tpe, 1);
%    Inital Estimate Error Cov
TP_P0 = 1e1*eye(2*n_tpe);

Tsim = round(IS.time(end)/Ts)*Ts;
nd_mean = round((1/Test.SF)/Ts); % for block after kaiser
num_delay = round((1/Test.SF)/Ts/2) * 5 ;

[En_Threshold,w_BOL] = mal.echd.thresholdSet(SigName);

%%  DISPLAY THE IMPORTANT PARAMETERS

disp('********************************************')
disp(['>>>> ',properties.File,'<<<<'])
disp (['wS :', num2str(Test.SF,'%3.2f'), ' Hz, wT= ', num2str(Test.TPE,'%3.2f'), ' Hz'])
disp (['Kalman N :', num2str(n_tpe,'%3.0f'), ' upto wS*N = ', num2str(n_tpe*Test.SF,'%3.0f'), ' Hz'])
disp (['Kalman lambda :', num2str(TP_Q(1,1)/TP_R,'%3.2e')])
disp (['Kalman R :', num2str(TP_R,'%3.3e')])
disp (['Kalman Q :', num2str(TP_Q(1,1),'%3.3e')])
disp (['Energy Ratio Limit :', num2str(EN_RATIO_LIMIT, '%.2f')])
disp('********************************************')

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
B = zeros(m,2*n+1);
A = zeros(m, 2*n);
for i=1:m
    wn=m1+i-1;
    dt=0.05;
    pass_band = [wn, wn+1]*fT;
    [num, den] = mal.echd.band_pass_chatter(pass_band, Ts);
    
    B(i,:)= num;
    A(i,:)= den(2:2*n+1);
end

%% EQUATION 27
% Lag parameter FOR EACH FREQ INTERVAL
M = ones(1,m);
for i=1:m
    M(i)=round(Fs/(4*(m1+i)*fT+fT/2)+0.5);
end
nd = max(M);% number of delays for kaiser 4*nd

Test.D = 20;
Test.SF = 150;
Test.N = 2;
Test.TPE = 300;
Test.F = 2000;
Test.Fpt = 0.1111;
Test.ap = 1.7;
Test.ae = 20;
%%  RUN SIMULATION
% sim('yudi_KLM_simplified_Kalman')
simPath = "C:\Users\mhoss\Dropbox\Project MASc\Main\+mal\+echd\yudi_KLM_simplified_Kalman.slx";
% set_param(simPath,'Ts','25')
% sim(simPath)
options = simset('SrcWorkspace','current');
sim(simPath,[],options);
output = ChatterDetected.signals.values;
% max(output)
plot(output);
end