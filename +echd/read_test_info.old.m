function [Test]=read_test_info(data_file)
%   Input is the file name with format :
%       'Cut6_S9000_N2_F2000_ap0p8_ae20_D20'
%   Output is the test information
%     -> Test.SF   :[rev/s - Hz] Spindle frequency
%     -> Test.N    :[] number o flutes
%     -> Test.D    :[] number o flutes, Diameter of the flute
%     -> Test.TPE  : % tooth passing frequency %[Hz] 
%     -> Test.F    :[mm/rev]
%     -> Test.Fpt  : feed oer tooth [mm]
%     -> Test.ap   :  [mm] Axial Depth of cut
%     -> Test.ae   :  [mm] radial Depth of cut (max)

%   Test data
ind1=  strfind(data_file,'_S');
ind2=  strfind(data_file,'_N');
ind3=  strfind(data_file,'_F');
ind4=  strfind(data_file,'_ap');
ind5=  strfind(data_file,'_ae');
ind6=  strfind(data_file,'_D');

Test.SF =str2double(data_file(ind1+2:ind2-1))/60;% [rev/s - Hz] Spindle frequency
Test.N =str2double(data_file(ind2+2:ind3-1)); %[]
Test.TPE = Test.SF*Test.N; % tooth passing frequency %[Hz] 

%%
indp=strfind(data_file(ind3+2:ind4-1),'p');
if isempty(indp)
    Test.F =str2double(data_file(ind3+2:ind4-1));%[mm/rev]
else
    dum = data_file(ind3+2:ind4-1);
    Test.F = str2double(dum(1:indp-1))+ str2double(dum(indp+1:end))/(10^(length(dum(indp+1:end))));
end
Test.Fpt = Test.F/(Test.SF*60)/Test.N;% feed oer tooth [mm]
%%
indp=strfind(data_file(ind4+3:ind5-1),'p');
if isempty(indp)
    Test.ap =str2double(data_file(ind4+3:ind5-1));
else
    dum = data_file(ind4+3:ind5-1);
    Test.ap = str2double(dum(1:indp-1))+ str2double(dum(indp+1:end))/(10^(length(dum(indp+1:end))));
end

indp=strfind(data_file(ind5+3:ind6-1),'p');
if isempty(indp)
    Test.ae =str2double(data_file(ind5+3:ind6-1));
else
    dum = data_file(ind5+3:ind6-1);
    Test.ae = str2double(dum(1:indp-1))+ str2double(dum(indp+1:end))/(10^(length(dum(indp+1:end))));
end

indp=strfind(data_file(ind6+2:end),'p');
if isempty(indp)
    Test.D =str2double(data_file(ind6+2:end));
else
    dum = data_file(ind6+2:end);
    Test.D = str2double(dum(1:indp-1))+ str2double(dum(indp+1:end))/(10^(length(dum(indp+1:end))));
end
end