%%
close all
clear all
clc
%% Scenario Setup
dsParam.validNo= [1:10:32, 33:10:77, 78:10:117, 118:10:158, 159:10:199, ...
    200, 206, 212:10:239, 240:10:282, 283:10:331, 332:10:373, 374:10:393, ...
    394:10:414, 415, 418:10:435, 436:10:459, 460, 465, 471];
dsParam.testNo = [2:10:32, 34:10:77, 79:10:117, 119:10:158, 160:10:199, ...
    201, 207, 213:10:239, 241:10:282, 284:10:331, 333:10:373, 375:10:393, ...
    395:10:414, 416, 419:10:435, 437:10:459, 461, 466, 467, 472];
dsParam.trainNo = find(~ismember([1:473], [dsParam.validNo, dsParam.testNo]));

dsParam.label = ["chatter", "stable", "aircut", "entrance", "exit"];
dsParam.source =  ["Mic"];
dsParam.extention = ".csv";
dsParam.dsPath = util.dirManipulator(pwd,"DS");

dsParam.grindingSize = 10000;

imdsParam.tfFunction = @featExt.statistics;

%% ds generation
dataset.training = utilities.dsGen(dsParam, dsParam.trainNo);
dataset.validation = utilities.dsGen(dsParam, dsParam.validNo);
dataset.test = utilities.dsGen(dsParam, dsParam.testNo);

%% training cases generation
clc
testData = dataset.test.transform(imdsParam.tfFunction);
testData = dataFormater(testData);
trainingData = dataset.training.transform(imdsParam.tfFunction);
trainingData = dataFormater(trainingData);

function tableOut = dataFormater(dataIn)
tableOut = table();

dataIn = dataIn(~cellfun('isempty',dataIn));
for i = 1:numel(dataIn)
    tableOut = [tableOut; dataIn{i}];
end
end


