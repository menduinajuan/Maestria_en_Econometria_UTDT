options crt;  ? 11e6
in mroz;   ? contains PRIN, WA2, AX2, and LWW1 if 11e1 has been run

title 'Exercise 6, part (a) - Probit and inverse Mills ratio';
we2 = we*we;
wawe = wa*we;
wa3 = wa2*wa;
we3 = we2*we;
wa2we = wa2*we;
wawe2 = wa*we2;
list seta c kl6 k618 wa we wa2 we2 wawe wa3 we3 wa2we wawe2
          wfed wmed un cit prin;
probit lfp seta;
  invr1 = @mills;
list setax seta ax ax2;
probit lfp setax;
  invr2 = @mills;

title 'Exercise 6, part (b) - Heckit';
select lfp;
olsq(robust) lww1 seta;
olsq(robust) lww1 setax;
olsq(robust) lww1 seta invr1;
olsq(robust) lww1 setax invr2;

title 'optional - Direct ML estimation for sample selectivity';
?  Note:  using the same set of RHS variables in both equations
?  means the model is identified only by the nonlinearity in the
?  inverse Mills function.
select 1;
sampsel(hcov=wn,maxit=400) lfp seta | lww1 seta;
sampsel(hcov=wn,maxit=100) lfp setax | lww1 setax;

title 'Exercise 6, part (c) - 2SLS';
select lfp;
list setb c kl6 k618 wa we lww1 prin;
2sls(robust,inst=seta) whrs setb;
2sls(robust,inst=(seta,invr1)) whrs setb invr1;
2sls(robust,inst=setax) whrs setb;
2sls(robust,inst=(setax,invr2)) whrs setb invr2;

title 'Exercise 6, part (e) - Olsen linear probability model';
? This does not work very well when run as described in the book,
? because phatm1 is collinear with the other RHS variables.
? In Heckit, invr1 and invr2 are not collinear with the other RHS
? variables because the inverse Mills ratio is a nonlinear function.
title 'without Experience variables';
select 1;
olsq(silent) lfp seta;
select lfp;
phatm1 = @fit-1;
olsq whrs seta phatm1;
title 'with Experience variables';
select 1;
olsq(silent) lfp setax;
select lfp;
phatm1 = @fit-1;
olsq whrs setax phatm1;
