function out = driver(data, properties, echdParam, param)
savingPath = "C:\Users\mhoss\Desktop\Hossein\enetgyBased_optimized";

rawOut = echd.energybased(data, properties, echdParam);

out.kalmanOut = rawOut.kalmanOut{1};
% out.bandpassFiltersOut = squeeze(rawOut.bandpassFiltersOut{1});
out.priodicEn = squeeze(rawOut.priodicEn{1});
out.ratio = rawOut.ratio{1};
out.detected = rawOut.detected{1};


if 4 <= nargin && isfield(param, 'subFolder')
    subFolder = param.subFolder;
elseif 4 <= nargin && isstring(param)
    subFolder = param;
else
    subFolder = [];
end
if 4 <= nargin && isfield(param, 'savingIsOn') && ~param.savingIsOn
    % save unless told otherwise
else % saving
    fileParts = split(properties.File, filesep);
    fileName = split(fileParts{end}, '.');
    fileName = fileName{1};
    
    fileFullPath = fullfile(savingPath, subFolder, [fileName, '.mat']);
    save(fileFullPath, 'out');
end

end