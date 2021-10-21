function [output, filePath, imgOut] = frequencyDomainConversion(data, properties, spectogramParam)
output = [];
%% Variables initialization
Fs = properties.sampling;
windowSize = spectogramParam.windowLength;
overlap = spectogramParam.numOverlap;
%% filter
% data = filter(utilities.highPassFilt, data);
%% extraction
fftLength = spectogramParam.fftLength;
imgOut = stft(data,Fs,'Window',hann(windowSize,"periodic"),...
    'OverlapLength',overlap,'FFTLength',fftLength);
imgOut = db(abs(imgOut)); % db
imgOut = imgOut(1:end/2, :); % the second half is redundant

if ~isempty(imgOut)
    imgOut = imgOut - min(min(imgOut)); % shift to all positive
    imgOut = round((imgOut * (2^16-1)) / max(max(imgOut))); % normalize to 0-(2^16-1)
    imgOut = uint16(imgOut);
end

if isfield(spectogramParam,"size") % resizing
    if isfield(spectogramParam,"resizeMethod")
        method = spectogramParam.resizeMethod;
    else
        method = 'bicubic';
    end
    imgOut = imresize(imgOut, spectogramParam.size, method);
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
end
%% Combine
imgOut(1, end+1) = TPFsample;
imgOut(2, end) = TPF;
imgOut(3, end) = S;
imgOut(4, end) = numFlutes;

%% saving
output = imgOut;
extention = '.jpg';

if 2 <= nargout
filePath = ['.tempSTFT', extention];

imwrite(imgOut, filePath, 'BitDepth', 16, 'Mode', 'lossless');
end
if 3 <= nargout
    imgOut = imread(filePath);
end
end