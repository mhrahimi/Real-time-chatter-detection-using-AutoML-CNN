function out = statistics(data, properties)
structOut = ml.descFeat(data);
out = struct2table(structOut);
out.label = categorical(properties.Label);
end