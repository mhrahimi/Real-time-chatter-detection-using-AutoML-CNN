%%
clc
clear all

setOfData = 'test';

imp.path = "C:\Users\mhoss\Desktop\Hossein\enetgyBased_improved\";
mal.path = "C:\Users\mhoss\Desktop\Hossein\enetgyBased_mal";
opt.path = "C:\Users\mhoss\Desktop\Hossein\enetgyBased_optimized";

imp.fldr = fullfile(imp.path, setOfData);
mal.fldr = fullfile(mal.path, setOfData);
opt.fldr = fullfile(opt.path, setOfData);

fds.chatterEn = fileDatastore(imp.fldr,'ReadFcn', ...
    @(x) improvedEnergy.readFcn(x, 'chatterEnergy')); %
fds.malOut = fileDatastore(mal.fldr,'ReadFcn', ...
    @(x) improvedEnergy.readFcn(x, 'detected'));
fds.malprEN = fileDatastore(mal.fldr,'ReadFcn', ...
    @(x) improvedEnergy.readFcn(x, 'priodicEn'));%
fds.optOut = fileDatastore(opt.fldr,'ReadFcn', ...
    @(x) improvedEnergy.readFcn2(x, 'detected'));
fds.optEN = fileDatastore(opt.fldr,'ReadFcn', ...
    @(x) improvedEnergy.readFcn2(x, 'priodicEn')); %

chatterEn = fds.chatterEn.readall;
malOut = fds.malOut.readall;
malPrEn = fds.malprEN.readall;
optOut = fds.optOut.readall;
optPrEn = fds.optEN.readall;

[~, ~, label, ~] = DStools.dsNameExtract(convertCharsToStrings(fds.malOut.Files));
label = label';
cats = {'aircut', 'chatter', 'entrance', 'exit', 'stable'};
label = categorical(label, cats);

data = table(chatterEn, malOut, malPrEn, optOut, optPrEn, label);
[len, varCount] = size(data);
clear chatterEn malOut malPrEn impOut impPrEn

% analysis
anal.chatterEn.sum = sum(cellfun(@sum, data.chatterEn));
anal.chatterEn.allLen = sum(cellfun(@length, data.chatterEn));
anal.chatterEn.avg = anal.chatterEn.sum / anal.chatterEn.allLen;

anal.malPrEn.sum = sum(cellfun(@sum, data.malPrEn));
anal.malPrEn.allLen = sum(cellfun(@length, data.malPrEn));
anal.malPrEn.avg = anal.malPrEn.sum / anal.chatterEn.allLen;
%%
files = fds.chatterEn.Files;
DSRoot = "C:\energy\DS";

for i = 1:length(files)
    thisFile = files{i};
    thisFile = split(thisFile, filesep);
    thisFile = split(thisFile{end}, '.');
    thisFile = thisFile{1};
    
    thisPath = fullfile(DSRoot, thisFile);
    rawData{i} = readmatrix(thisPath);
end

%%
clc
loopCount = 1;
results = zeros(1e4,2);
figure

for threshold =0.001:.01:1
    numCorr = 0;
    totalData = 0;
    for j = 1:len
%         ratio = data.chatterEn{j}./(data.chatterEn{j}+data.malPrEn{j}*200);
        ratio = (data.chatterEn{j}+1)./(data.chatterEn{j}+data.malPrEn{j}*100+1);
        detectedIsChatter = threshold <= ratio;
%         detectedIsChatter = threshold <= data.chatterEn{j};
        if data.label(j) == categorical({'chatter'})
            isChatter = true;
        else
            isChatter = false;
        end
        correct = detectedIsChatter == isChatter;
        numCorr = numCorr + sum(~correct);
        totalData = totalData + length(correct);
    end
    
    results(loopCount,:) = [threshold (numCorr/totalData)];
    scatter(results(:,1),results(:,2));
    if ~mod(loopCount,10)
        drawnow
    end
    loopCount = loopCount + 1;
end

for iLen = 1:len
end

















