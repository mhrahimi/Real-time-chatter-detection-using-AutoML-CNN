function [output] = readFcn2(path, obj)
% m = matfile(path);
% output = m.out.(obj);
m = load(path);
output = m.out.(obj);
end