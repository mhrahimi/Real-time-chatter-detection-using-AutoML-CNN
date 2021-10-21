%%
close all
clear all
% clc
%% Scenario Setup
dsParam.testNo= [1:10:32, 33:10:77, 78:10:117, 118:10:158, 159:10:199, ...
    200, 206, 212:10:239, 240:10:282, 283:10:331, 332:10:373, 374:10:393, ...
    394:10:414, 415, 418:10:435, 436:10:459, 460, 465, 471];
dsParam.validNo = [2:10:32, 34:10:77, 79:10:117, 119:10:158, 160:10:199, ...
    201, 207, 213:10:239, 241:10:282, 284:10:331, 333:10:373, 375:10:393, ...
    395:10:414, 416, 419:10:435, 437:10:459, 461, 466, 467, 472];
dsParam.trainNo = find(~ismember([1:473], [dsParam.validNo, dsParam.testNo]));

dsParam.label = ["chatter", "stable", "aircut", "entrance", "exit"];
% dsParam.label = ["chatter", "stable"];
dsParam.source =  ["Mic"];
dsParam.extention = ".csv";
% dsParam.dsPath = util.dirManipulator(pwd,"DS");
dsParam.dsPath = "C:\Users\mhoss\Dropbox\Project MASc\Main\DS";

% dsParam.grindingSize = 10000;
dsParam.grindingSize = 7000; % 8000
% dsParam.grindingSize = @(prop) round((prop.S*prop.sampling)/(60*prop.numFlutes));
% dsParam.grindingSize = @(prop) round((4*60*prop.numFlutes*prop.sampling)/(prop.S));

imdsParam.tfFunction = @featExt.featureExtractor;
imdsParam.path = util.desktopDir("Hossein\imds2");
imdsParam.extension = '.jpg';

%featureExtractor
spectogramParam.func = "sfft";
% spectogramParam.windowLength = 2000; % 1000; % 256;
spectogramParam.windowLength = 800; % 256;
spectogramParam.numOverlap = round(0.85 * spectogramParam.windowLength);
% spectogramParam.numOverlap = round(0.9 * spectogramParam.windowLength);
spectogramParam.fftLength = spectogramParam.windowLength;
spectogramParam.size = [227, 227];

energybasedParam.EN_RATIO_LIMIT = 0.3;
energybasedParam.SigName = 'Spindle Current';
% TPE KALMAN
energybasedParam.n_tpe=20;
energybasedParam.lambda = 1e-6;

%% ds generation
dataset.training = utilities.dsGen(dsParam, dsParam.trainNo);
dataset.validation = utilities.dsGen(dsParam, dsParam.validNo);
dataset.test = utilities.dsGen(dsParam, dsParam.testNo);

%% training cases generation
util.folderEmpty(imdsParam.path);
% structfun(@(ds) transform(ds, spectogramParam.transformationFunction), dataset);
imds.training = trainingCasesGen(dataset.training, spectogramParam, ...
    imdsParam, "training");
imds.validation = trainingCasesGen(dataset.validation, spectogramParam, ...
    imdsParam, "validation");
imds.test = trainingCasesGen(dataset.test, spectogramParam, ...
    imdsParam, "test");

% energy-based run
energybasedParam.tranformationFunction = ...
    @(data, properties) mal.echd.energybased(data, properties, energybasedParam);
% dataset.transform(energybasedParam.tranformationFunction);
%% Train
% pause(1800)
imds.training = imageDatastore("C:\Users\mhoss\Desktop\0 Final Nets\BaseNet\imds\training", 'IncludeSubfolders',true,...
    'FileExtensions', imdsParam.extension,'LabelSource','foldernames');
imds.validation = imageDatastore("C:\Users\mhoss\Desktop\0 Final Nets\BaseNet\imds\validation", 'IncludeSubfolders',true,...
    'FileExtensions', imdsParam.extension,'LabelSource','foldernames');
imds.test = imageDatastore("C:\Users\mhoss\Desktop\0 Final Nets\BaseNet\imds\test", 'IncludeSubfolders',true,...
    'FileExtensions', imdsParam.extension,'LabelSource','foldernames');


[trainedNet, netEval.trainingInfo] = netRun(imds.training, imds.validation);
[netEval.training, netEval.test, netEval.validation] = ...
    networkEvaluation(trainedNet, imds);
disp(netEval.test.performance.err);




