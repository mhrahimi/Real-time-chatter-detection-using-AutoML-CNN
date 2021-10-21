%%
close all
clear all
clc
%% Scenario Setup
rng(123)
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
dsParam.dsPath = "C:\Users\mhoss\Dropbox\Project MASc\Main\DS";

dsParam.grindingSize = 7000; 

imdsParam.tfFunction = @featureExtractor;
imdsParam.path = util.desktopDir("Hossein\imds");
imdsParam.extension = '.jpg';

%featureExtractor
spectogramParam.padding = false;
spectogramParam.func = "sfft";
spectogramParam.windowLength = 800; % 256;
spectogramParam.numOverlap = round(0.85 * spectogramParam.windowLength);
spectogramParam.fftLength = spectogramParam.windowLength;
%% ds generation
dataset.training = utilities.dsGen(dsParam, dsParam.trainNo);
dataset.validation = utilities.dsGen(dsParam, dsParam.validNo);
dataset.test = utilities.dsGen(dsParam, dsParam.testNo);

%% training cases generation
util.folderEmpty(imdsParam.path);
% structfun(@(ds) transform(ds, spectogramParam.transformationFunction), dataset);
imds.training = trainingCasesGen(dataset.training, spectogramParam, ...
    imdsParam, "training");
[TPFimds.training, labelsImds.training] = ...
    utilities.ToothPassingIMDSGen(imds.training, 'TPF');

imds.validation = trainingCasesGen(dataset.validation, spectogramParam, ...
    imdsParam, "validation");
[TPFimds.validation, labelsImds.validation] = ...
    utilities.ToothPassingIMDSGen(imds.validation, 'TPF');

imds.test = trainingCasesGen(dataset.test, spectogramParam, ...
    imdsParam, "test");
[TPFimds.test, labelsImds.test] = ...
    utilities.ToothPassingIMDSGen(imds.test, 'TPF');
%% Train
clc
imds.training = imageDatastore("C:\Users\mhoss\Desktop\Hossein\imds\training", 'IncludeSubfolders',true,...
    'FileExtensions', imdsParam.extension,'LabelSource','foldernames');
imds.validation = imageDatastore("C:\Users\mhoss\Desktop\Hossein\imds\validation", 'IncludeSubfolders',true,...
    'FileExtensions', imdsParam.extension,'LabelSource','foldernames');
imds.test = imageDatastore("C:\Users\mhoss\Desktop\Hossein\imds\test", 'IncludeSubfolders',true,...
    'FileExtensions', imdsParam.extension,'LabelSource','foldernames');

TPFimds.training = imageDatastore("C:\Users\mhoss\Desktop\Hossein\TPF\training", 'IncludeSubfolders',true,...
    'FileExtensions', '.png','LabelSource','foldernames');
TPFimds.validation = imageDatastore("C:\Users\mhoss\Desktop\Hossein\TPF\validation", 'IncludeSubfolders',true,...
    'FileExtensions', '.png','LabelSource','foldernames');
TPFimds.test = imageDatastore("C:\Users\mhoss\Desktop\Hossein\TPF\test", 'IncludeSubfolders',true,...
    'FileExtensions', '.png','LabelSource','foldernames');

labelsImds.training = tabularTextDatastore("C:\Users\mhoss\Desktop\Hossein\TPF\training\labels.csv", ...
    'FileExtensions', '.csv', 'TextType', 'char');
labelsImds.training.ReadVariableNames = 0;
labelsImds.training.ReadSize = 1;
labelsImds.training.SelectedFormats = {'%C'}; 
labelsImds.validation = tabularTextDatastore("C:\Users\mhoss\Desktop\Hossein\TPF\validation\labels.csv", ...
    'FileExtensions', '.csv', 'TextType', 'char');
labelsImds.validation.ReadVariableNames = 0;
labelsImds.validation.ReadSize = 1;
labelsImds.validation.SelectedFormats = {'%C'}; 
labelsImds.test = tabularTextDatastore("C:\Users\mhoss\Desktop\Hossein\TPF\test\labels.csv", ...
    'FileExtensions', '.csv', 'TextType', 'char');
labelsImds.test.ReadVariableNames = 0;
labelsImds.test.ReadSize = 1;
labelsImds.test.SelectedFormats = {'%C'}; 

combinedimds.training = combine(TPFimds.training, imds.training, labelsImds.training);
combinedimds.validation = combine(TPFimds.validation, imds.validation, labelsImds.validation);
combinedimds.test = combine(TPFimds.test, imds.test, labelsImds.test);

[trainedNet, netEval.trainingInfo] = ...
    netTweak(combinedimds.training, combinedimds.validation);
[netEval.training, netEval.test, netEval.validation] = ...
    networkEvaluation(trainedNet, combinedimds);
disp(netEval.test.performance.err);



%% imds gen
abcd
clear all
clc
close all
imdsParam.path = util.desktopDir("Hossein\imds");
imdsParam.extension = '.jpg';
netParam.splitPerc = [.7, .2];

imds.all = imageDatastore(imdsParam.path, 'IncludeSubfolders',true,...
    'FileExtensions', imdsParam.extension,'LabelSource','foldernames');
[imds.train, imds.val, imds.test] = splitEachLabel(imds.all,...
    netParam.splitPerc(1), netParam.splitPerc(2));
objFcnParam.numLabels = numel(unique(imds.all.Labels));
%% Optimization
clc
objFcnParam.batchPortion = .3;

optimVars = [
    optimizableVariable('convNum',[1,5],'Type','integer')
    optimizableVariable('nnNum',[1,3],'Type','integer')
    optimizableVariable('filtSz',[3,13],'Type','integer')
    optimizableVariable('numFilt',[1,100],'Type','integer','Transform','log')
    optimizableVariable('numFiltPGp',[1,180],'Type','integer','Transform','log')
    optimizableVariable('fc6',[3,4096],'Type','integer','Transform','log')
    optimizableVariable('fc7',[3,4096],'Type','integer','Transform','log')
    optimizableVariable('fc8',[3,4096],'Type','integer','Transform','log')
    ];
ObjFcn = @(x) neuroevo.neuroEvoObjFcn(objFcnParam, x, imds.train, imds.val);
BayesObject = bayesopt(ObjFcn,optimVars, ...
    'MaxTime',14*60*60, ...
    'PlotFcn',{@plotMinObjective,@plotConstraintModels},...
    'ConditionalVariableFcn',@neuroevo.condvariablefcn,...
    'IsObjectiveDeterministic',false);






