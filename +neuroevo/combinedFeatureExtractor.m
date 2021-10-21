function [output] = combinedFeatureExtractor(data, properties, param, savingPath)
output = [];
%% Variables initialization
Fs = properties.sampling;
windowSize = param.windowLength;
overlap = param.numOverlap;
%% filter
% data = filter(utilities.highPassFilt, data);
%% extraction
switch lower(param.func)
    case "spectogram"
        nfft = param.nfft;
        [~,~,~,imgOut] = spectrogram(data, windowSize, overlap, nfft, Fs);
        imgOut = db(abs(imgOut')); % db
    case "sfft"
        fftLength = param.fftLength;
        imgOut = stft(data,Fs,'Window',hann(windowSize,"periodic"),...
            'OverlapLength',overlap,'FFTLength',fftLength);
%         numFeatures = floor(windowSize/2 + 1);
%         imgOut = imgOut(numFeatures-1:end,:);
        imgOut = db(abs(imgOut)); % db
        imgOut = imgOut(1:end/2, :); % the second half is redundant
    case "pspectrum"
%         imgOut = pspectrum(data,Fs);
end
% imgOut = utilities.spectogramOutlierSmoother(imgOut);
% imgOut = db2mag(imgOut');
% imgOut = db(db(imgOut')); % db
% imgOut = log1p(imgOut);
if ~isempty(imgOut)
%     imgOut = normalize(imgOut,'range'); % normalization
%     imgOut = uint16(normalize(imgOut,'range') * (2^16-1)); % 16 bit normalization
    imgOut = imgOut - min(min(imgOut)); % shift to all positive
    imgOut = round((imgOut * (2^16-1)) / max(max(imgOut))); % normalize to 0-(2^16-1)
    imgOut = uint16(imgOut);
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
if isfield(param, 'padding') && ~param.padding % if not padding
    % do nothing
else
    imgOut = util.imagePadder(imgOut, 2); % 3d padding
end

%% TPF
sampling = properties.sampling;
S = properties.S;
numFlutes = properties.numFlutes;

TPF = (S/60) .* numFlutes;
TPFsample = round(sampling ./ TPF);
%% Label
if isfield(properties, 'Label')
    Label = string(properties.Label{1});
else
    Label = string(properties.label);
end
%% Combine
imgOut(1, end+1) = TPFsample;
imgOut(2, end) = TPF;
imgOut(3, end) = S;
imgOut(4, end) = numFlutes;
switch Label
    case "aircut"
        labelNum = 1;
    case "entrance"
        labelNum = 2;
    case "stable"
        labelNum = 3;
    case "chatter"
        labelNum = 4;
    case "exit"
        labelNum = 5;
end
imgOut(end, 5) = labelNum;

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
    imwrite(imgOut, fileFullPath, 'BitDepth', 16, 'Mode', 'lossless');
%     writematrix(imgOut, fileFullPath);
end
end