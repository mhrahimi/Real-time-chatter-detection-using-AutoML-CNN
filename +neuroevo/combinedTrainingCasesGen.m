function [imds, outData] = combinedTrainingCasesGen...
    (dataset, spectogramParam, imdsParam, pathExt)
if nargin <= 3
    path = imdsParam.path;
else
    path = fullfile(imdsParam.path,pathExt);
end

transFunction = @(data, properties) imdsParam.tfFunction(data,... 
    properties, spectogramParam, path);

if 2 <= nargout
    outData = dataset.transform(transFunction);
else
    dataset.transform(transFunction);
end

imds = imageDatastore(path, 'IncludeSubfolders',true,...
    'FileExtensions', imdsParam.extension,'LabelSource','foldernames');
end