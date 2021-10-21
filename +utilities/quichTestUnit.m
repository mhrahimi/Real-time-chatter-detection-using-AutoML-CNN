clear all
clc
close all

%% readData
dataAdd = "C:\Users\mhoss\Dropbox\Project MASc\Main\DS\N_1_S_AccelerationY_L_chatter_.csv";
signal = readmatrix(dataAdd);
%%
plot(signal);

%%
pic = featureExtractor(signal, 