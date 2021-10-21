clc
close all
clear all

% data = ones(1e3, 1);
filePath = "C:\Users\mhoss\Dropbox\Project MASc\DATA\Final\1\1-7220_S_F_D_.lvm";
[allData, details] = tools.reader.fileHandler(filePath);
allData = allData.Mic;
n = 1;
rawDataRoot = "C:\Users\mhoss\Dropbox\Project MASc\DATA\Final";
allProp = load(fullfile(rawDataRoot, "batchProp.mat"));
properties = (allProp.batchProp);
thisProp = properties(n,:);
%%
clc
data = allData(8294070:9190460);
% disp("Starting EB")
f = waitbar(0,"Starting EB - Setting the object...");

prop.sampling = thisProp.sampling;
prop.S = thisProp.S;
prop.numFlutes = thisProp.numFlutes;

% param.numHarmonics = 20; 
param.numHarmonics = 5;  
param.errCov = 2; % errCov
param.lambda = 1e-6;
param.filters.order = 4; % need to be added
param.meanFilter.delay = round((prop.S * prop.sampling) / 60); % spindle frequency has been used
param.eta = 1;

N_ = param.numHarmonics;
numOfFlute = prop.numFlutes;
spindleSpeed = prop.S;
samplingPeriod = prop.sampling;
lamda = param.lambda;
R_ = param.errCov;
numOfBand= 10; % CHECK & CHANGE
energyThreshold = .9; % MADEUP      CChatterDetection
energyRatioLimit = 12; % MADEUP     CChatterDetection
integrationFactor = param.eta;
chatterEnergyThreshold = .9; % MADEUP
ndMean = 20;  % MADEUP
delay = param.meanFilter.delay;

aa = CChatterDetectionSystem(N_, numOfFlute, spindleSpeed,...
                samplingPeriod, lamda, R_, numOfBand, energyThreshold, energyRatioLimit, ...
                integrationFactor, chatterEnergyThreshold, ndMean, delay);
%%
% clc
dataLen = length(data);
bb = zeros(dataLen, 1);
for i = 1:dataLen
    aa.Run(data(i));
    bb(i) = aa.ChatterDetection.ChatterDetected;
    cc(i) = aa.ChatterDetection.EnergyRatio;
    waitbar(i/dataLen,f,['Processing ', num2str(i), ' out of ',num2str(dataLen)]);
    if mod(i, 10000) == 0
        plot(cc);
    end
end

















% [ER, EN_p, EN_c, sHat_p] =  energyBased.run(allData, prop, param);
% subplot(5,1,1);
% plot(data(1:ii));
% title("Data");
% subplot(5,1,2);
% plot(sHat_p);
% title("sHat_p");
% subplot(5,1,3);
% plot(EN_p);
% title("EN_p");
% subplot(5,1,4);
% plot(EN_c);
% title("EN_c");
% subplot(5,1,5);
% plot(ER);
% title("ER");
% drawnow;


% plot(data)
% hold on
% plot(estimation/50000)
% hold off

