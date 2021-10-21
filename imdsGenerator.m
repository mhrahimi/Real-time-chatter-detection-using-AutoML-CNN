function [imds, dataset] = imdsGenerator(dsParam, spectogramParam, imdsParam)
if nargin == 1 && ~isfield(dsParam, 'trainNo') && isfield(dsParam, 'path')
    % imds already generated
    if isfield(dsParam, 'extension') % extention specified
        imds.training = imageDatastore(fullfile(dsParam.path, 'training'), ...
            'IncludeSubfolders',true,...
            'FileExtensions', dsParam.extension,'LabelSource','foldernames');
        imds.validation = imageDatastore(fullfile(dsParam.path, 'validation'), ...
            'IncludeSubfolders',true,...
            'FileExtensions', dsParam.extension,'LabelSource','foldernames');
        imds.test = imageDatastore(fullfile(dsParam.path, 'test'), ...
            'IncludeSubfolders',true,...
            'FileExtensions', dsParam.extension,'LabelSource','foldernames');
    else
        imds.training = imageDatastore(fullfile(dsParam.path, 'training'), ...
            'IncludeSubfolders',true, 'LabelSource','foldernames');
        imds.validation = imageDatastore(fullfile(dsParam.path, 'validation'), ...
            'IncludeSubfolders',true, 'LabelSource','foldernames');
        imds.test = imageDatastore(fullfile(dsParam.path, 'test'), ...
            'IncludeSubfolders',true, 'LabelSource','foldernames');
    end
elseif 1 <= nargin
    %% ds generation
    dataset.training = utilities.dsGen(dsParam, dsParam.trainNo);
    dataset.validation = utilities.dsGen(dsParam, dsParam.validNo);
    dataset.test = utilities.dsGen(dsParam, dsParam.testNo);
end
if nargin == 3
    %% training cases generation
    clc
    util.folderEmpty(imdsParam.path);
    
    imds.training = trainingCasesGen(dataset.training, ...
        spectogramParam, imdsParam, "training");
    imds.validation = trainingCasesGen(dataset.validation, ...
        spectogramParam, imdsParam, "validation");
    imds.test = trainingCasesGen(dataset.test, ...
        spectogramParam, imdsParam, "test");
end

end