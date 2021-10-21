clear all
clc
close all

% vars
path = "C:\Users\mhoss\Desktop\Hossein\enetgyBased_improved";
dataFolder = fullfile(path, 'validation');
totalData = 0;
numCorr = 0;

%
fds = fileDatastore(dataFolder,'ReadFcn',@(x) improvedEnergy.readFcn(x, 'chatterEnergy'));
while(fds.hasdata)
    [output, info] = fds.read;
%     output = logical(output);
    detectedIsChatter = threshold <= output;
    [~, ~, label, ~] = ...
        DStools.dsNameExtract(convertCharsToStrings(info.Filename));
    label = categorical(label);
    if label == categorical({'chatter'})
        isChatter = true;
    else
        isChatter = false;
    end
    correct = detectedIsChatter == isChatter;
    numCorr = numCorr + sum(~correct);
    totalData = totalData + length(correct);
end

disp(numCorr/totalData)

