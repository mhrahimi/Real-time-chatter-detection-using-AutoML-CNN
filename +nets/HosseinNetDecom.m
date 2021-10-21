function [lgraph, options] = HosseinNetDecom(valImgs, inParam, optParam)
%% Deafualt values
% inputSize = [400 52 1]; % Constant
%
% conv(1).size = [20 3];
% conv(1).num = 96;
% conv(2).size = [8 3];
% conv(2).num = 128;
% conv(3).size = [5 2];
% conv(3).num = 384;
% conv(4).size = [5 2];
% conv(4).num = 192;
% conv(5).size = [5 2];
% conv(5).num = 128;
% conv(6).size = [5 2];
% conv(6).num = 100;
%
% NN(1) = 1024;
% NN(2) = 1024;
% NN(3) = 1024;
% NN(4) = numLabels; % Constant
%
% numConv = length(conv);
% numNN = length(NN);
%% Bayesian Optimization
% numConv = 4; % [3:6]
% numNN = 3; % [2:4]
% 
% fr = 3; % [1:7] % filter Ratio
% 
% c(1).s = 20; % [9:35]
% c(1).s = [c(1).s, ratioFunc(c(1).s, fr)];
% c(1).n = 90; % [10:100]
% 
% c(2).s = 8; % [6:20]
% c(2).s = [c(2).s, ratioFunc(c(2).s, fr)];
% c(2).n = 100; % [20:150]
% 
% c(3).s = 5; % [3:10]
% c(3).s = [c(3).s, ratioFunc(c(3).s, fr)];
% c(3).n = 300; % [40:400]
% 
% c(4).s = 5; % [3:10]
% c(4).s = [c(4).s, ratioFunc(c(4).s, fr)];
% c(4).n = 200; % [30:200]
% 
% c(5).s = 5; % [3:10]
% c(5).s = [c(5).s, ratioFunc(c(5).s, fr)];
% c(5).n = 100; % [10:300]
% 
% c(6).s = 5; % [3:10]
% c(6).s = [c(6).s, ratioFunc(c(6).s, fr)];
% c(6).n = 50; % [5:150]
% 
% n(1) = 512;
% n(2) = 512;
% n(3) = 512;
%%
verboseIsOn = false;
%% Tweaking

numConv = optParam.numConv; % [3:6]
numNN = optParam.numNN; % [2:4]

ratioFunc = @(s, r) max(1, round(s/r));

fr = optParam.fr; % [1:7] % filter Ratio

c(1).s = optParam.c1s; % [9:35]
c(1).s = [c(1).s, ratioFunc(c(1).s, fr)];
c(1).n = 2 * optParam.c1n; % [10:100]

c(2).s = optParam.c2s; % [6:20]
c(2).s = [c(2).s, ratioFunc(c(2).s, fr)];
c(2).n = optParam.c2n; % [20:150]

c(3).s = optParam.c3s; % [3:10]
c(3).s = [c(3).s, ratioFunc(c(3).s, fr)];
c(3).n = 2 * optParam.c3n; % [40:400]

c(4).s = optParam.c4s; % [3:10]
c(4).s = [c(4).s, ratioFunc(c(4).s, fr)];
c(4).n = optParam.c4n; % [30:200]

c(5).s = optParam.c5s; % [3:10]
c(5).s = [c(5).s, ratioFunc(c(5).s, fr)];
c(5).n = optParam.c5n; % [10:300]

c(6).s = optParam.c6s; % [3:10]
c(6).s = [c(6).s, ratioFunc(c(6).s, fr)];
c(6).n = optParam.c6n; % [5:150]

n(1) = optParam.n1;
n(2) = optParam.n2;
n(3) = optParam.n3;

%% Params
inputSize = [400 53 1]; % Constant
classWeights = [0.1 0.35 0.1 0.1 0.35];
% penaltyWeights = [0 0 0 .1 0];
penaltyWeights = [0.0001 0.0001 0.001 .1 0.0001];
lambda = .25;

