function thereshLine = threshold(amp, param)
windowSize = param.windowSize;
numSTD = param.numSTD;
len = length(amp);
fftDamped = (amp);

totalSTD = std(amp);
totalMean = mean(amp);
totalMedian = median(amp);

for i = 1:len
    st = max([1, i-windowSize]);
    ed = min([len, i+windowSize]);
    
    localSTD(i) = std(fftDamped(st:ed));
    localMean(i) = mean(fftDamped(st:ed));
    localMedian(i) = median(fftDamped(st:ed));
%     Z(i) = (amp(i) - localMean(i))/localSTD(i);
    
    thisThreshline(i) = totalMean+localMean(i) + numSTD*localSTD(i);
    if thisThreshline < amp(ed)
        damper = exp((amp(ed) - thisThreshline(i))+.5);
        
        fftDamped(ed) = fftDamped(ed) / damper;
    end
end
thereshLine = totalMean + localMean + numSTD*localSTD;

end