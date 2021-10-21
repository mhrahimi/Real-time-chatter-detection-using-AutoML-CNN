% clear all
% close all
clc

% temp = load("C:\Users\mhoss\Dropbox\Project MASc\trainedNet\20200819\net.mat");
temp = load("C:\Users\mhoss\Dropbox\Project MASc\trainedNet\allLabels9452p-20200827.mat");
param.net = temp.trainedNet;
[data, detail] = tools.reader.fileHandler("C:\Users\mhoss\Dropbox\Project MASc\DATA\Final\*.lvm");

temp = load("C:\Users\mhoss\Dropbox\Project MASc\DATA\Final\batchProp.mat");
allProperties = temp.batchProp;
filePartsSep = strsplit(detail.file, filesep);
thisBatchNo = str2num(filePartsSep{end-1});
properties = allProperties(thisBatchNo, :);
points = load(fullfile(filePartsSep{1:end-1}, 'labels.mat'));
points = points.varToSave;
%%

param.grindingSize = 1e4;
param.tfFunction = @featureExtractor;
param.func = "sfft";
param.windowLength = 1000; % 1000; % 256;
param.numOverlap = round(0.8 * param.windowLength);
param.fftLength = param.windowLength;
param.size = [227, 227];

% figure(3);
% plot(data.Mic);

algorithmOut = run.offline(data.Mic, properties, param);
pointsTS = points2TS(points);

% plot(out)
% hold on
% plot(pointsTS);
% hold off

%%
L = categorical({'aircut', 'entrance','stable','chatter','exit', 'transient'});
Mic = data.Mic;

algorithmOutShort = algorithmOut(1:numel(pointsTS));
notEq = algorithmOutShort ~= pointsTS;
compare = notEq & (pointsTS ~= L(6));
plot(data.Mic);
hold on
plot(compare/3);
hold off

alStable = algorithmOutShort == categorical("stable");
alChatter = (algorithmOutShort == categorical("chatter"));
alAir = (algorithmOutShort == categorical("aircut"));
alEntEx = ((algorithmOutShort == categorical("entrance")...
    | algorithmOutShort == categorical("exit")));


pointsToImport = load(fullfile(filePartsSep{1:end-1}, 'labels.mat'));
pointsToImport = pointsToImport.varToSave;
disp(detail.file)




function pointsTS = points2TS(points)
pointsTS = categorical("",{'aircut', 'entrance','stable','chatter','exit'});
lastInd = 1;
for i = 1:height(points)
    thisPoint = round(points.Point(i));
    pointsTS(lastInd:thisPoint) = points.Label(i);
    lastInd = thisPoint;
end
end