function [all, durationS, durationSamples] = durationCalculator(data, properties)
[height, width] = size(data);
durationSamples = height*width;
durationS = durationSamples/properties.sampling;
% cells = {durationS, durationSamples, properties.Label};
all = [durationS, durationSamples, properties.Label];
end