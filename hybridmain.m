clear all
clc

load('hybridMatTestData.mat')
load('theHolyNet.mat')

%%
%featureExtractor
param.padding = false;
param.func = "sfft";
param.windowLength = 800; % 256;
param.numOverlap = round(0.85 * param.windowLength);
param.fftLength = param.windowLength;

spectoSize = 7000;
stepSize = 7000; % 1000;

% initialization
clear decesion
decesion.ML = []; decesion.prob = []; decesion.certainty = []; 
decesion.Pchatter = []; decesion.PnonChatter = []; 
decesion.chatterEn = []; decesion.periodic = []; decesion.ratio = []; 
decesion.trueLabel = [];
% decesion.predLabel = [];

loopC = 1;
%%
clc
tic
for i = 1:height(data) % each expriment
    thisData = data.rawData{i};
    thisProp = data.properties(i);
    thisLabel = data.label(i);
    thisRatio = (data.chatterEn{i}+1)./(data.chatterEn{i}+data.malPrEn{i}*100+1);
    
    batches = [1:stepSize:length(thisData) - spectoSize, ...
        length(thisData) - spectoSize:-stepSize:1];
    for j =batches
        % ML
        thisThisSpecto = neuroevo.combinedFeatureExtractor...
    (thisData(j:j+spectoSize),thisProp,param);
        [thisPred, thisProb] = classify(trainedNet, thisThisSpecto);
        decesion.ML(loopC, 1) = thisPred;
        decesion.Pchatter(loopC, 1) = thisProb(2);
        decesion.PnonChatter(loopC, 1) = max(thisProb([1,3,4,5]));
        decesion.prob(loopC, 1) = max(thisProb);
        thisProb = sort(thisProb);
        thisCertainty = thisProb(end) - thisProb(end-1);
        thisProb = thisProb(end); % max prob
        decesion.certainty(loopC, 1) = thisCertainty;
        
        % improved energy
        thisThisRatio = thisRatio(j);
        decesion.chatterEn(loopC, 1) = data.chatterEn{i}(j);
        decesion.periodic(loopC, 1) = data.malPrEn{i}(j);
        decesion.ratio(loopC, 1) = thisThisRatio;
        
        % 
        decesion.trueLabel(loopC, 1) = thisLabel;
%         decesion.predLabel(loopC, 1)  = decesionMakingAlg ...
%             (thisPred, thisProb, thisCertainty, thisThisRatio);
        
        loopC = loopC + 1;
    end
end
decesion = struct2table(decesion);
toc
%%
clear alOut theTable
cats = categories(thisPred);
K = .3;
theTable = decesion;

theTable.ratio = theTable.chatterEn./...
    (theTable.periodic*100000+theTable.chatterEn+1);

th_c = .8; % certainty threshold
for i = 1:height(theTable)
    thisRow = theTable(i,:);
    P_C(i,1) = (thisRow.Pchatter+K*thisRow.ratio)/(1+K);
    P_S(i,1) = (thisRow.PnonChatter+K*(1-thisRow.ratio))/(1+K);
    if P_S(i,1) < P_C(i,1)
        alOut(i,1) = 2; % chatter
    else % non chatter
        alOut(i,1) = 5; % stable
        if th_c/10 < thisRow.certainty
            alOut(i,1) = thisRow.ML;
        end
    end
    
    if thisRow.ML == 1 || thisRow.ML == 3 || thisRow.ML == 4 % air, entrance, exit
        if th_c < thisRow.certainty
            alOut(i,1) = thisRow.ML;
        end
    end
end

sum(alOut==theTable.trueLabel)/height(theTable)
c = confusionmat(theTable.trueLabel,alOut);
%%
function out = confMatGen(data, preds)
confMat = zeros(5,2);

for i = 1:height(data)
    thisLabIdx = grp2idx(data.trueLabel(i));
    thisData = preds(i); % thisData = data.(obj){i};
    thisChatterCount = 0;
    thisStableCount = 0;
    thisChatterCount = thisChatterCount + sum(thisData);
    thisStableCount = thisStableCount + sum(~thisData);
    confMat(thisLabIdx, 1) = confMat(thisLabIdx, 1) + thisChatterCount; % chatter
    confMat(thisLabIdx, 2) = confMat(thisLabIdx, 2) + thisStableCount; % stable
end
correct = confMat(2,1) +  sum(confMat(1,2)) +  sum(confMat(3:5,2));
wrong = confMat(1,1)+sum(confMat(3:5,1))+confMat(2,2);
acc = correct/(correct+wrong);

out.conf = confMat;
out.correct = correct;
out.wrong = wrong;
out.acc = acc;
end