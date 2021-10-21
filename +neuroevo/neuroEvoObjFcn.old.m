function [objLoss, constraint] = neuroEvoObjFcn(objFcnParam, optimVars,...
    trainDS, valDS)
constraint = 1;
[layers, options] = nets.tweakNet(objFcnParam.numLabels, valDS, optimVars);
if ~isa(options, 'nnet.cnn.TrainingOptionsADAM')
    constraint = -1;
    objLoss = NaN;
    return
end

trainingBatch = splitEachLabel(trainDS, objFcnParam.batchPortion);
try
[datatrainedNet, info] = trainNetwork(trainingBatch,layers,options);
catch e
    constraint = -1;
    objLoss = NaN;
    return
    disp(e)
end

objLoss = info.ValidationLoss(end)
end