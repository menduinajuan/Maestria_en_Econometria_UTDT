%edeir_ss.m
%Steady state of the Small Open Economy Model With An External Debt-Elastic Interest Rate as presented in chapter 4 of ``Open Economy Macroeconomics,'' by Martin Uribe, 2013.

%Calibration
%Time unit is a year
SIGG = 2; %mENDOZA
DELTA = 0.1; %depreciation rate
RSTAR = 0.04; %long-run interest rate
ALFA = 0.32; %F(k,h) = k^ALFA h^(1-ALFA)
OMEGA = 1.455; %Frisch ela st. from Mendoza 1991
DBAR =  0.74421765717098; %debt
PSSI = 0.11135/150; %debt elasticity of interest rate
PHI = 0.028; %capital adjustment cost
RHO = 0.42; %persistence of TFP shock
STD_EPS_A = 0.0129; %standard deviation of innovation to TFP shock

BETTA = 1/(1+RSTAR); %subjective discount factor


 r = RSTAR; %interest rate
d = DBAR; %debt
KAPA = ((1/BETTA - (1-DELTA)) / ALFA)^(1/(ALFA-1)); %k/h

h = ((1-ALFA)*KAPA^ALFA)^(1/(OMEGA -1)); 

k = KAPA * h; %capital

output = KAPA^ALFA * h; %output

c = output-DELTA*k-RSTAR*DBAR;

ivv = DELTA * k; %investment

tb = output - ivv - c; %trade balance

tby = tb/output;

ca = -r*d+tb;

cay = ca/output;

a = 1; %technological factor

tfp = a; %technological factor

la = ((c - h^OMEGA/OMEGA))^(-SIGG); %marginal utility of wealth