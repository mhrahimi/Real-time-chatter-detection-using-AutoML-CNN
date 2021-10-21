function loss = optimizeObjectiveFcn(optParam, dataset)
% EBChD
echdParam.EN_RATIO_LIMIT = optParam.enRatio;
echdParam.SigName = 'Spindle Current';
% TPE KALMAN
echdParam.n_tpe=20;
echdParam.lambda = optParam.lambda;

trainFun = @(data, prop) improvedEnergy.optimizeDriver(data, prop, echdParam);
eachLoss = dataset.transform(trainFun);
loss = sum([eachLoss{:}]);
disp(loss);
end