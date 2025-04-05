function [nfx,nfxp,nfy,nfyp] = mendoza91
%This program computes a log-linear approximation to the  function f for a small open economy with endogenous discount factor. The model is described in ``Closing Small Open Economy Models,'' by Stephanie Schmitt-Grohe and Martin Uribe. The function f defines  the DSGE model (a p denotes next-period variables) : 
%  E_t f(yp,y,xp,x) =0. 
%
%Inputs: none
%
%Output: Numerical first derivative of f
%
%Calls: anal_deriv.m num_eval.m mendoza91_ss.m
%
%(c) Stephanie Schmitt-Grohe and Martin Uribe
%
%Date November 8, 2001

approx = 1; %Order of approximation desired

%Define parameters
syms GAMA DELTA ALFA PSSI RHO OMEGA PHI R

%Define variables 
syms c cp k kp k1 k1p a ap h hp d dp  yy yyp iv ivp tb tbp la lap eta etap tby tbyp cay cayp    


%Give functional form for discount, production, and utility functions
beta = (1 + c - h^OMEGA/OMEGA)^(-PSSI);
betap = (1 + cp - hp^OMEGA/OMEGA)^(-PSSI);
u = ((c - h^OMEGA/OMEGA)^(1-GAMA)-1)/(1-GAMA);
up = ((cp - hp^OMEGA/OMEGA)^(1-GAMA)-1)/(1-GAMA);
output = a * k^ALFA *  h^(1-ALFA);
outputp = ap * kp^ALFA *  hp^(1-ALFA);

%Write equations (ei, i=1:n)
%Note: we take a linear, rather than log-linear, approximation with respect to tb, the trade balance)
e1 = (1+R) * d - log(tb) - dp;

e2 = -log(tb) + yy - c - iv - PHI/2 * (kp -k)^2;

e3 = -yy + a * k^ALFA *  h^(1-ALFA);

e4 = -iv + kp - (1-DELTA) *k;

e5 = - la + beta * (1+R) *lap;

e6 = - la + diff(u,'c') - eta * diff(beta,'c');

e7 = -eta - up + etap * betap;

e8 = -diff(u,'h') +  eta * diff(beta,'h') - la * diff(output,'h');

e9 = -la * (1+ PHI*(kp-k)) + beta *  lap* (diff(outputp,'kp') + 1 - DELTA + PHI * (k1p -k1));

e10 = -k1 + kp;

e11 = -log(ap) + RHO * log(a); 

e12 = -log(tby) + log(tb) / yy; 

e13 = -log(cay) - R*d / yy + log(tby); 

%Create function f
f = [e1;e2;e3;e4;e5;e6;e7;e8;e9;e10;e11;e12;e13];

% Define the vector of controls, y, and states, x

x = [k d a];

y = [yy c iv h tby cay tb eta la k1];

xp = [kp dp ap];

yp = [yyp cp ivp hp tbyp cayp tbp etap lap k1p];


%Make f a function of the logarithm of the state and control vector
f = subs(f, [x,y,xp,yp], exp([x,y,xp,yp]));

%Compute analytical derivatives of f
[fx,fxp,fy,fyp]=anal_deriv(f,x,y,xp,yp,approx);

%Numerical evaluation

%Assign values to parameters and steady-state variables
[GAMA,DELTA,ALFA,PSSI,RHO,OMEGA,PHI,R,c,cp,h,hp,k,kp,k1,k1p,d,dp,iv,ivp,tb,tbp,eta,etap,la,lap,yy,yyp,a,ap,tby,tbyp,cay,cayp]=mendoza91_ss;

%Compute numerical derivatives of f
num_eval