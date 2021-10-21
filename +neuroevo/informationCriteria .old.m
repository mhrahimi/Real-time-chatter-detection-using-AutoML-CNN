function [goodnessOfFit, usrdata] = informationCriteria(net, validation, numDataPoints)
% T = numDataPoints;
Complexity = neuroevo.complexityCalc(net);
allLosses = activations(net, validation, 'loss'); % the value of the maximized loglikelihood objective function for a model
Loss = mean(min(squeeze(allLosses)));
% *Consistent AIC (CAIC)* — The CAIC imposes an additional penalty for 
% complex models, as compared to the BIC. The CAIC for a given model is
% https://www.mathworks.com/help/econ/information-criteria.html
% goodnessOfFit = -2 * log(L) + k*(log(T) + 1);
% goodnessOfFit = -2 * log(Loss) + Complexity * (log(numDataPoints) + 1);



% goodnessOfFit = n * log(SSE/n) + (n + p) / (1 - (p + 2) / n);


% Corrected AIC (Hurvich and Tsai, 1989)
% AICc = n * log(SSE/n) + (n + p) / (1 - (p + 2) / n);
% AICc = n log 52 - n log o.2 + 2n(p + 1 )/(n - p - 2)
goodnessOfFit = numDataPoints * log(Loss/numDataPoints) + ...
    (numDataPoints + Complexity) / (1 - (Complexity + 2) / numDataPoints);
% AICu (McQuarrie and Shumway, 1996)
% AICu = n log(6. 2 ) - n log(a~) + 2n(p + 1 )/(n - p - 2).
usrdata.Complexity = Complexity;
usrdata.Loss = Loss;
usrdata.goodnessOfFit = goodnessOfFit;
end