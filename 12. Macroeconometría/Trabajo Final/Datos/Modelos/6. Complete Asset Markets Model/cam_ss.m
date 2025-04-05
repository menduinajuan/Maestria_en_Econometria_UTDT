%cam_ss.m
%Steady state of the Small Open Economy Model With complete asset markets presented in chapter 4 of ``Open Economy Macroeconomics,'' by Martin Uribe, 2013.

%Calibration
%Time unit is a year
SIGG = 2; %curvature of period utility funciton
DELTA = 0.1; %depreciation rate
RSTAR = 0.04; %long-run interest rate (used to calibrate the subjective discount factor)
ALFA = 0.32; %F(k,h) = k^ALFA h^(1-ALFA)
OMEGA = 1.455; %Frisch ela st. from Mendoza 1991
DBAR =  0.74421765717098; %debt
PHI = 0.028; %capital adjustment cost
RHO = 0.42; %persistence of TFP shock
STD_EPS_A = 0.0129; %standard deviation of innovation to TFP shock

BETTA = 1/(1+RSTAR); %subjective discount factor

KAPA = ((1/BETTA - (1-DELTA)) / ALFA)^(1/(ALFA-1)); %k/h

h = ((1-ALFA)*KAPA^ALFA)^(1/(OMEGA -1)); 

k = KAPA * h; %capital

output = KAPA^ALFA * h; %output

c = output-DELTA*k-RSTAR*DBAR; %this is the level of consumpiton in the EDEIR model, which we use to calibrate PSSI_CAM

ivv = DELTA * k; %investment

tb = output - ivv - c; %trade balance

tby = tb/output;

ca = 0;

cay = ca/output;

s = tb * BETTA/ (BETTA-1); %value of portfolio  purchased in the current period

b = s / BETTA; %current-period payoff of portfolio purchased in the previous period

a = 1; %technological factor

la = ((c - h^OMEGA/OMEGA))^(-SIGG); %marginal utility of wealth

PSSI_CAM = la; 