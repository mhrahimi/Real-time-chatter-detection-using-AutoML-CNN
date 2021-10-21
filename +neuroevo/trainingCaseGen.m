imds.training = imageDatastore("C:\Users\mhoss\Desktop\Hossein\imds\training", 'IncludeSubfolders',true,...
    'FileExtensions', imdsParam.extension,'LabelSource','foldernames');
imds.validation = imageDatastore("C:\Users\mhoss\Desktop\Hossein\imds\validation", 'IncludeSubfolders',true,...
    'FileExtensions', imdsParam.extension,'LabelSource','foldernames');
imds.test = imageDatastore("C:\Users\mhoss\Desktop\Hossein\imds\test", 'IncludeSubfolders',true,...
    'FileExtensions', imdsParam.extension,'LabelSource','foldernames');

imdsIn = imds.training;
%% Images
images = readall(imdsIn);

%% TPF
files = imdsIn.Files;

[N, ~, L] = DStools.dsNameExtract(files);

propertiesPath = "C:\Users\mhoss\Dropbox\Project MASc\Main\DS\properties.mat";
load(propertiesPath);

sampling = properties.sampling(N);
S = properties.S(N);
numFlutes = properties.numFlutes(N);

TPF = (S/60) .* numFlutes;
TPFsample = round(sampling ./ TPF);
features = num2cell(TPFsample);

%% Labels
Labels = imdsIn.Labels;
labelsCells = arrayfun(@(x)x,Labels,'UniformOutput',false);

%% combination
netIn = [features, images, labelsCells];

%% 
clc

datastorePath = 'C:\Users\mhoss\Desktop\Hossein\combined\training';
for i = 1:length(netIn)
    thisFileSections = strsplit(imdsIn.Files{i}, filesep);
    thisFileSections = strsplit(thisFileSections{end}, '.');
    thisName = thisFileSections{1};
    thisName = fullfile(datastorePath,thisName);
    inctance = netIn(i,:);
    save(thisName, 'inctance');
end

%% saving
% save(datastorePath,'netIn');
% filedatastore = fileDatastore(datastorePath,'ReadFcn',@load);
% trainingDatastore = transform(filedatastore,@rearrangeData);
% trainingDatastore = transform(filedatastore);
fds = fileDatastore(datastorePath,'ReadFcn',@load,'FileExtensions','.mat');

%% function to be used to transform the filedatastore 
%to ensure the read(datastore) returns M-by-3 cell array ie., (numInputs+1) columns
function out = rearrangeData(ds)
out = ds.netIn;
end