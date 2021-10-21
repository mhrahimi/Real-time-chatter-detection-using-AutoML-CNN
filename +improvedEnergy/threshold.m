function [thereshLine, damperThereshLine] = threshold(amp, param)
windowSize = param.windowSize;
% numSTD = param.numSTD;

% totalSTD = std(amp);
totalMean = mean(amp);
% totalMedian = median(amp);

b = (1/windowSize)*ones(1,windowSize);
a = 1;
localMean = filter(b,a,amp);

if mod(windowSize, 2) == 0 % stdfilt don't accept even numbers
    windowSize = windowSize + 1;
end
localSTD = stdfilt(amp, true(windowSize,1));

% damping
% damperThereshLine = totalMean + localMean + localSTD;
damperThereshLine = localMean + localSTD;
damperFactor = exp((1/max(amp)) *max(0, amp - damperThereshLine));

% final
dampedAmp = amp ./ damperFactor;
dampedLocalMean = filter(b,a,dampedAmp);
dampedLocalSTD = stdfilt(dampedAmp, true(windowSize,1));

% thereshLine = dampedLocalMean + numSTD*dampedLocalSTD;
thereshLine = totalMean + dampedLocalMean + dampedLocalSTD;
end