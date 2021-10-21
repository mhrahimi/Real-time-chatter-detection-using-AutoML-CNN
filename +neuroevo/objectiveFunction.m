function [CAIC, coupledconstraints, userdata] = objectiveFunction...
    (optParam, combinedDS)
rng(123);

err = [];
userdata = [];
coupledconstraints = -1;
CAIC = -inf;

inParam.maxEpochs = 1; % 3;
inParam.numLabels = 5;

numTrainingInctances = length(combinedDS.training.Files);

try
    [layers, options] = nets.HosseinNetDecom(combinedDS.validation, inParam, optParam);
    userdata.layers = layers;
    [trainedNet, trainingInfo] = trainNetwork(combinedDS.training, layers, options);
    userdata.trainingInfo = trainingInfo;
catch err
    coupledconstraints = 1;
%     disp(err);
    userdata.err = err;
end
if exist('trainedNet')
    [CAIC, userdata] = neuroevo.informationCriteria...
        (trainedNet, combinedDS.validation, numTrainingInctances);
    [userdata.testAcc] = ml.netAccuracy(trainedNet, combinedDS.test);
    
    userdata.layers = layers;
    userdata.trainingInfo = trainingInfo;
end

% disp("___________________");
% disp(coupledconstraints);
% disp(optParam);
% [netEval.training, netEval.test, netEval.validation] = ...
%     networkEvaluation(trainedNet, netIn);
% disp(netEval.test.performance.err);
end