function [En_Threshold,w_BOL] = thresholdSet(SigName)

w_BOL=0;
if SigName == categorical({'Mic'}) | strfind(SigName,'Mic')>0
    w_BOL=1;
    En_Threshold = 2e-6;
end
if SigName == categorical({'Acc'}) | strfind(SigName,'Acc')>0
    w_BOL=2;
    En_Threshold = 1e-8;
end

if strfind(SigName,'Derv Spindle Speed')>0
    w_BOL=2;
    En_Threshold = 0;
end

if strfind(SigName,'Spindle Speed')>0
    w_BOL=1;
    En_Threshold = 0;
end

if SigName == categorical({'Spindle Current'}) | strfind(SigName,'Spindle Current')>0
    w_BOL=1;
    En_Threshold = 1e-8;
end


end

