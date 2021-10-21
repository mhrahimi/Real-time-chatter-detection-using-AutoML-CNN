function [goodnessOfFit, usrdata] = informationCriteria(net, validation, numDataPoints, performance)
% T = numDataPoints;
Complexity = neuroevo.complexityCalc(net);
allLosses = activations(net, validation, 'loss'); % the value of the maximized loglikelihood objective function for a model
Loss = mean(min(squeeze(allLosses)));
netPerformance = ml.netAccuracy(net, validation);
Accuracy = netPerformance.accuracy;
% *Consistent AIC (CAIC)* — The CAIC imposes an additional penalty for
% complex models, as compared to the BIC. The CAIC for a given model is
% https://www.mathworks.com/help/econ/information-criteria.html
% goodnessOfFit = -2 * log(L) + k*(log(T) + 1);
% goodnessOfFit = -2 * log(Loss) + Complexity * (log(numDataPoints) + 1);



% goodnessOfFit = n * log(SSE/n) + (n + p) / (1 - (p + 2) / n);


% Corrected AIC (Hurvich and Tsai, 1989)
% AICc = n * log(SSE/n) + (n + p) / (1 - (p + 2) / n);
% AICc = n log 52 - n log o.2 + 2n(p + 1 )/(n - p - 2)
% AICu (McQuarrie and Shumway, 1996)
% AICu = n log(6. 2 ) - n log(a~) + 2n(p + 1 )/(n - p - 2).

% goodnessOfFit = numDataPoints * log((1/Accuracy)/numDataPoints) + ...
%     (numDataPoints + Complexity) / (1 - (Complexity + 2) / numDataPoints);
% lossOrAcc = Loss;
lossOrAcc = 1/Accuracy;
goodnessOfFit = numDataPoints * log(lossOrAcc/numDataPoints) + ...
    (numDataPoints + Complexity) / (1 - (Complexity + 2) / numDataPoints);

usrdata = netPerformance;
usrdata.Complexity = Complexity;
usrdata.loss = Loss;
usrdata.goodnessOfFit = goodnessOfFit;
end