options crt;  ? 11e5
in mroz;

title 'Exercise 5, part (a) - wage equation';
select lfp;
frml wage lww = g0 + g1*wa + g2*wa2 + g3*we + g4*cit + g5*ax;
  param g0-g5;
lww = log(ww);
lsq wage;

title 'Exercise 5, part (b) - reservation wage equations';
frml resjust  lwr = a0 + a1*wa + a2*wa2 + a3*we + a4*cit +
                    a5*kl6 + a6*k618 + a7*prin + a8*un;
  param a0-a8;
frml resover  lwr = b0 + b1*wa + b2*wa2 + b3*we +
                    b4*kl6 + b5*k618 + b6*prin + b7*un;
  param b0-b7;
frml resunder lwr = c0 + c1*wa + c2*wa2 + c3*we + c4*cit + c5*ax +
                    c6*kl6 + c7*k618 + c8*prin + c9*un;
  param c0-c9;
frml hours whrs = d*(lww - lwr);   ? (11.65a), not sure how to use (11.65b)
  param d,1;  ? non-zero starting value so that derivatives are non-zero
? substitute in equations
eqsub(name=hjust)  hours wage resjust;
eqsub(name=hover)  hours wage resover;
eqsub(name=hunder) hours wage resunder;

title 'Exercise 5, part (c) - just identified estimation';
select 1;     ? full sample

title 'Method 1: reduced form / indirect least squares';
olsq whrs c wa wa2 we cit ax  kl6 k618 prin un;
title 'recover structural parameters from reduced form';
frml rd  d  = ax/g5;            ? coef of ax = d*g5
frml ra0 a0 =   -c*g5/ax + g0;  ? coef of c = d*(g0-a0)
frml ra1 a1 =  -wa*g5/ax + g1;
frml ra2 a2 = -wa2*g5/ax + g2;
frml ra3 a3 =  -we*g5/ax + g3;
frml ra4 a4 = -cit*g5/ax + g4;
frml ra5 a5 = -kl6*g5/ax;       ? coef of kl6 = -d*a5
frml ra6 a6 = -k618*g5/ax;
frml ra7 a7 = -prin*g5/ax;
frml ra8 a8 = -un*g5/ax;
analyz rd ra0-ra8;

title 'Method 2: OLS on transformed variables';
?  We are going to cheat slightly by using the value of d estimated
?  above to get a0-a8 directly.
?  To do this without cheating, see Method 3 below.
zd = g0 + g1*wa + g2*wa2 + g3*we + g4*cit + g5*ax;  ? same as LWWHAT below
z0 = -d;
z1 = -d*wa;
z2 = -d*wa2;
z3 = -d*we;
z4 = -d*cit;
z5 = -d*kl6;
z6 = -d*k618;
z7 = -d*prin;
z8 = -d*un;
ols whrs zd z0-z8;

? The methods below are easier than the ones above, although they
? are not described in the book.

title 'Method 3: second stage estimation';
? Note: since the original wage coefficients are held fixed,
? an easier way to do this estimation is to use a predicted
? log wage LWWHAT from those coefficients as the LWW variable
? with coefficient d.  Then we can divide the other coefficients
? in the reduced form by (-d) to obtain a0-a8 or b0-b7.
?   This also illustrates why the final model is not identified --
? the LWWHAT variable is a linear combination of the other variables
? in the reduced form.
genr wage lwwhat;
?frml resjust  lwr = a0 + a1*wa + a2*wa2 + a3*we + a4*cit +
?                    a5*kl6 + a6*k618 + a7*prin + a8*un;
olsq whrs lwwhat c wa wa2 we cit kl6 k618 prin un;
set r2just = @rsq;
title 'recover structural parameters from second stage';
frml ed  d  = lwwhat;
frml ea0 a0 = -c/lwwhat;
frml ea1 a1 = -wa/lwwhat;
frml ea2 a2 = -wa2/lwwhat;
frml ea3 a3 = -we/lwwhat;
frml ea4 a4 = -cit/lwwhat;
frml ea5 a5 = -kl6/lwwhat;
frml ea6 a6 = -k618/lwwhat;
frml ea7 a7 = -prin/lwwhat;
frml ea8 a8 = -un/lwwhat;
analyz ed ea0-ea8;

title 'Method 4: direct nonlinear least squares estimation';
? Note: convergence will be immediate, since both procedures produce
? the same estimates, and the coefficients computed from the reduced
? form are now used as starting values.  It also works with about 10
? iterations from the default starting values, so the reduced form
? above is not really needed.
const g0-g5;  ? hold original wage coefficients fixed
lsq hjust;

title 'Exercise 5, part (d) - over identified estimation';
title 'reduced form';
title 'second stage estimation';
?frml resover  lwr = b0 + b1*wa + b2*wa2 + b3*we +
?                    b4*kl6 + b5*k618 + b6*prin + b7*un;
olsq whrs lwwhat c wa wa2 we kl6 k618 prin un;
frml eb0 b0 = -c/lwwhat;
frml eb1 b1 = -wa/lwwhat;
frml eb2 b2 = -wa2/lwwhat;
frml eb3 b3 = -we/lwwhat;
frml eb4 b4 = -kl6/lwwhat;
frml eb5 b5 = -k618/lwwhat;
frml eb6 b6 = -prin/lwwhat;
frml eb7 b7 = -un/lwwhat;
analyz ed eb0-eb7;
title 'direct nonlinear least squares estimation';
lsq hover;

title 'Exercise 5, part (e) - under identified model';
title 'reduced form - LWWHAT collinear with other variables';
title 'generalized inverse flags last collinear variable';
?frml resunder lwr = c0 + c1*wa + c2*wa2 + c3*we + c4*cit + c5*ax +
?                    c6*kl6 + c7*k618 + c8*prin + c9*un;
olsq whrs lwwhat c wa wa2 we cit ax kl6 k618 prin un;
title 'verify same fit as just-identified';
print @rsq r2just;
title 'change order of variables -- now LWWHAT is flagged';
olsq whrs c wa wa2 we cit ax lwwhat kl6 k618 prin un;
title 'direct nonlinear least squares estimation';
lsq hunder;
