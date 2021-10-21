function out = combinedDSReadFun(filePath)
persistent TPFsample
if isempty(TPFsample)
    propertiesPath = "C:\Users\mhoss\Dropbox\Project MASc\Main\DS\properties.mat";
    allProperties = load(propertiesPath);
    allProperties = allProperties.properties;
    
    sampling = allProperties.sampling;
    S = allProperties.S;
    numFlutes = allProperties.numFlutes;
    
    TPF = (S/60) .* numFlutes;
    TPFsample = round(sampling ./ TPF);
end

data = imread(filePath);

[N, ~, L] = DStools.dsNameExtract({filePath});



Label = categorical(L, {'aircut', 'entrance', 'stable', 'chatter', 'exit'});

out = [num2cell(TPFsample(N)), {data}, {Label}];
% out = [num2cell(TPFsample(N)), {data}];
end