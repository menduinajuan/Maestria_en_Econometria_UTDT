% MODELO SOE-RBC (basado en Schmitt-Groh� y Uribe 2003)
% COLOMBIA


%*************************************************************************%
% 1. VARIABLES Y PAR�METROS %
%*************************************************************************%


var        y c k i h A y_h w d tb ca beta eta r;
varexo     e;
parameters alpha delta gamma omega phi psi1 rho rstar sigmae;


%*************************************************************************%
% 2. CALIBRACI�N %
%*************************************************************************%


alpha  = 0.33;
delta  = 0.0532;
gamma  = 0.316;
omega  = 1.7;
phi    = 0.028;
psi1   = 0.11135;
rho    = 0.811;
rstar  = 0.0484;
sigmae = 0.0129;


%*************************************************************************%
% 3. MODELO 1 (Factor de descuento end�geno) %
%*************************************************************************%


model;

  h^(omega-1) = (1-alpha)*(y/h);

  (c-(h^omega)/omega)^(-gamma) = beta*((c(1)-(h(1)^omega)/omega)^(-gamma))*(alpha*(y(1)/k)+1-delta+phi*(k(1)-k))/(1+phi*(k-k(-1)));

  (c-(h^omega)/omega)^(-gamma) = beta*((c(1)-(h(1)^omega)/omega)^(-gamma)-eta(1)*(-psi1*(1+c(1)-h(1)^omega/omega)^-psi1-1))*(1+rstar)+eta*(-psi1*(1+c-h^omega/omega)^-psi1-1);

  c+i+(phi/2)*(k-k(-1))^2+(1+rstar)*d(-1) = y+d;

  y = A*(k(-1)^alpha)*(h^(1-alpha));

  beta = (1+c-h^omega/omega)^(-psi1);

  k = i+(1-delta)*k(-1);

  eta = -((c-(h^omega)/omega)^(-gamma)/(1-gamma))/(1-beta);

  log(A) = rho*log(A(-1))+e;

  tb = 100*(y-c-i-(phi/2)*(k-k(-1))^2);

  ca = tb-r*d(-1);

  y_h = y/h;

  r = rstar;

  w = (1-alpha)*(y/h);

end;


%*************************************************************************%
% 4. COMPUTACI�N %
%*************************************************************************%


initval;

  k    = 5;
  c    = 1.12;
  h    = 1.0074;
  d    = 0.5725;
  A    = 1; 
  e    = 0;
  beta = 1/(1+rstar);

end;

shocks;
  var e = sigmae^2;
end;

steady;


%*************************************************************************%
% 5. RESULTADOS %
%*************************************************************************%


stoch_simul(order=1, irf=10);

statistic = 100*sqrt(diag(oo_.var(1:14,1:14)))./oo_.mean(1:14);

disp(' ');
disp('----------------------------------');
disp('Relative Standard Deviations in %');
disp('----------------------------------');
disp('VARIABLE        REL. STD. DEV.');
for i = 1:14
    fprintf('%-10s    %8.3f\n', M_.endo_names{i}, statistic(i));
end;