options crt;  ? 11e8
in mroz;

title 'Exercise 8, part (a) - specify equations';
frml wage lww1 = g0 + g1*wa + g2*wa2 + g3*we + g4*cit + g5*ax;
  param g0-g5;

? reservation wage equation - overidentified
frml resover  lwr = b0 + b1*wa + b2*wa2 + b3*we +
                    b4*kl6 + b5*k618 + b6*prin + b7*un;
  param b0-b7;
frml hours whrs = d*(lww1 - lwr);   ? (11.65a)
  param d,2000;  ? non-zero starting value so that derivatives are non-zero
                 ? (speed up iterations by using starting value from 11e5)
? substitute in equations
eqsub(name=hover)  hours wage resover;

title 'obtain starting values from sample of workers';
select lfp;
lsq wage;
const g0-g5;
lsq hover;
param g0-g5;
lsq wage hover;
set loglsq = @logl;
? Sigma = [ sig2w     sigdw*d    ]
?         [ sigdw*d   sig2d*d**2 ]
set sig2w = @covu(1,1);
set sigdw = @covu(2,1)/d;
set sig2d = @covu(2,2)/d**2;
?  Solve for structural variance parameters:
frml esdw sigdw = sig2w - sigwr;
frml es2d sig2d = sig2w + sig2r - 2*sigwr;
set sigwr = sig2w - sigdw;
set sig2r = sig2d - sig2w + 2*sigwr;
param sig2w sig2r sigwr;

title 'Exercise 8, part (b) - log likelihood function';
select 1;
nowork = 1-lfp;
frml tobitex logl = lfp*jpdf2 + nowork*lcnorm(-J/sqrt(sig2d));

? joint pdf for 2 equations
frml jpdf2 -epsie/2 - log(detsig)/2 - log2pi;  ? -neq*log(2*pi)/2

frml epsie ew*ew*sigiw + ed*ed*sigid + 2*ew*ed*sigidw;  ? e'Sigma"e
frml ew lww1 - lwwhat;  ? residual from wage equation
frml ed whrs - d*J;     ? residual from hours equation
frml J lwwhat - lwr;
frml lwwhat1 lwwhat = g0 + g1*wa + g2*wa2 + g3*we + g4*cit + g5*ax;
? sigiw, sigid, and sigidw are the elements of Sigma-inverse
frml sigiw sig2d*d**2/detsig;
frml sigid sig2w/detsig;
frml sigidw -sigdw*d/detsig;
frml detsig d**2 * (sig2w*sig2d - sigdw**2);  ? det(Sigma)
  set detsig detsigma;  print detsigma;

set pi = 4*atan(1);  ? tan(pi/4) = 1
set log2pi = log(2*pi);

? Substitute in all the equations
eqsub tobitex jpdf2 epsie sigiw sigid sigidw detsig esdw es2d
                    ew ed J resover lwwhat1;

title 'Exercise 8, part (c) - ML estimation - with experience';
title 'Estimation for workers only -- to check LogL for errors';
title 'LogL should be exactly the same as from LSQ';
select lfp;
ML(hiter=n) tobitex;
print @logl loglsq;
title 'Estimation with full sample';
select 1;
ML(hiter=n,hcov=nw) tobitex;

title 'Exercise 8, part (d) - ML estimation - without experience';
const g5,0;  ? Just hold the coefficient on ax fixed at zero.
title 'obtain starting values from sample of workers';
select lfp;
lsq wage;
title 'use OLS method to estimate hours equation from exercise 11e5';
lwwhat = @fit;
?frml resover  lwr = b0 + b1*wa + b2*wa2 + b3*we +
?                    b4*kl6 + b5*k618 + b6*prin + b7*un;
olsq(silent) whrs lwwhat c wa wa2 we kl6 k618 prin un;
unmake @coef d b0-b7;
dot b0-b7;
  set . = . / (-d) ;   ? recover structural params by division
enddot;
title 'check OLS structural parameters with LSQ';
print @logl @ssr;
const g0-g4;
lsq hover;
param g0-g4;
lsq wage hover;
set sig2w = @covu(1,1);
set sigdw = @covu(2,1)/d;
set sig2d = @covu(2,2)/d**2;
?  Solve for structural variance parameters:
set sigwr = sig2w - sigdw;
set sig2r = sig2d - sig2w + 2*sigwr;
title 'Estimation with full sample';
select 1;
ML(hiter=n,hcov=nw) tobitex;
