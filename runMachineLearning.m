close all
clc

param.padding = false;
param.func = "sfft";
param.windowLength = 800; % 256;
param.numOverlap = round(0.85 * param.windowLength);
param.fftLength = param.windowLength;

grindingSize = 7000;

properties.sampling = 50000;

dsParam.testNo= [1:10:32, 33:10:77, 78:10:117, 118:10:158, 159:10:199, ...
    200, 206, 212:10:239, 240:10:282, 283:10:331, 332:10:373, 374:10:393, ...
    394:10:414, 415, 418:10:435, 436:10:459, 460, 465, 471];
dsParam.label = ["chatter", "stable", "aircut", "entrance", "exit"];
dsParam.source =  ["Mic"];
dsParam.extention = ".csv";
dsParam.dsPath = "C:\Users\mhoss\Dropbox\Project MASc\Main\DS";

dataset = utilities.dsGen(dsParam, dsParam.testNo, 0);
dsLen = dataset.Len;
%%
f = waitbar(0,'Please wait...');

thisData = dataset.fetch(1);
thisLen = length(thisData);
output = ones(400,52,thisLen-grindingSize);
for i = 1:thisLen-grindingSize
    st = i;
    ed = i + grindingSize;
    thisSpecto = featExt.featureExtractor(thisData(st:ed), properties, param);
    thisSpecLen = size(thisSpecto);
    output(:, :, i) = thisSpecto;
    
    waitbar(i/thisLen-grindingSize,f,'Processing');
end
close(f)