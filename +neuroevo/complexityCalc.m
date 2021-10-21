function complexity = complexityCalc(net)
if isprop(net, 'Layers')
    layers = net.Layers;
else
    layers = net;
end

complexity = 0;

for i = 1:length(layers)
    thisType = class(layers(i));
    thisComplexity = 0;
    if strcmp(thisType, 'nnet.cnn.layer.Convolution2DLayer') || ...
            strcmp(thisType, 'nnet.cnn.layer.GroupedConvolution2DLayer') || ...
            strcmp(thisType, 'nnet.cnn.layer.FullyConnectedLayer')
        
            thisComplexity = numel(layers(i).Weights) + numel(layers(i).Bias);
            complexity = complexity + thisComplexity;
    end
end
end