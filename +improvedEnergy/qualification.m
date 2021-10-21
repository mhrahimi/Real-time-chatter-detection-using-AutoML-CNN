function [mx, mxInd, isRejected] = qualification(eligAmp, freq, harmonicsSP)
gpCount = 1;
mCount = 1;
len = length(eligAmp);

inelig = categorical("Ineligible");
elig = categorical("Eligible");

mx = [];
mxInd = [];
isRejected = [];

while mCount < len % Itrate through the FFT to group the continous points amp*[nan nan nan 1 1 1 1 1 1 nan nan 1 1 1 nan nan... -> amp*[1 1 1 1 1 1] , [1 1 1], ...
    while isnan(eligAmp(mCount)) && mCount < len
        mCount = mCount + 1;
    end
    st = mCount;
    while ~isnan(eligAmp(mCount)) && mCount < len
        mCount = mCount + 1;
    end
    en = mCount;
    if mCount < len
        harmonSmall = freq(st) <= harmonicsSP;
        harmonLarge = harmonicsSP <= freq(en);
        isRejected(gpCount) = any(and(harmonSmall, harmonLarge));
        
%         if ~isRejected(gpCount)
        [mx(gpCount), mxInd(gpCount)] = max(eligAmp(st:en));
        mxInd(gpCount) = st + mxInd(gpCount) - 1;
        gpCount = gpCount + 1;
%         end
    end
end
end