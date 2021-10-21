classdef weightedClassificationTwoDLayer < nnet.layer.ClassificationLayer
    
    properties
        % Row vector of weights corresponding to the classes in the
        % training data.
        ClassWeights
    end
    
    methods
        function layer = weightedClassificationTwoDLayer(classWeights, name)
            % Set class weights.
%             layer.ClassWeights = classWeights;
%             layer.ClassWeights = classWeights;


            layer.ClassWeights = classWeights/sum(sum(classWeights));
%             layer.ClassWeights = classWeights./sum(classWeights);
            
            % Set layer name.
            if nargin == 2
                layer.Name = name;
            end
            
            % Set layer description
            layer.Description = 'Weighted cross entropy for Machining';
        end
        
        function loss = forwardLoss(layer, Y, T)
            % loss = forwardLoss(layer, Y, T) returns the weighted cross
            % entropy loss between the predictions Y and the training
            % targets T.
                        
%             W = layer.ClassWeights / sum(sum(layer.ClassWeights));   % normalized weights
            W = layer.ClassWeights;   % normalized weights
            Y = squeeze(Y); % predictions
            T = squeeze(T); % targets
            N = size(Y,4);
            
%             loss = -sum((W*T).*Y)/N;
%             loss = -sum(sum((Y'*W).*T'))
%             loss = sum(sum((W'*T).*log(Y)));
            loss = -sum(sum(W'*(T.*log(Y)))); % WORKING
%             loss = -sum(sum(W*(T.*log(Y))))/N;
        end
    end
end

