function out = combinedDSReadFun(filePath)
% data = readmatrix(filePath, 'OutputType', 'uint8', 'Delimiter','\t,', ...
%     'LineEnding','\n', 'FileType', 'text');
data = readmatrix(filePath);
% data = csvread(filePath);

TPFsample = data(end, 1);
labelNum = data(end, 2);
switch labelNum
    case 1
        Label = "aircut";
    case 2
        Label = "entrance";
    case 3
        Label = "stable";
    case 4
        Label = "chatter";
    case 5
        Label = "exit";
end
Label = categorical(Label, {'aircut', 'entrance', 'stable', 'chatter', 'exit'});

out = [num2cell(TPFsample), {data(1:end-1,:,:)}, {Label}];
end