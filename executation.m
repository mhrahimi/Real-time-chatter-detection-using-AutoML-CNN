%   This is the main routine of the Machine Learning Machining state
%   detection method.
%   This code and all of dependent codes and models are the  
%   intellectual property of M.Hossein Rahimi.
%   
%   Copyright 2021 MohammadHossein Rahimi. 
%
%%
clc
close all 
clear all
%% Reading data
filePath = "C:\Users\mhoss\Dropbox\Project MASc\Main - Small\+run\combined_chatter6567.mp3";
[rawData, originalFs] = audioread(filePath);
rawData = rawData(:, 1);

prop.S = 12500; % Spindle speed [RPM]
prop.sampling = originalFs; % File Sampling Frequency [Hz]
prop.numFlutes = 4; % Number of flutes

% machining.plt(rawData,prop) % Plotting with harmonics


% filePath = "C:\Users\mhoss\Dropbox\Project MASc\Main - Small\+run\metalcutting_nochatter8058.mp3";
% [rawData, originalFs] = audioread(filePath);
% rawData = rawData(:, 1);
% 
% prop.S = 15000; % Spindle speed [RPM]
% prop.sampling = originalFs; % File Sampling Frequency [Hz]
% prop.numFlutes = 4; % Number of flutes
%% Data preprocessing
Fs = 50e3; % sampling frequency

prop.sampling = Fs; % File Sampling Frequency [Hz]
% data = resample(rawData,originalFs,Fs);
data = upsample(rawData,floor(Fs/originalFs));
time = 0:1/Fs:(length(data)-1)/Fs;
% machining.plt(data,prop) % Plotting with harmonics

%% Transformation into Frequency-domain
spectogramParam.padding = false;
spectogramParam.windowLength = 800;
spectogramParam.numOverlap = round(0.85 * spectogramParam.windowLength);
spectogramParam.fftLength = spectogramParam.windowLength;

% [output, filePath] = frequencyDomainConversion(data, prop, spectogramParam);

%% Detection loop
clc
figure;
subplot(2,1,1)
plot(data)
subplot(2,1,2)

windowSize = 7000;
loadingProgress = waitbar(0,'Loading the model...');
load("hosseinNet.mat"); % Loading the model (may take a while)

jj = 1; % array counter
runningStepSize = 5e2;
for ii = windowSize+1:runningStepSize:length(data)
    thisSlice = data(ii-windowSize : ii);
    [thisSTFT] = ...
        frequencyDomainConversion(thisSlice, prop, spectogramParam);
    [machiningState(jj), probability{jj}] = classify(hosseinNet, thisSTFT);
    sampleNo(jj) = ii;
    jj = jj + 1;
    waitbar(ii/length(data), loadingProgress, 'Detecting maching states');
    
    plot(sampleNo, machiningState)
    xlim([0 length(data)])
end
close(loadingProgress)

