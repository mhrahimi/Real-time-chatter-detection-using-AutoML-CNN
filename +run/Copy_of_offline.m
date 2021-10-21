function [out, eachLabel] = offline(data, properties, param)
dSize = param.grindingSize;
segments = [1:dSize:numel(data)-dSize];
% if segments(end) ~= numel(data)
%     segments = [segments, 
% out = categorical(4);
% figure(1);
% figure(2);
out = categorical("",{'aircut', 'entrance','stable','chatter','exit'});
for i = 1:numel(segments)-1
    thisData = data(segments(i):segments(i+1)-1);
    thisImOut = param.tfFunction(thisData, properties, param);
    eachLabel(i) = classify(param.net, thisImOut*255);
    out((i-1)*dSize+1:i*dSize) = eachLabel(i);
%     figure(1);
%     imshow(thisImOut);
%     figure(2);
%     plot(thisData);
%     ylim([-.1,.1]);
%     imshow(thisImOut);
end


end