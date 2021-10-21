function [imds, nargout] = trainingCasesGen(dataset, spectogramParam, imdsParam, pathExt)
if nargin <= 3
    path = imdsParam.path;
else
    path = fullfile(imdsParam.path,pathExt);
end

transFunction = @(data, properties) imdsParam.tfFunction(data,... 
    properties, spectogramParam, path);

dataset.transform(transFunction);

imds = imageDatastore(path, 'IncludeSubfolders',true,...
    'FileExtensions', imdsParam.extension,'LabelSource','foldernames');
end
% function out = dsReadFun(filePath)
% data = readmatrix(filePath);
% TPFsample = data(end, 1);
% labelNum = imgOut(end, 2);
% switch labelNum
%     case 1
%         Label = "aircut";
%     case 2
%         Label = "entrance";
%     case 3
%         Label = "stable";
%     case 4
%         Label = "chatter";
%     case 5
%         Label = "exit";
% end
% Label = categorical(Label);
% 
% out = [num2cell(TPFsample), {data}, {Label}];
% end