clear all
clc
%%
param.conv1.filtSize = [11, 11];
param.conv1.numFilt = 96;
param.pool1.poolSize = [3, 3];

param.conv2.filtSize = [5, 5];
param.conv2.numFiltPGp = 128;
param.pool2.poolSize = [3, 3];

param.conv3.filtSize = [3, 3];
param.conv3.numFilt = 384;

param.conv4.filtSize = [3, 3];
param.conv4.numFiltPGp = 192;

param.conv5.filtSize = [3, 3];
param.conv5.numFiltPGp = 128;
param.pool5.poolSize = [3, 3];

param.fc6.num = 4096;
param.fc7.num = 4096;

input = imageInputLayer([227 227 3],"Name","data");
conv{1} = [convolution2dLayer(param.conv1.filtSize,param.conv1.numFilt,"Name",...
    "conv1","BiasLearnRateFactor",2,"Stride",[4 4])
    reluLayer("Name","relu1")
    crossChannelNormalizationLayer(5,"Name","norm1","K",1)
    maxPooling2dLayer(param.pool1.poolSize,"Name","pool1","Stride",[2 2])];
conv{2} = [groupedConvolution2dLayer(param.conv2.filtSize,param.conv2.numFiltPGp,2,"Name",...
    "conv2","BiasLearnRateFactor",2,"Padding",[2 2 2 2])
    reluLayer("Name","relu2")
    crossChannelNormalizationLayer(5,"Name","norm2","K",1)
    maxPooling2dLayer(param.pool2.poolSize,"Name","pool2","Stride",[2 2])];
conv{3} = [convolution2dLayer(param.conv3.filtSize,param.conv3.numFilt,"Name",...
    "conv3","BiasLearnRateFactor",2,"Padding",[1 1 1 1])
    reluLayer("Name","relu3")];
conv{4} = [groupedConvolution2dLayer(param.conv4.filtSize,param.conv4.numFiltPGp,2,"Name",...
    "conv4","BiasLearnRateFactor",2,"Padding",[1 1 1 1])
    reluLayer("Name","relu4")];
conv{5} = [groupedConvolution2dLayer(param.conv5.filtSize,param.conv5.numFiltPGp,2,"Name","conv5","BiasLearnRateFactor",2,"Padding",[1 1 1 1])
    reluLayer("Name","relu5")
    maxPooling2dLayer(param.pool5.poolSize,"Name","pool5","Stride",[2 2])];
NN{1} = [fullyConnectedLayer(param.fc6.num,"Name","fc6","BiasLearnRateFactor",2)
    reluLayer("Name","relu6")
    dropoutLayer(0.5,"Name","drop6")];
NN{2} = [fullyConnectedLayer(param.fc7.num,"Name","fc7","BiasLearnRateFactor",2)
    reluLayer("Name","relu7")
    dropoutLayer(0.5,"Name","drop7")];
output = [fullyConnectedLayer(1000,"Name","fc8","BiasLearnRateFactor",2)
    softmaxLayer("Name","prob")
    classificationLayer("Name","output")];

layers = [input
    conv{1}
    conv{2}
    conv{3}
    conv{4}
    conv{5}
    NN{1}
    NN{1}
    output]
    % input
    
    % Conv Blocks
    % 1

    % 2

    % 3

    % 4
    
    % 5
    
    % NN
    % 6
    
    % 7
    
    % output
    % 8
    





