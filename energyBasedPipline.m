%%
% close all
clear all
clc
%% Scenario Setup
dsParam.testNo= [1:10:32, 33:10:77, 78:10:117, 118:10:158, 159:10:199, ...
    200, 206, 212:10:239, 240:10:282, 283:10:331, 332:10:373, 374:10:393, ...
    394:10:414, 415, 418:10:435, 436:10:459, 460, 465, 471];
dsParam.validNo = [2:10:32, 34:10:77, 79:10:117, 119:10:158, 160:10:199, ...
    201, 207, 213:10:239, 241:10:282, 284:10:331, 333:10:373, 375:10:393, ...
    395:10:414, 416, 419:10:435, 437:10:459, 461, 466, 467, 472];
dsParam.trainNo = find(~ismember([1:473], [dsParam.validNo, dsParam.testNo]));

dsParam.label = ["chatter", "stable", "aircut", "entrance", "exit"];
dsParam.source =  ["Mic"];
dsParam.extention = ".csv";
dsParam.dsPath = "C:\Users\mhoss\Dropbox\Project MASc\Main\DS";

% dsParam.grindingSize = 7000; % 8000

% EBChD
echdParam.EN_RATIO_LIMIT = 0.89701; % 0.3;
echdParam.SigName = 'Spindle Current';
% TPE KALMAN
echdParam.n_tpe=20;
echdParam.lambda = 0.00012499; % 1e-6;

%energybased vars
% energyFunction = @(data, prop) echd.driver(data, prop, echdParam);

%% ds generation
dataset.training = utilities.dsGen(dsParam, dsParam.trainNo, 0);
dataset.validation = utilities.dsGen(dsParam, dsParam.validNo, 0);
dataset.test = utilities.dsGen(dsParam, dsParam.testNo, 0);

%%
clc
% util.folderEmpty("C:\Users\mhoss\Desktop\Hossein\enetgyBased_optimized")
% util.folderGen("C:\Users\mhoss\Desktop\Hossein\enetgyBased_optimized", ...
%     {'training', 'test', 'validation'});
trainFun = @(data, prop) echd.driver(data, prop, echdParam, "test");
dataset.test.transform(trainFun);
% validationFun = @(data, prop) echd.driver(data, prop, echdParam, "validation");
% dataset.validation.transform(validationFun);
% testFun = @(data, prop) echd.driver(data, prop, echdParam, "test");
% dataset.test.transform(testFun);


