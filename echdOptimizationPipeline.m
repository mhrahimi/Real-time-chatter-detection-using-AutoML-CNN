%%
close all
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
dsParam.smallTrainNo = dsParam.trainNo(2:25:end);

dsParam.label = ["chatter", "stable", "aircut", "entrance", "exit"];
dsParam.source =  ["Mic"];
dsParam.extention = ".csv";
dsParam.dsPath = "C:\Users\mhoss\Dropbox\Project MASc\Main\DS";

% dsParam.grindingSize = 7000; % 8000



%energybased vars
% energyFunction = @(data, prop) echd.driver(data, prop, echdParam);
dataset.training = utilities.dsGen(dsParam, dsParam.smallTrainNo, 0);
% %% ds generation
% dataset.training = utilities.dsGen(dsParam, dsParam.trainNo, 0);
% dataset.validation = utilities.dsGen(dsParam, dsParam.validNo, 0);
% dataset.test = utilities.dsGen(dsParam, dsParam.testNo, 0);

%%
clc

optimVars = [
    optimizableVariable('enRatio',[.1, .9],'Type','real') % .3
    optimizableVariable('lambda',[1e-8, 1e-3],'Type','real')]; % 1e-6

ObjFcn = @(optParam) improvedEnergy.optimizeObjectiveFcn...
    (optParam, dataset.training);

InitialX = cell2table({.3, 1e-6});
InitialX.Properties.VariableNames = {'enRatio','lambda'};
 
% optimization 
optimizationResults = bayesopt(ObjFcn, optimVars, ...
    'AcquisitionFunctionName','probability-of-improvement', ...
    'IsObjectiveDeterministic', false, ...
    'MaxTime',2.5*60*60, ... % time in seconds
    'UseParallel', true, ...
    'MaxObjectiveEvaluations', 1000, ...
    'PlotFcn','all',...
    'InitialX', InitialX);













