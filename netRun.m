function [trainedNet, trainingInfo] = netRun(trainDs, validationDS)
% cnnTrainingPipline Dpendency, run the CNN training process
%% setup
rng(123);
numLabels = length(unique(trainDs.Labels));

[layers, options] = nets.CNNfocalLoss(numLabels, validationDS);
[trainedNet, trainingInfo] = trainNetwork(trainDs, layers, options);
end