clear all
clc
close all
tic
%%
dataRootPath = "C:\Users\mhoss\Dropbox\Project MASc\DATA\Final";
batchProp = load("C:\Users\mhoss\Dropbox\Project MASc\DATA\Final\batchProp.mat");
batchProp = batchProp.batchProp;

folderNumber = 1; % don't change it
[data, detail] = tools.reader.lvmRead("C:\Users\mhoss\Dropbox\Project MASc\DATA\Final\1\1-7220_S_F_D_.lvm");
mic = data.Mic;
mic = mic(8300000:9200000);
prop = batchProp(folderNumber, :);

% EBChD
energybasedParam.EN_RATIO_LIMIT = 0.3;
energybasedParam.SigName = 'Spindle Current';
% TPE KALMAN
energybasedParam.n_tpe=20;
energybasedParam.lambda = 1e-6;
%%
output = echd.run(mic, prop, energybasedParam);
toc