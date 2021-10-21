function [training, test, validation] = networkEvaluation(trainedNet, subDS, graphingIsOn)
% Dependency 
%% Assessments
if nargin <= 2
    graphingIsOn = true;
end
%%
if 1 <= nargout
    [training.performance, training.Confusion, training.classes] =  aq1(trainedNet, subDS.training);
    if 2 <= nargout
        [test.performance, test.Confusion, test.classes] = ml.netAssess(trainedNet, subDS.test);
        if 3 <= nargout
            [validation.performance, validation.Confusion, validation.classes] = ml.netAssess(trainedNet, subDS.validation);
        end
    end
end

if graphingIsOn
    figure;
    [cmap,clabel] = confusionmat(test.classes.true, test.classes.pred);
    heatmap(clabel,clabel,cmap)
    title('Confusion Matrix');
    xlabel('Predicted Class');
    ylabel('True Class');
end
end