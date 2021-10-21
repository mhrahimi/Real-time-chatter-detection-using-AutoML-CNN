function [layers, options] = tweakNet(numLabels, valDS, opt)
param.numClass = numLabels;

% deafualt values
% opt.convNum = 5;
% opt.nnNum = 3;
%
% opt.filtSz = 11;
% opt.numFilt = 96;
% opt.numFiltPGp = 128;
% opt.fc6 = 4096;
% opt.fc7 = 4096;
% opt.fc8 = 4096;
disp(opt)
param.in.size = [227, 227, 3];

param.conv1.filtSize = opt.filtSz * [1,1]; % [11, 11];
param.conv1.numFilt = opt.numFilt; % 96;
param.pool1.poolSize = [3, 3];

param.conv2.filtSize = floor(opt.filtSz*[1,1]/2); % [5, 5];
param.conv2.numFiltPGp = opt.numFiltPGp; % 128;
param.pool2.poolSize = [3, 3];

param.conv3.filtSize = floor((opt.filtSz+3)*[1,1]/4); % [3, 3];
param.conv3.numFilt = opt.numFilt*4; % 384;

param.conv4.filtSize = floor((opt.filtSz+2)*[1,1]/4); % [3, 3];
param.conv4.numFiltPGp = ceil(opt.numFiltPGp*1.5); % 192;

param.conv5.filtSize = floor((opt.filtSz+1)*[1,1]/4); % [3, 3];
param.conv5.numFiltPGp = opt.numFiltPGp; % 128;
param.pool5.poolSize = [3, 3];

param.fc6.num = opt.fc6; % 4096;
param.fc7.num = opt.fc7; % 4096;
param.fc8.num = opt.fc8; % 4096;

param.out.numClass = 6;
try
    input = imageInputLayer(param.in.size,"Name","data");
    conv{1} = [convolution2dLayer(param.conv1.filtSize,param.conv1.numFilt,"Name",...
        "conv1","BiasLearnRateFactor",2,"Stride",[4 4])
        reluLayer("Name","relu1")
        crossChannelNormalizationLayer(5,"Name","norm1","K",1)
        maxPooling2dLayer(param.pool1.poolSize,"Name","pool1","Stride",[2 2])];
    if 2 <= opt.convNum
        conv{2} = [groupedConvolution2dLayer(param.conv2.filtSize,param.conv2.numFiltPGp,2,"Name",...
            "conv2","BiasLearnRateFactor",2,"Padding",[2 2 2 2])
            reluLayer("Name","relu2")
            crossChannelNormalizationLayer(5,"Name","norm2","K",1)
            maxPooling2dLayer(param.pool2.poolSize,"Name","pool2","Stride",[2 2])];
    end
    if 3 <= opt.convNum
        conv{3} = [convolution2dLayer(param.conv3.filtSize,param.conv3.numFilt,"Name",...
            "conv3","BiasLearnRateFactor",2,"Padding",[1 1 1 1])
            reluLayer("Name","relu3")];
    end
    if 4 <= opt.convNum
        conv{4} = [groupedConvolution2dLayer(param.conv4.filtSize,param.conv4.numFiltPGp,2,"Name",...
            "conv4","BiasLearnRateFactor",2,"Padding",[1 1 1 1])
            reluLayer("Name","relu4")];
    end
    if 5 <= opt.convNum
        conv{5} = [groupedConvolution2dLayer(param.conv5.filtSize,param.conv5.numFiltPGp,2,"Name","conv5","BiasLearnRateFactor",2,"Padding",[1 1 1 1])
            reluLayer("Name","relu5")
            maxPooling2dLayer(param.pool5.poolSize,"Name","pool5","Stride",[2 2])];
    end
    NN{1} = [fullyConnectedLayer(param.fc6.num,"Name","fc6","BiasLearnRateFactor",2)
        reluLayer("Name","relu6")
        dropoutLayer(0.5,"Name","drop6")];
    if 2 <= opt.nnNum
        NN{2} = [fullyConnectedLayer(param.fc7.num,"Name","fc7","BiasLearnRateFactor",2)
            reluLayer("Name","relu7")
            dropoutLayer(0.5,"Name","drop7")];
    end
    if 3 <= opt.nnNum
        NN{3} = [fullyConnectedLayer(param.fc8.num,"Name","fc8","BiasLearnRateFactor",2)
            reluLayer("Name","relu8")
            dropoutLayer(0.5,"Name","drop8")];
    end
    output = [fullyConnectedLayer(param.numClass,"Name","fc9","BiasLearnRateFactor",2)
        softmaxLayer("Name","prob")
        classificationLayer("Name","output")];
    
    layers = input;
    for i = 1:opt.convNum
        layers = [layers; conv{i}];
    end
    for i = 1:opt.nnNum
        layers = [layers; NN{i}];
    end
    layers = [layers; output];
catch e
    disp(e);
    options = NaN;
    return
end
% analyzeNetwork(layers)
%% Training Options
InitialLearnRate = 0.000005;
solverName = 'adam';
options = trainingOptions(solverName, ...
    'InitialLearnRate',InitialLearnRate, ...
    'LearnRateSchedule','piecewise', ...
    'Shuffle', 'once',...
    'LearnRateDropPeriod',15, ...
    'Verbose',false, ...
    'ValidationData', valDS);

end
