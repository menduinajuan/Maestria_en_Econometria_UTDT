% MODELO SOE-RBC (basado en Schmitt-Groh� y Uribe 2003)
% COLOMBIA


%*************************************************************************%
% 1. VARIABLES Y PAR�METROS %
%*************************************************************************%


var        y c k i h A y_h w d tb ca p r;
varexo     e;
parameters alpha delta gamma omega phi rho rstar sigmae beta dbar psi2;


%*************************************************************************%
% 2. CALIBRACI�N %
%*************************************************************************%



alpha  = 0.33;
delta  = 0.0532;
gamma  = 0.316;
omega  = 1.7;
phi    = 0.028;
rho    = 0.811;
rstar  = 0.0484;
sigmae = 0.0129;
beta   = 1/(1+rstar);
dbar   = 0.5725;
psi2   = 0.11135/150;


%*************************************************************************%
% 3. MODELO 2 (Tasa de inter�s el�stica a la deuda) %
%*************************************************************************%


model;

  h^(omega-1) = (1-alpha)*(y/h);

  (c-(h^omega)/omega)^(-gamma) = beta*((c(1)-(h(1)^omega)/omega)^(-gamma))*(alpha*(y(1)/k)+1-delta+phi*(k(1)-k))/(1+phi*(k-k(-1)));

  (c-(h^omega)/omega)^(-gamma) = beta*((c(1)-(h(1)^omega)/omega)^(-gamma))*(1+r);

  c+i+(phi/2)*(k-k(-1))^2+(1+r)*d(-1) = y+d;

  y = A*(k(-1)^alpha)*(h^(1-alpha));

  p = psi2*(exp(d(-1)-dbar)-1);

  k = i+(1-delta)*k(-1);

  log(A) = rho*log(A(-1))+e;

  tb = 100*(y-c-i-(phi/2)*(k-k(-1))^2);

  ca = tb-r*d(-1);

  y_h = y/h;

  r = rstar+p;

  w = (1-alpha)*(y/h);

end;


%*************************************************************************%
% 4. COMPUTACI�N %
%*************************************************************************%


initval;

  k = 5;
  c = 1.12;
  h = 1.0074;
  d = 0.5725;
  A = 1; 
  e = 0;

end;

shocks;
  var e = sigmae^2;
end;

steady;


%*************************************************************************%
% 5. RESULTADOS %
%*************************************************************************%


stoch_simul(order=1, irf=10);

statistic = 100*sqrt(diag(oo_.var(1:13,1:13)))./oo_.mean(1:13);

disp(' ');
disp('----------------------------------');
disp('Relative Standard Deviations in %');
disp('----------------------------------');
disp('VARIABLE        REL. STD. DEV.');
for i = 1:13
    fprintf('%-10s    %8.3f\n', M_.endo_names{i}, statistic(i));
end;