conv(1).size = c(1).s;
conv(1).num = c(1).n;
conv(2).size = c(2).s;
conv(2).num = c(2).n;
conv(3).size = c(3).s;
conv(3).num = c(3).n;
conv(4).size = c(4).s;
conv(4).num = c(4).n;
conv(5).size = c(5).s;
conv(5).num = c(5).n;
conv(6).size = c(6).s;
conv(6).num = c(6).n;

NN(1) = n(1);
NN(2) = n(2);
NN(3) = n(3);
NN(4) = inParam.numLabels; % Constant

% numConv = length(conv);
% numNN = length(NN);
%% Blocks
% Input
inputBlock = [imageInputLayer(inputSize, "Name","imageinput", ...
    'Normalization', 'none')
    decomposerLayer("decom")];
% Convolution Blocks
convBlock{1} = [
    convolution2dLayer(conv(1).size, conv(1).num,"Name","conv1","BiasInitializer", ...
    "ones","BiasLearnRateFactor",2,"Stride",[4 4],"WeightsInitializer","narrow-normal")
    reluLayer("Name","convRelu1")
    crossChannelNormalizationLayer(5,"Name","norm1","K",1)
    maxPooling2dLayer([3 3],"Name","pool1","Stride",[2 2])];
convBlock{2} = [
    groupedConvolution2dLayer(conv(2).size, conv(2).num,2,"Name","conv2", ...
    "BiasInitializer","ones","BiasLearnRateFactor",2,"Padding",[2 2 2 2],"WeightsInitializer","narrow-normal")
    reluLayer("Name","convRelu2")
    crossChannelNormalizationLayer(5,"Name","norm2","K",1)
    maxPooling2dLayer([3 3],"Name","pool2","Stride",[2 2])];
convBlock{3} = [
    convolution2dLayer(conv(3).size, conv(3).num,"Name","conv3","BiasInitializer","ones", ...
    "BiasLearnRateFactor",2,"Padding",[1 1 1 1],"WeightsInitializer","narrow-normal")
    reluLayer("Name","convRelu3")];
if ~isnan(conv(4).size)
convBlock{4} = [
    groupedConvolution2dLayer(conv(4).size, conv(4).num,2,"Name","conv4","BiasInitializer", ...
    "ones","BiasLearnRateFactor",2,"Padding",[1 1 1 1],"WeightsInitializer","narrow-normal")
    reluLayer("Name","convRelu4")];
end
if ~isnan(conv(5).size)
convBlock{5} = [
    groupedConvolution2dLayer(conv(5).size, conv(5).num,2,"Name","conv5","BiasInitializer", ...
    "ones","BiasLearnRateFactor",2,"Padding",[1 1 1 1],"WeightsInitializer","narrow-normal")
    reluLayer("Name","convRelu5")
    maxPooling2dLayer([3 3],"Name","pool5","Stride",[2 2])];
end
if ~isnan(conv(6).size)
convBlock{6} = [
    groupedConvolution2dLayer(conv(6).size, conv(6).num,2,"Name","conv6","BiasInitializer", ...
    "ones","BiasLearnRateFactor",2,"Padding",[1 1 1 1],"WeightsInitializer","narrow-normal")
    reluLayer("Name","convRelu6")
    maxPooling2dLayer([3 3],"Name","pool6","Stride",[2 2])];
end
% NN
NNBlock{1} = [
    fullyConnectedLayer(NN(1),"Name","fc1","BiasLearnRateFactor",2,"WeightsInitializer","narrow-normal")
    reluLayer("Name","NNRelu1")
    dropoutLayer(0.5,"Name","drop1")];
if ~isnan(NN(2))
NNBlock{2} = [
    fullyConnectedLayer(NN(2),"Name","fc2","BiasLearnRateFactor",2,"WeightsInitializer","narrow-normal")
    reluLayer("Name","NNRelu2")
    dropoutLayer(0.5,"Name","drop2")];
