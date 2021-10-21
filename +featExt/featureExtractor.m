function [output] = featureExtractor(data, properties, param, savingPath)
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
    imgOut = round((imgOut - min(min(imgOut)))*(255/max(max(imgOut)))); % 8 bit normalization
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
%% saving
if nargin <= 3
    output = imgOut;
elseif ~isempty(imgOut)
    extention = '.png';
    subLabel = join(["g_",properties.SubNo,extention],'');
    imgName = DStools.dsNameGen(properties.No, properties.Source, properties.Label, subLabel);
    imgPath = fullfile(savingPath, properties.Label{1});
    if exist(imgPath) ~= 7
        mkdir(imgPath)
    end
    fileFullPath = fullfile(imgPath, imgName);
    
    output = size(imgOut);
    imwrite(imgOut, fileFullPath,'BitDepth',16);
end
end