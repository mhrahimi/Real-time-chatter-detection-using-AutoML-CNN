function output = spectogramGen(data, properties, param, savingPath)
output = [];
%% Variables initialization
Fs = properties.sampling;
windowSize = param.windowLength;
overlap = param.numOverlap;
nfft = param.nfft;
%% extraction
[~,~,~,imgOut] = spectrogram(data, windowSize, overlap, nfft, Fs);
imgOut = utilities.spectogramOutlierSmoother(imgOut);
imgOut = 1./imgOut';
imgOut = db(imgOut); % db
% imgOut = db2mag(imgOut');
% imgOut = db(db(imgOut')); % db
% imgOut = log1p(imgOut);
if ~isempty(imgOut)
    imgOut = normalize(imgOut,'range'); % normalization
end
% figure;surf(imgOut);
if isfield(param,"size") % resizing
    if isfield(param,"resizeMethod")
        method = param.resizeMethod;
    else
        method = 'bicubic';
    end
    imgOut = imresize(imgOut, param.size, method);
end

%% padding
imgOut = util.imagePadder(imgOut, 2);

%% saving
if nargin <= 3
    output = imgOut;
elseif ~isempty(imgOut)
    extention = '.jpg';
    subLabel = join(["g_",properties.SubNo,extention],'');
    imgName = DStools.dsNameGen(properties.No, properties.Source, properties.Label, subLabel);
    imgPath = fullfile(savingPath, properties.Label{1});
    if exist(imgPath) ~= 7
        mkdir(imgPath)
    end
    fileFullPath = fullfile(imgPath, imgName);
    
    output = size(imgOut);
    imwrite(imgOut, fileFullPath);
end
end