end
if ~isnan(NN(3))
NNBlock{3} = [
    fullyConnectedLayer(NN(3),"Name","fc3","BiasLearnRateFactor",2,"WeightsInitializer","narrow-normal")
    reluLayer("Name","NNRelu3")
    dropoutLayer(0.5,"Name","drop3")];
end
NNBlock{4} = [
    fullyConnectedLayer(NN(4),"Name","fc4","BiasLearnRateFactor",2,"WeightsInitializer","narrow-normal")
    softmaxLayer("Name","prob")
%     focalLossLayer("Name","loss")
    classificationLayer("Name","loss")
%     weightedClassificationLayer(classWeights, penaltyWeights, lambda, "loss")...
    ];


%% CNN layers assemble
lgraph = layerGraph();
% lgraph = addLayers(lgraph, inputBlock);

convModule = [];
for i = 1:numConv
    convModule = [convModule; convBlock{i}];
end

beforeConcatModule = [inputBlock; convModule; NNBlock{1}];

lgraph = addLayers(lgraph,beforeConcatModule);

NNModule = concatenationLayer(3,2,"Name","concat");
for i = 1:numNN-2
    NNModule = [NNModule; NNBlock{i+1}];
end
NNModule = [NNModule; NNBlock{end}];

lgraph = addLayers(lgraph, NNModule);
lgraph = connectLayers(lgraph,"decom/feature","concat/in2");
lgraph = connectLayers(lgraph,"drop1/out","concat/in1");

% plot(lgraph);

switch optParam.options
    case categorical("a")
        % Training Options
        InitialLearnRate = 0.00005;
        solverName = 'adam';
        options = trainingOptions(solverName, ...
            'InitialLearnRate',InitialLearnRate, ...
            'LearnRateSchedule','piecewise', ...
            'Shuffle', 'once',...
            'MaxEpochs', inParam.maxEpochs, ...
            'LearnRateDropPeriod',1, ...
            'LearnRateDropFactor',0.005, ...
            'Verbose', verboseIsOn, ...
            'VerboseFrequency', 100*inParam.maxEpochs, ...
            'OutputFcn', @ml.trainingOutputFcn);
        
    case categorical("s")
        %Alex Net
        options = trainingOptions('sgdm', ...
            'InitialLearnRate', .01, ...
            'LearnRateSchedule', 'piecewise', ...
            'LearnRateDropFactor', .01, ...
            'LearnRateDropPeriod', 3, ...
            'MaxEpochs', inParam.maxEpochs, ...
            'MiniBatchSize', 128, ...
            'Shuffle', 'once',...
            'Momentum', .9, ...
            'L2Regularization', .0005, ...
            'Verbose',verboseIsOn, ...
            'VerboseFrequency', 100*inParam.maxEpochs, ...
            'OutputFcn', @ml.trainingOutputFcn);
end
% analyzeNetwork(lgraph)
end

%% Recycling zone
% % Training Options
% InitialLearnRate = 0.00005;
% solverName = 'adam';
% options = trainingOptions(solverName, ...
%     'InitialLearnRate',InitialLearnRate, ...
%     'Plots','training-progress', ...
%     'LearnRateSchedule','piecewise', ...
%     'Shuffle', 'once',...
%     'MaxEpochs', inParam.maxEpochs, ...
%     'LearnRateDropPeriod',1, ...
%     'LearnRateDropFactor',0.005, ...
%     'ValidationData', valImgs);
% 
% %Alex Net
% options = trainingOptions('sgdm', ...
%     'InitialLearnRate', .01, ...
%     'LearnRateSchedule', 'piecewise', ...
%     'LearnRateDropFactor', .01, ...
%     'LearnRateDropPeriod', 3, ...
%     'MaxEpochs', inParam.maxEpochs, ...
%     'MiniBatchSize', 128, ...
%     'Shuffle', 'once',...
%     'Momentum', .9, ...
%     'L2Regularization', .0005, ...
%     'Plots','training-progress', ...
%     'ValidationData', valImgs);