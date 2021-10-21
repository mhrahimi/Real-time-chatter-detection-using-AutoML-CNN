function loss = energyBasedObjectiveFunction(ds, param, k)
if nargin == 3 % No folds
    indicies = randperm(ds.Len, k)%;
else
    indicies = 1:ds.Len;
end
% global corrDetArrMat
corrDetArr = cell(numel(indicies), 1);
for counter = 1:numel(indicies)
    idx = indicies(counter);
    % signal and its properties
    signal = ds.fetch(idx);
    realLabelName = ds.Label(idx);
    % energy-based
    EChDOut = mal.echd.energybased(signal, ds.propertiesFetch(idx), param);
    % result comparison
    if strcmp(realLabelName, 'chatter')
        realLabelCode = 1;
    else
        realLabelCode = 0;
    end
    thisCorrDet = EChDOut{1} == realLabelCode;
    thisCorrDet = (thisCorrDet*2) - 1; % Normalizae to -1 and 1
    corrDetArr{counter} = thisCorrDet;
    % Loss calculation
%     rightRatio = sum(corrDet) / numel(signal);
%     sumRightRatio = sumRightRatio + rightRatio;
    
    disp((counter-1)/numel(indicies)); %del
end
% avgRightRatio = sumRightRatio / ds.Len;
% loss = 1 - avgRightRatio;

% loss = 1 - sumNumRightDet / sumLength;

corrDetArrMat = cell2mat(corrDetArr);
weight = 1;
exponentialLoss = weight * sum(exp(-corrDetArrMat));

loss = exponentialLoss;
end