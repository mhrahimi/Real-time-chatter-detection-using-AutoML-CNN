function [layers, options] = CNNfocalLoss(numLabels, valImgs)
%% CNN modification
net = alexnet;
layers = net.Layers;

% % withe initialization THE CORRECT ONE
layers(14) = groupedConvolution2dLayer([3 3],128,2,...
    "Name","conv5","BiasLearnRateFactor",2,"Padding",[1 1 1 1], ...
    "WeightsInitializer" , @(x) utilities.WBinit(net.Layers(14, 1).Weights, x), ...
    "BiasInitializer" , @(x) utilities.WBinit(net.Layers(14, 1).Bias, x));
layers(end-8) = fullyConnectedLayer(4096, ...
    "WeightsInitializer" , @(x) utilities.WBinit(net.Layers(17, 1).Weights, x), ...
    "BiasInitializer" , @(x) utilities.WBinit(net.Layers(17, 1).Bias, x));
layers(end-5) = fullyConnectedLayer(4096, ...
    "WeightsInitializer" , @(x) utilities.WBinit(net.Layers(20, 1).Weights, x), ...
    "BiasInitializer" , @(x) utilities.WBinit(net.Layers(20, 1).Bias, x));
layers(end-2) = fullyConnectedLayer(numLabels);
layers(end) = focalLossLayer;

% layers(14) = groupedConvolution2dLayer([3 3],128,2,...
%     "Name","conv5","BiasLearnRateFactor",2,"Padding",[1 1 1 1]);
% layers(end-8) = fullyConnectedLayer(4096);
% layers(end-5) = fullyConnectedLayer(4096);
% layers(end-2) = fullyConnectedLayer(numLabels);
% layers(end) = focalLossLayer;

%% Training Options
InitialLearnRate = 0.0003;
learnRateDropFactor = 0.01; % 0.01;
% InitialLearnRate = 0.000064;
% learnRateDropFactor = 0.005;
solverName = 'adam';
maxEpochs = 30;
MiniBatchSize = 128;

options = trainingOptions(solverName, ...
    'InitialLearnRate',InitialLearnRate, ...
    'Plots','training-progress', ...
    'LearnRateSchedule','piecewise', ...
    'Shuffle', 'once',...
    'MaxEpochs', 15, ...
    'LearnRateDropPeriod',1, ...
    'LearnRateDropFactor',learnRateDropFactor, ...
    'MiniBatchSize', MiniBatchSize, ...
    'MaxEpochs', maxEpochs, ...
    'ValidationData', valImgs);

%Alex Net
% options = trainingOptions('sgdm', ...
%     'InitialLearnRate', .01, ...
%     'LearnRateSchedule', 'piecewise', ...
%     'LearnRateDropFactor', .01, ...
%     'LearnRateDropPeriod', 3, ...
%     'MaxEpochs', 15, ...
%     'MiniBatchSize', 128, ...
%     'Shuffle', 'once',...
%     'Momentum', .9, ...
%     'L2Regularization', .0005, ...
%     'Plots','training-progress', ...
%     'ValidationData', valImgs);

% % adam
% InitialLearnRate = 0.0001;
% solverName = 'adam';
% options = trainingOptions(solverName, ...
%     'InitialLearnRate',InitialLearnRate, ...
%     'Plots','training-progress', ...
%     'LearnRateSchedule','piecewise', ...
%     'Shuffle', 'once',...
%     'MaxEpochs', 15, ...
%     'LearnRateDropPeriod',3, ...
%     'LearnRateDropFactor',0.0001, ...
%     'ValidationData', valImgs);

% stochastic gradient descent with momentum
% InitialLearnRate = 0.00000005;
% solverName = 'sgdm';
% options = trainingOptions(solverName, ...
%     'InitialLearnRate',InitialLearnRate, ...
%     'Plots','training-progress', ...
%     'LearnRateSchedule','piecewise', ...
%     'Shuffle', 'once',...
%     'LearnRateDropPeriod',3, ...
%     'MaxEpochs', 15, ...
%     'LearnRateDropFactor',0.0001, ...
%     'ValidationData', valImgs);
end