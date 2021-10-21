function out = optimizeDriver(data, properties, echdParam)
rawOut = echd.energybased(data, properties, echdParam);

% out.kalmanOut = rawOut.kalmanOut{1};
% out.ratio = rawOut.ratio{1};
detected = rawOut.detected{1};

if strcmp(properties.Label{1}, 'chatter')
    thisLabel = 1;
else
    thisLabel = 0;
end
missClassified = sum(detected ~= thisLabel);
out = missClassified + (missClassified .* detected*4);

end