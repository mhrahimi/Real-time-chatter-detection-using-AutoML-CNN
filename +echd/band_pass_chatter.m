function [numCoeffs, denCoeffs] =band_pass_chatter(wc_c, Ts)
%Inputs wc_c, frequency band in Hz
% Ts: Sampling time
%--------------------------
% wc_c = [n  n+1]*w_tpe; % the band pass frq interval
%   Frequency wraping with bi-linear transform
wc_d = 2/Ts .* tan(2*pi*wc_c*Ts/2);
w0 = sqrt(wc_d(1) * wc_d(2));
dw = wc_d(2) - wc_d(1);
Q = w0/dw;
a1 = 0.7654; % this is constant plenarameter
a2 = 1.8478;% this is constant parameter



%------------------ Coeffcients of discrete tf---------------------
%---------------------------
d8=(2/Ts*Q/w0)^4;
d7=(a1+a2)*(2/Ts*Q/w0)^3;
d6=(2/Ts*Q/w0)^2*(a1*a2 + 2*(2*Q^2+1));
d5=(2/Ts)^1*(a1+a2)*Q/w0*(3*Q^2+1);
d4=(6*Q^4 +  (2*a1*a2+4)*Q^2 + 1);
d3=(2/Ts)^-1*(a1+a2)*w0*Q*(1 + 3*Q^2);
d2=(Ts/2*Q*w0)^2*(4*Q^2+ 2 + a1*a2);
d1=(a1+a2)*(Ts/2*Q*w0)^3;
d0=(Q*w0*Ts/2)^4;

% dd8 = d0 - d1 + d2 - d3 + d4 - d5 + d6 - d7 + d8;
% dd7 = 8*d0 - 6*d1 + 4*d2 - 2*d3 + 2*d5 - 4*d6 + 6*d7 - 8*d8;
% dd6 = 28*d0 - 14*d1 + 4*d2 + 2*d3 - 4*d4 + 2*d5 + 4*d6 - 14*d7 + 28*d8;
% dd5=56*d0 - 14*d1 - 4*d2 + 6*d3 - 6*d5 + 4*d6 + 14*d7 - 56*d8;
% dd4=70*d0 - 10*d2 + 6*d4 - 10*d6 + 70*d8;
% dd3=56*d0 + 14*d1 - 4*d2 - 6*d3 + 6*d5 + 4*d6 - 14*d7 - 56*d8;
% dd2=28*d0 + 14*d1 + 4*d2 - 2*d3 - 4*d4 - 2*d5 + 4*d6 + 14*d7 + 28*d8;
% dd1=8*d0 + 6*d1 + 4*d2 + 2*d3 - 2*d5 - 4*d6 - 6*d7 - 8*d8;
% dd0=d0 + d1 + d2 + d3 + d4 + d5 + d6 + d7 + d8;

dd0 = d0 - d1 + d2 - d3 + d4 - d5 + d6 - d7 + d8;
dd1 = 8*d0 - 6*d1 + 4*d2 - 2*d3 + 2*d5 - 4*d6 + 6*d7 - 8*d8;
dd2 = 28*d0 - 14*d1 + 4*d2 + 2*d3 - 4*d4 + 2*d5 + 4*d6 - 14*d7 + 28*d8;
dd3=56*d0 - 14*d1 - 4*d2 + 6*d3 - 6*d5 + 4*d6 + 14*d7 - 56*d8;
dd4=70*d0 - 10*d2 + 6*d4 - 10*d6 + 70*d8;
dd5=56*d0 + 14*d1 - 4*d2 - 6*d3 + 6*d5 + 4*d6 - 14*d7 - 56*d8;
dd6=28*d0 + 14*d1 + 4*d2 - 2*d3 - 4*d4 - 2*d5 + 4*d6 + 14*d7 + 28*d8;
dd7=8*d0 + 6*d1 + 4*d2 + 2*d3 - 2*d5 - 4*d6 - 6*d7 - 8*d8;
dd8=d0 + d1 + d2 + d3 + d4 + d5 + d6 + d7 + d8;
% The denominator coeffiecients
denCoeffs =[dd8 dd7 dd6 dd5 dd4 dd3 dd2 dd1 dd0]/dd8;
numCoeffs=[1,0, -4,0, 6,0, -4,0, 1]/dd8;
