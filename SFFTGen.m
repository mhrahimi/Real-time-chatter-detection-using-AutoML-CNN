function output = SFFTGen(data, properties, param, savingPath)
output = [];
%% Variables initialization
Fs = properties.sampling;
windowLength  = param.windowLength;
overlap = param.numOverlap;
ffTLength = param.fftLength;
%% extraction
imgOut = stft(data,'Window', hamming(windowLength,"periodic"), ... 
    'OverlapLength', overlap, 'FFTLength',ffTLength);

numFeatures = floor(windowLength/2 + 1);
imgOut = abs(imgOut(numFeatures-1:end,:));
imgOut = utilities.spectogramOutlierSmoother(imgOut);
% imgOut = 1./imgOut';
imgOut = db(imgOut); % db
% imgOut = db2mag(imgOut');
% imgOut = db(db(imgOut')); % db
% imgOut = log1p(imgOut);

% numFeatures = windowLength/2 + 1;
% imgOut = abs(imgOut(numFeatures-1:end,:));
% imgOut = utilities.spectogramOutlierSmoother(imgOut);
% imgOut = 1./imgOut';


if ~isempty(imgOut)
    imgOut = normalize(imgOut,'range'); % normalization
end
% figure;surf(imgOut);close all

if isfield(param,"size") % resizing
    if isfield(param,"resizeMethod")
        method = param.resizeMethod;
    else
        method = 'bicubic';
    end
    imgOut = imresize(imgOut, param.size, method);
end

%% padding
if isfield(param, 'padding')
    imgOut = util.imagePadder(imgOut, param.padding);
else
    imgOut = util.imagePadder(imgOut, 2);
end
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