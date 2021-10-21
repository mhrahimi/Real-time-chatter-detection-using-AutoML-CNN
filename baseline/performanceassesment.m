clc

pred = trainedModel.predictFcn(valData);
compare = pred == valData.label;
correct = sum(compare);
all = length(compare);
correct/all
[conf,order] = confusionmat(pred,valData.label);


% view(trainedModel.ClassificationTree,'mode','graph')