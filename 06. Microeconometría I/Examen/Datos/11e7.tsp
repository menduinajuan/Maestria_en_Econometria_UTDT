options crt;  ? 11e7
in mroz;   ? contains PRIN, WA2, AX2, and LWW1 if 11e1 has been run

title 'Exercise 7, part (a) - tax variables';
vprin = (1-mtr)*prin;
ltax = log(1-mtr);
ltww = ltax+lww1;

title 'Exercise 7, part (b) - Probit and inverse Mills ratio';
we2 = we*we;
wawe = wa*we;
wa3 = wa2*wa;
we3 = we2*we;
wa2we = wa2*we;
wawe2 = wa*we2;
list seta c kl6 k618 wa we wa2 we2 wawe wa3 we3 wa2we wawe2
          wfed wmed un cit prin;
probit lfp seta;
  invr = @mills;

title 'Exercise 6, part (c) - Heckit 2SLS';
select lfp;
list setb c ltww ltax kl6 k618 wa we prin invr;
2sls(robust,inst=(seta,invr)) whrs setb;

title 'Exercise 6, part (d) - alternative specifications';
title 'add experience variables';
list setax seta ax ax2;
select 1;
probit lfp setax;
  invr = @mills;
select lfp;
2sls(robust,inst=(setax,invr)) whrs setb ax ax2;
