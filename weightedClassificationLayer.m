classdef weightedClassificationLayer < nnet.layer.ClassificationLayer
    
    properties
        % Row vector of weights corresponding to the classes in the
        % training data.
        ClassWeights
    end
    
    methods
        function layer = weightedClassificationLayer(classWeights, name)
            % Set class weights.
            layer.ClassWeights = classWeights;
            
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
            
            N = size(Y,4);
            Y = squeeze(Y); % predictions
            T = squeeze(T); % targets
            W = layer.ClassWeights;
    
%             loss = -sum(W*(T.*log(Y)))/N; % original
            loss = -sum(W*(T.*log(Y)))/N; % really working one
        end
    end
end

