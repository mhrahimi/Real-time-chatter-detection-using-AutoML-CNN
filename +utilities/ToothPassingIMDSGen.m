function [imdsOut, labelsImds] = ToothPassingIMDSGen(imdsIn, nameIn)
nameIn = char(nameIn);
extention = '.png';

propertiesPath = "C:\Users\mhoss\Dropbox\Project MASc\Main\DS\properties.mat";
load(propertiesPath);

files = imdsIn.Files;
folder = imdsIn.Folders{1};
sepFolder = split(folder, filesep);
saveToPath = fullfile(sepFolder{1:end-2}, nameIn, sepFolder{end});

[N, ~, L] = DStools.dsNameExtract(files);

mkdir(saveToPath);
lUnique = unique(L);
for i = 1:length(lUnique)
    thisFolderAdd = fullfile(saveToPath, lUnique(i));
    mkdir(thisFolderAdd{1});
end

sampling = properties.sampling(N);
S = properties.S(N);
numFlutes = properties.numFlutes(N);
% diameter = properties.diameter(N);

TPF = (S/60) .* numFlutes;
TPFsample = round(sampling ./ TPF);

for i = 1:length(TPFsample)
    temp = split(files(i), filesep);
    thisFullName = temp{end};
    thisFullName = split(thisFullName, '.');
    thisName = thisFullName{1};
    thisPath = fullfile(saveToPath, L{i}, [thisName, extention]);
    
    thisTPFsample = uint16(TPFsample(i));
    imwrite(thisTPFsample, thisPath);
end

imdsOut = imageDatastore(saveToPath, 'IncludeSubfolders',true,...
    'FileExtensions', extention,'LabelSource','foldernames');

% labels
labelsDSPath = fullfile(saveToPath, 'labels.csv');
writematrix((imdsOut.Labels), labelsDSPath); % grp2idx
labelsImds = tabularTextDatastore(labelsDSPath, 'FileExtensions', '.csv');
end

% %%
% utilities.ToothPassingIMDSGen(imds.validation, 'TPF');
% utilities.ToothPassingIMDSGen(imds.test, 'TPF');
% utilities.ToothPassingIMDSGen(imds.training, 'TPF');