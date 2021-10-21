function [output] = readFcn(path, obj)
m = matfile(path);
output = m.(obj);
end