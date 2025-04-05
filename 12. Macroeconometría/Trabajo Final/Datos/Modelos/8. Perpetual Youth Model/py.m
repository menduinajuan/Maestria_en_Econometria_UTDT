function [nfx,nfxp,nfy,nfyp] = deir
%This program computes a log-linear approximation to the  function f for a small open economy with perpetual youth. The model is described in``Lectures in Open Economy Macroeconomics,'' by Martin Uribe. The function f defines  the DSGE model (a p denotes next-period variables) : 
%  E_t f(yp,y,xp,x) =0. 
%
%Inputs: none
%
%Output: Numerical first derivative of f
%
%Calls: anal_deriv.m num_eval.m py_ss.m
%
%(c) Martin Uribe
%
%Date April 2009

approx = 1; %Order of approximation desired

%Define parameters
syms DELTA ALFA THETA RHO OMEGA PHI R XBAR BETTA

%Define variables 
syms c cp k kp k1 k1p a ap h hp d dp  yy yyp iv ivp tb tbp la lap tby tbyp cay cayp  zztil zztilp

%Give functional form for utility, production, and interest-rate premium functions
output = a * k^ALFA *  h^(1-ALFA);
outputp = ap * kp^ALFA *  hp^(1-ALFA);


pai =  ALFA * output - iv - PHI/2 * (kp-k)^2;

zz = pai + (1-1/OMEGA) * (1-ALFA) * output  - XBAR;

xx = XBAR + (BETTA * (1+R)^2 - THETA)  / BETTA / THETA / (1+R) * (log(zztil) - THETA* log(d));

xxp = XBAR + (BETTA * (1+R)^2 - THETA)  / BETTA / THETA / (1+R) * (log(zztilp) - THETA* log(dp));

%Write equations (e1, e2,...en)
%Note: we take a linear, rather than log-linear, approximation with respect to tb, the trade balance)
e1 = (1+R) * log(d) - zz + xx - XBAR - log(dp);

e2 = -log(tb) + yy - c - iv - PHI/2 * (kp -k)^2;

e3 = -yy + output;

e4 = -iv + kp - (1-DELTA) *k;

e5 = - la - (xx-XBAR);

e6 = -diff(output,'h') + h^(OMEGA-1);

e7 = -la * (1+ PHI*(kp-k)) + BETTA *  lap* (diff(outputp,'kp') + 1 - DELTA + PHI * (k1p -k1));

e8 = -k1 + kp;

e9 = -log(ap) + RHO * log(a); 

e10 = -log(tby) + log(tb) / yy; 

e11 = -log(cay) - (log(dp)-log(d))/yy; 

e12 = -log(zztil) + THETA / (1+R) * (zz+log(zztilp));

e13 = -xx + c - h^OMEGA / OMEGA;

%Create function f
f = [e1;e2;e3;e4;e5;e6;e7;e8;e9;e10;e11;e12;e13];

% Define the vector of controls, y, and states, x
x = [k d a];

y = [yy c iv h tby cay tb la k1 zztil];

xp = [kp dp ap];

yp = [yyp cp ivp hp tbyp cayp tbp lap k1p zztilp];


%Make f a function of the logarithm of the state and control vector
f = subs(f, [x,y,xp,yp], exp([x,y,xp,yp]));

%Compute analytical derivatives of f
[fx,fxp,fy,fyp]=anal_deriv(f,x,y,xp,yp,approx);

%Numerical evaluation

%Assign values to parameters and steady-state variables

[DELTA,ALFA,RHO,OMEGA,PHI,R,c,cp,h,hp,k,kp,k1,k1p,d,dp,iv,ivp,tb,tbp,la,lap,yy,yyp,a,ap,tby,tbyp,cay,cayp, zztil, zztilp, XBAR, THETA, BETTA]=py_ss




%Compute numerical derivatives of f
num_eval
