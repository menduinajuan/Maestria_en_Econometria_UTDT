%EDEIR_MODEL.M Small Open Economy With An External Debt-Elastic Interest Rate as presented in chapter 4 of ``Open Economy Macroeconomics,'' by Martin Uribe, 2013.
%Run this program only once or every time the structure of the model changes. No need to re run it when parameter values change. 
%model.m computes a symbolic  log-linear approximation to the  function f, which defines  the DSGE model: 
%  E_t f(yp,y,xp,x) =0. 
%here, a p denotes next-period variables.  
%
%Output: Analytical expressions for f and its first derivatives as well as x and y. The output is written to <filename>_num_eval.m which can then be run for numerical evaluations
%
%Calls: anal_deriv.m and anal_deriv_print2f.m 
%
%(c) Stephanie Schmitt-Grohe and Martin Uribe
%
%Date February 2013

filename = 'edeir'; %a file with this name and suffix _num_eval.m is created at the end of this program and contains symbolic expression for the function f and its derivatives fx fy fxp fyp 

syms RSTAR BETTA DBAR DELTA ALFA  PHI  RHO  STD_EPS_A ETASHOCK SIGG OMEGA PSSI

syms c cp h hp d dp k kp kfu kfup  la lap tb tbp ca cap ivv ivvp tby tbyp cay cayp r rp a ap output outputp tfp tfpp

%Equilibrium conditions. The symbols e1, e2, ... denote equation 1, equation2, ...

%Evolution of debt
e1 = -dp + (1+r)*d + c + ivv + PHI/2*(kp -k)^2 - output; 

%Output
e2 = -output + a*k^ALFA*h^(1-ALFA);

%FOC w.r.t. consumption
e3 = -la + (c-h^OMEGA/OMEGA)^(-SIGG); 

%FOC w.r.t. h
e4 = -h^(OMEGA-1)+ (1-ALFA) * a * (k/h)^ALFA;

%FOC w.r.t. debt
e5 = -la + BETTA * (1+rp) * lap;

%FOC w.r.t. capital
e6 = -la* (1+PHI*(kp-k)) + BETTA * lap * (1-DELTA + ALFA * ap * (kp/hp)^(ALFA-1) + PHI * (kfup-kp));

%Country premium
e7 = -rp + RSTAR + PSSI * (exp(dp-DBAR) -1);

%Investment
e8 = -ivv +kp - (1-DELTA)*k;

%Trade balance
e9 = -tb + output-c - ivv;

%Trade-balance-to-output ratio
e10 = -tby + tb/output;

%Current account
e11 = -ca-dp+d;

%Current-account-to-output ratio
e12 = -cay + ca/output;

%Evolution of TFP
e13 = -log(ap) + RHO * log(a);

%make kfu=kp
e14 = -kfu+kp;

%TFP
e15 = -tfp + a;

%Create function f
f = eval(eval([e1;e2;e3;e4;e5;e6;e7;e8;e9;e10;e11;e12;e13;e14;e15]));

% Define the vector of controls in periods t and t+1, controlvar and controlvarp, and the vector of states in periods t and t+1, statevar and statevarp

%States to substitute from levels to logs

states_in_logs = [k a];
states_in_logsp = [kp ap];

statevar = [d r states_in_logs];

statevarp = [dp rp states_in_logsp];
 
controls_in_logs = [c ivv output h la kfu tfp];

controls_in_logsp = [cp  ivvp outputp hp lap kfup tfpp];

controlvar = [controls_in_logs tb tby ca cay]; 

controlvarp = [controls_in_logsp tbp tbyp cap cayp]; 

%Number of states
ns = length(statevar);

%Make f a function of the logarithm of the state and control vector

%variables to substitute from levels to logs
variables_in_logs = transpose([states_in_logs, controls_in_logs, states_in_logsp, controls_in_logsp]);

f = subs(f, variables_in_logs, exp(variables_in_logs));

approx = 1;

%Compute analytical derivatives of f
[fx,fxp,fy,fyp]=anal_deriv(f,statevar,controlvar,statevarp,controlvarp,approx);

%Make f and its derivatives a function of the level of its arguments rather than the log
f = subs(f, variables_in_logs, log(variables_in_logs));
fx = subs(fx, variables_in_logs, log(variables_in_logs));
fy = subs(fy, variables_in_logs, log(variables_in_logs));
fxp = subs(fxp, variables_in_logs, log(variables_in_logs));
fyp = subs(fyp, variables_in_logs, log(variables_in_logs));

%Symbolically evaluate f and its derivatives at the nonstochastic steady state (c=cp, etc.)
cu = transpose([statevar controlvar k]);
cup = transpose([statevarp controlvarp kfu ]);


for subcb=1:2 %substitution must be run twice  in case the original system is a stochastic difference equation of order higher than one. For example, the current model features k_t, k_t+1, and k_t+2 and thus is a 2nd order difference equation

f = subs(f, cup,cu,0);
fx = subs(fx, cup,cu,0);
fy = subs(fy, cup,cu,0);
fxp = subs(fxp, cup,cu,0);
fyp = subs(fyp, cup,cu,0);
end


%Construct ETASHOCK matrix, which determines the var/cov of the forcing term of the system. Specifically, the state vector evolves over time according to 
%x_t+1 = hx x_t + ETASHOCK epsilon_t+1
ETASHOCK(ns,1) = STD_EPS_A;
ETASHOCK(1:ns-1) = 0;

varshock = ETASHOCK*ETASHOCK';

%Print derivatives to file <filename>_num_eval.m'  for model evaluation
anal_deriv_print2f(filename,fx,fxp,fy,fyp,f,ETASHOCK);


eval(['save ' filename '.mat'])