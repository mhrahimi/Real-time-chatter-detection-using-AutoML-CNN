clear all
clc
close all

%% vars
path = "C:\Users\mhoss\Desktop\Hossein\enetgyBased_mal";
dataFolder = fullfile(path, 'validation');
totalData = 0;
numCorr = 0;

%%
fds = fileDatastore(dataFolder,'ReadFcn',@(x) improvedEnergy.readFcn(x, 'detected'));
while(fds.hasdata)
    [output, info] = fds.read;
    output = logical(output);
    [~, ~, label, ~] = ...
        DStools.dsNameExtract(convertCharsToStrings(info.Filename));
    label = categorical(label);
    if label == categorical({'chatter'})
        isChatter = true;
    else
        isChatter = false;
    end
    correct = output == isChatter;
    numCorr = numCorr + sum(~correct);
    totalData = totalData + length(correct);
end

disp(numCorr/totalData)

