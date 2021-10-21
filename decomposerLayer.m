classdef  decomposerLayer < nnet.layer.Layer
    % This Class is a NNet Layer
    % This class seprates its last layer's input and output its first
    % element as one output and the rest of the input as the first output.
    
    properties
        % Scaling coefficients.
    end
    
    methods
        function layer = decomposerLayer(name)
            % Set layer name.
            layer.Name = name;
            
            % Set layer description.
            layer.Description = "Layer seperates its input's last row";
            
            layer.NumInputs = 1;
            layer.InputNames = {'compositImage'};
            
            layer.NumOutputs = 2;
            layer.OutputNames = {'image', 'feature'};
            
        end
        
        function [image, feature] = predict(layer, input)
%             varargout{1} = input(:,1:end-1,:);
%             varargout{2} = input(1,end,:);

%             image = input(1:end-1, :, :);
%             feature = input(end, 1, :);

            image = input(:, 1:end-1, :, :);
            feature = input(1, end, :, :);
            
        end
    end
end