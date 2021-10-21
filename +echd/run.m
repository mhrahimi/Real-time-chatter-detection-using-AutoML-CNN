function output = run(data, properties, echdParam)
%% param
if ~isfield(echdParam, 'sigName') % deafualt sigName
    echdParam.SigName = 'Spindle Current';%del
end
energyRatioLimit = echdParam.EN_RATIO_LIMIT;
sigName = echdParam.SigName;

% TPE KALMAN
n_tpe = echdParam.n_tpe;
lambda = echdParam.lambda;
%%
spindleFreq = properties.S/60; % [rev/s - Hz] Spindle frequency [not sure]  Test.SF
Test.SF = spindleFreq;
toothPassingFreq = Test.SF/properties.numFlutes; % tooth passing frequency [Hz]     Test.TPE
samplingFreq = Test.SF;
samplingInterval = 1/properties.sampling;           % Sampling time
numFlute = properties.numFlutes;
%%
wH = samplingFreq*2*pi;      % Spindle Frequency and its harmonics [rad/s] %*needChange*
TP_R = 8.539750000056574E-6;
TP_Q = TP_R*lambda;    %TP_Q = TP_R*1e-6*eye(2*n_tpe);   % Coefficient Cov

TP_PHI = zeros(2*n_tpe, 1);
for i=1:n_tpe
    TP_PHI(2*i-1, 1) = cos(i*wH*samplingInterval);
    TP_PHI(2*i, 1) = sin(i*wH*samplingInterval);
end

TP_q0 = zeros(2*n_tpe, 1);%   Initial State Estimate (2*n)

TP_P0 = 1e1*eye(2*n_tpe);%    Inital Estimate Error Cov

nd_mean = round((1/samplingFreq)/samplingInterval); % for block after kaiser
num_delay = round((1/samplingFreq)/samplingInterval/2) * 5 ;

%% threshold
w_BOL=1;
En_Threshold = 2e-6;
%%  Filter Design
fil.startFreq = samplingFreq;
fil.stopFreq = fil.startFreq * n_tpe;

fil.startBand = ceil(fil.startFreq/toothPassingFreq);% Start Band
if(fil.stopFreq <= toothPassingFreq)
    m = 1;
else
    m = ceil(fil.stopFreq/toothPassingFreq)*toothPassingFreq/...
        toothPassingFreq-fil.startBand;% Number of filter- CHOOSE THIS ONE AS MULTIPLE OF FLUTES Test.N
end

fil.stopBand = 5;%[dB] 2 original 5
Ripple_Mag = 2; %[dB] 1.1

n = 4; % constant order(4) of butterworth
m = floor(m);
n = floor(n);
B = zeros(m,2*n+1);
A = zeros(m, 2*n);
for i=1:m
    wn = m1 + i - 1;
    dt=0.05;
    pass_band = [wn, wn+1]*toothPassingFreq;
    [num, den] = echd.band_pass_chatter(pass_band, samplingInterval);
    
    B(i,:)= num;
    A(i,:)= den(2:2*n+1);
end
%% EQUATION 27
% Lag parameter FOR EACH FREQ INTERVAL
M = ones(1,m);
for i=1:m
    M(i)=round(properties.sampling/(4*(m1+i)*toothPassingFreq+toothPassingFreq/2)+0.5);
end
nd = max(M);% number of delays for kaiser 4*nd
%%  RUN SIMULATION
% sim('yudi_KLM_simplified_Kalman')
simPath = util.dirManipulator(mfilename('fullpath'),'..','energybasedHosseinEd.slx');
% simPath = util.dirManipulator(mfilename('fullpath'),'..','yudi_KLM_simplified_Kalman.slx');
options = simset('SrcWorkspace','current');
sim(simPath,[],options);
output = {ChatterDetected.signals.values};

if isfield(echdParam, 'isDebugingOn') && echdParam.isDebugingOn % debugging zone
    plot(data)
%     length(data)
    hold on
    plot(max(data)*output{:})
%     length(output{:})
    hold off
%     disp(properties.Label{1})
    legend('Signal', '1: Chatter');
    disp([properties.Label{1},'->',num2str(properties.No)])
end
%% RUN
% xxxxxxxxxxxxxxxxxxx
%% 

%% 
time = (0:samplingInterval:samplingInterval*(length(data)-1))';
Tsim = round(IS.time(end)/Ts)*Ts;
end