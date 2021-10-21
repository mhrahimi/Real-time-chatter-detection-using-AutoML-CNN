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

imdsParam.tfFunction = @neuroevo.combinedFeatureExtractor;
imdsParam.path = util.desktopDir("Hossein\imds");
imdsParam.extension = '.jpg';

%featureExtractor
spectogramParam.padding = false;
spectogramParam.func = "sfft";
spectogramParam.windowLength = 800; % 256;
spectogramParam.numOverlap = round(0.85 * spectogramParam.windowLength);
spectogramParam.fftLength = spectogramParam.windowLength;
 %% IMDS
imds = imdsGenerator(imdsParam)
%% Optimization Variables
clc
close all
objFcnParam.batchPortion = .3;

optimVars = [
    optimizableVariable('numConv',[3, 6],'Type','integer')
    optimizableVariable('numNN',[2, 4],'Type','integer')
    optimizableVariable('fr',[1, 7],'Type','integer')
    optimizableVariable('c1s',[9 ,35 ],'Type','integer','Transform','none')
    optimizableVariable('c1n',[5,50],'Type','integer','Transform','none')
    
    optimizableVariable('c2s',[6 ,20 ],'Type','integer','Transform','none')
    optimizableVariable('c2n',[20,150],'Type','integer','Transform','none')
    
    optimizableVariable('c3s',[3 ,10 ],'Type','integer')
    optimizableVariable('c3n',[20,200],'Type','integer','Transform','none')
    
    optimizableVariable('c4s',[3 ,10 ],'Type','integer','Transform','none')
    optimizableVariable('c4n',[30,200],'Type','integer','Transform','none')
    
    optimizableVariable('c5s',[3 ,10 ],'Type','integer','Transform','none')
    optimizableVariable('c5n',[10,300],'Type','integer','Transform','none')
    
    optimizableVariable('c6s',[3 ,10 ],'Type','integer','Transform','none')
    optimizableVariable('c6n',[5 ,150],'Type','integer','Transform','none')
    
    optimizableVariable('n1',[50,4096],'Type','integer','Transform','none')
    optimizableVariable('n2',[50,4096],'Type','integer','Transform','none')
    optimizableVariable('n3',[50,4096],'Type','integer','Transform','none')
    
    optimizableVariable('options',{'a' 's'},'Type','categorical')
    ];
% objective function
ObjFcn = @(optParam) neuroevo.objectiveFunction(optParam, imds);

% initial value
InitialX = cell2table({6,4,7, ...
    20,96,8,128,5,384,5,192,5,128,5,100, ...
    2048,2048,2048,categorical({'a'})});
InitialX.Properties.VariableNames = {'numConv','numNN','fr', ...
    'c1s','c1n', 'c2s','c2n','c3s','c3n','c4s','c4n','c5s','c5n','c6s','c6n', ...
    'n1','n2','n3','options'};

% optimization 
optimizationResults = bayesopt(ObjFcn, optimVars, ...
    'AcquisitionFunctionName','expected-improvement-plus', ...
    'IsObjectiveDeterministic', false, ...
    'MaxTime',3.6*60*60, ... % time in seconds
    'ConditionalVariableFcn', @neuroevo.condVariableFcn, ...
    'NumCoupledConstraints', 1, ...
    'AreCoupledConstraintsDeterministic', false, ...
    'MaxObjectiveEvaluations', 1000, ...
    'PlotFcn','all',...
    'InitialX', InitialX, ...
    'OutputFcn', @ml.optOutputFcn);

% 'ExplorationRatio',0.2
% 'UseParallel' — Compute in parallel
save('optResults.mat', 'optimizationResults', '-append')


