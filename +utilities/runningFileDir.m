function [fileDir, fileName, fileDirName] = runningFileDir(inputName)
fileName = mfilename;
fileDirName = mfilename('fullpath');
str2find = '+utilities';
endDir = strfind(fileDirName, str2find)-2;
fileDir = fileDirName(1:endDir);
if 1 <= nargin
    fileDir = fullfile(fileDir, inputname);
end
end