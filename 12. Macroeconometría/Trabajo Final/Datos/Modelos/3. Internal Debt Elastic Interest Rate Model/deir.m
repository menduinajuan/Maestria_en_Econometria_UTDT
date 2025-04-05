function [nfx,nfxp,nfy,nfyp] = deir
%This program computes a log-linear approximation to the  function f for a small open economy with a debt-elastic interest-rate premium. The model is described in ``Closing Small Open Economy Models,'' by Stephanie Schmitt-Grohe and Martin Uribe. The function f defines  the DSGE model (a p denotes next-period variables) : 
%  E_t f(yp,y,xp,x) =0. 
%
%Inputs: none
%
%Output: Numerical first derivative of f
%
%Calls: anal_deriv.m num_eval.m deir_ss.m
%
%(c) Stephanie Schmitt-Grohe and Martin Uribe
%
%Date November 8, 2001

approx = 1; %Order of approximation desired

%Define parameters
syms GAMA DELTA ALFA PSSI RHO OMEGA PHI R DBAR 

%Define variables 
syms c cp k kp k1 k1p a ap h hp d dp  yy yyp iv ivp tb tbp la lap tby tbyp cay cayp    

%Give functional form for utility, production, and interest-rate premium functions
u = ((c - h^OMEGA/OMEGA)^(1-GAMA)-1)/(1-GAMA);
up = ((cp - hp^OMEGA/OMEGA)^(1-GAMA)-1)/(1-GAMA);
p = PSSI * (exp(d-DBAR) - 1);
pp = PSSI * (exp(dp-DBAR) - 1);
output = a * k^ALFA *  h^(1-ALFA);
outputp = ap * kp^ALFA *  hp^(1-ALFA);

%Write equations (e1, e2,...en)
%Note: we take a linear, rather than log-linear, approximation with respect to tb, the trade balance)
e1 = (1+R+p) * d - log(tb) - dp;

e2 = -log(tb) + yy - c - iv - PHI/2 * (kp -k)^2;

e3 = -yy + a * k^ALFA *  h^(1-ALFA);

e4 = -iv + kp - (1-DELTA) *k;

e5 = - la * (1+R) + (1+R+pp) * lap;

e6 = - la + diff(u,'c');

e7 = -diff(u,'h') - la * diff(output,'h');

e8 = -la * (1+ PHI*(kp-k)) + 1 / (1+R) *  lap* (diff(outputp,'kp') + 1 - DELTA + PHI * (k1p -k1));

e9 = -k1 + kp;

e10 = -log(ap) + RHO * log(a); 

e11 = -log(tby) + log(tb) / yy; 

e12 = -log(cay) - (R+p)*d / yy + log(tby); 

%Create function f
f = [e1;e2;e3;e4;e5;e6;e7;e8;e9;e10;e11;e12];

% Define the vector of controls, y, and states, x
x = [k d a];

y = [yy c iv h tby cay tb la k1];

xp = [kp dp ap];

yp = [yyp cp ivp hp tbyp cayp tbp lap k1p];


%Make f a function of the logarithm of the state and control vector
f = subs(f, [x,y,xp,yp], exp([x,y,xp,yp]));

%Compute analytical derivatives of f
[fx,fxp,fy,fyp]=anal_deriv(f,x,y,xp,yp,approx);

%Numerical evaluation

%Assign values to parameters and steady-state variables
[GAMA,DELTA,ALFA,PSSI,RHO,OMEGA,PHI,R,DBAR,c,cp,h,hp,k,kp,k1,k1p,d,dp,iv,ivp,tb,tbp,la,lap,yy,yyp,a,ap,tby,tbyp,cay,cayp]=deir_ss;


%Compute numerical derivatives of f
num_eval