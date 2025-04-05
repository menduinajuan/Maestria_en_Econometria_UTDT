% MODELO SOE-RBC (basado en Schmitt-Groh� y Uribe 2003)
% CANAD�


%*************************************************************************%
% 1. VARIABLES Y PAR�METROS %
%*************************************************************************%


var        y c k i h A y_h w d tb ca beta r;
varexo     e;
parameters alpha delta gamma omega phi psi1 rho rstar sigmae dbar psi2;


%*************************************************************************%
% 2. CALIBRACI�N %
%*************************************************************************%


alpha  = 0.32;
delta  = 0.1;
gamma  = 2;
omega  = 1.455;
phi    = 0.028;
psi1   = 0.11135;
rho    = 0.42;
rstar  = 0.04;
sigmae = 0.0129;
dbar   = 0.7442;
psi2   = psi1/150;


%*************************************************************************%
% 3. MODELO 1a (Factor de descuento end�geno sin internalizaci�n) %
%*************************************************************************%


model;

  h^(omega-1) = (1-alpha)*(y/h);

  (c-(h^omega)/omega)^(-gamma) = beta*((c(1)-(h(1)^omega)/omega)^(-gamma))*(alpha*(y(1)/k)+1-delta+phi*(k(1)-k))/(1+phi*(k-k(-1)));

  (c-(h^omega)/omega)^(-gamma) = beta*((c(1)-(h(1)^omega)/omega)^(-gamma))*(1+r);

  c+i+(phi/2)*(k-k(-1))^2+(1+r+psi2*(exp(d(-1)-dbar)-1))*d(-1) = y+d;

  y = A*(k(-1)^alpha)*(h^(1-alpha));

  beta = (1+c-h^omega/omega)^(-psi1);

  k = i+(1-delta)*k(-1);

  log(A) = rho*log(A(-1))+e;

  tb = 100*(y-c-i-(phi/2)*(k-k(-1))^2);

  ca = tb-(r+psi2*(exp(d(-1)-dbar)-1))*d(-1);

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
  d    = 0.7442;
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

statistic = 100*sqrt(diag(oo_.var(1:13,1:13)))./oo_.mean(1:13);

disp(' ');
disp('----------------------------------');
disp('Relative Standard Deviations in %');
disp('----------------------------------');
disp('VARIABLE        REL. STD. DEV.');
for i = 1:13
    fprintf('%-10s    %8.3f\n', M_.endo_names{i}, statistic(i));
end;