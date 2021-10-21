function dataset = dsGen(dsParam, dsNos, grindingIsOn)
if nargin <= 1
    dsNos = dsParam.no;
end
if nargin <=2
    grindingIsOn = 1;
end
dataset = reading(dsNos, dsParam.source, dsParam.label, ...
    dsParam.extention, dsParam.dsPath);
if grindingIsOn
    dataset.grinder(dsParam.grindingSize);
end
% dataset.Label(strcmp(dataset.Label,'stableSide')) = {'stable'};
% dataset.Label(strcmp(dataset.Label,'air')) = {'stable'};
% dataset.Label(strcmp(dataset.Label,'entrance')) = {'stable'};
% dataset.Label(strcmp(dataset.Label,'exit')) = {'stable'};
end