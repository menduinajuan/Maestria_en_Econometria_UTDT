
@==========================================================================@
/*    A GIBBS SAMPLING APPROACH TO AN AR(4) MODEL:
         Y_t = MU + PHI1*Y_{t-1}+PHI2*Y_{t-2}+PHI3*Y_{t-3}+PHI4*Y_{T-4}+e_t
                     e_t -- i.i.d. N(0, sigma^2)

           based on Albert and Chibs'(1993, Journal of Econometrics)
       Subprograms.


*/
@==========================================================================@


     new;
 setvwrmode("many");
     library pgraph;

     format /m1 /rd 14,8;

     format /m1 /rd 9,5;
     load data[195,1]=D:\MCMC_PS8\Ch9\gdp4795.prn;  @Quarter, U.S. real GNP@
                              @1947.1 -- 1995.3 @

     yy=(ln(data[21:195,1])-ln(data[20:194,1]))*100;  @1952.II - 1995.3@
     T1=rows(yy);


     Y=YY[5:T1,1];
     X=ONES(t1-4,1)~YY[4:T1-1,1]~YY[3:T1-2,1]~YY[2:T1-3,1]~YY[1:T1-4,1];
     t=rows(y);



         @================= PARAMETERS FOR PRIOR DISTRIBUTIONS====@

     R0=EYE(5)*4000;
     BETA0=0|0|0|0|0;        @FOR mu,phi1,phi2,phi3,phi4@

     nu0=0;
     d0=0;                    @FOR SIG2_V OF INDIVIDUAL COMPONENT@


         @========INITIAL VALUES FOR THE GIBBS SAMPLER ===========@


       SIG2=0.5;


         @===== DESIGN  FOR THE GIBBS SAMPLER ===========@

       N0 = 500;       @NUMBER OF DRAWS TO LEAVE OUT@
       MM = 1500;       @NUMBER OF DRAWS@

       CAPN = N0 + MM;  @TOTAL NUMBER OF DRAWS@


         @===== STORAGE SPACES===========================@


           SIG2MM = {};
           BETAMM = {};


  ITR=1;
  DO WHILE ITR LE CAPN;      ITR;;"th  iteration.......";


     BETA=GEN_BETA;
     SIG2=GEN_SIG2;

    @==========END OF ONE ITERATION ========================@


    IF ITR>N0;

       SIG2MM = SIG2MM~SIG2;
       BETAMM = BETAMM~BETA;

    ENDIF;

  ITR=ITR+1;
  ENDO;

  FNL_MAT=BETAMM'~SIG2MM';


     @======== calculation of posterior expectations and std deviations@


          INDX = ZEROS(MM,1);
          INDX[1] = 1;
          J = 1;
          DO WHILE J LE MM;
               INDX[J] = 1;
          J = J + 5;
          ENDO;


          SORT_OUT=ZEROS(cols(fnl_mat),3);
          I_NDX=1;
          DO UNTIL I_NDX>COLS(FNL_MAT);

                tmpm1 = selif(FNL_MAT[.,I_NDX],indx);
                MN_OUT = meanc(tmpm1);
                STD_OUT = stdc(tmpm1);
                MED_OUT = median(tmpm1);
                u2out = MN_OUT~STD_OUT~MED_OUT;

        SORT_OUT[I_NDX,.]=U2OUT;

           I_NDX=I_NDX+1;
       ENDO;

OUTPUT FILE=GBS_AR4.OUT RESET;

       "FROM 1st TO --nd ROWS..............";

       "For mu, phi1,phi2,phi3,phi4,sigma^2";
       "===================================";
       "mean, sd, median";
       SORT_OUT;

       OUTPUT OFF;

          

"Sigma sq - SEE GRAPH";      

PlotXY(seqa(1,1,rows(sig2mm')),sig2mm');    
PlotHist(sig2mm',50);
wait;
       
"Mu - SEE GRAPH";      
PlotXY(seqa(1,1,rows(betamm[1,.]')),betamm[1,.]');    
PlotHist(betamm[1,.]',50);
wait;

"phi1 - SEE GRAPH";      
PlotXY(seqa(1,1,rows(betamm[2,.]')),betamm[2,.]');    
PlotHist(betamm[2,.]',50);
/*

title("\201phi1 realizations");
xy(seqa(1,1,rows(betamm[2,.]')),betamm[2,.]');

title("\201phi1 posterior distribution");
{a,b,c}=histp(betamm[2,.]',50);
wait;

*/


END;



     @=============================================================@
     @ GENERATING BETA (MU,PHI1,PHI2,PHI3,PHI4) CONDITIONAL ON SIG2@
     @=============================================================@

PROC GEN_BETA;
     LOCAL V, BETA1, BETA_F, C, ACCEPT, COEF, ROOT, ROOTMOD;

     V = inv(INV(R0) + SIG2^(-1)*X'X);
     BETA1 =  V*(INV(R0)*BETA0 + SIG2^(-1)*X'Y);
     C = chol(V);

     ACCEPT = 0;
     DO WHILE ACCEPT ==0;

          BETA_F = BETA1 + C'rndn(5,1); @GENERATE BETA@

          COEF = -REV(BETA_F[2:5])|1;
          ROOT = POLYROOT(COEF);
          ROOTMOD = ABS(ROOT);

          IF MINC(ROOTMOD) GE 1.0001;
              ACCEPT = 1;
          ELSE;
              ACCEPT = 0;
          ENDIF;

    ENDO;

RETP(BETA_F);
ENDP;


     @===============================================================@
     @ GENERATING SIG2 CONDITIONAL ON BETA (MU,PHI1,PHI2,PHI3,PHI4)  @
     @===============================================================@

PROC GEN_SIG2;
     LOCAL NU1, D1,C,T2,SIG2_F;

     NU1 = t + NU0;
     D1 = D0 + (Y-X*BETA)'(Y-X*BETA);

     c = rndc(NU1);
     t2 = c/D1;
     SIG2_F = 1/t2;

RETP(SIG2_f);
ENDP;



@========================================================================@
@========================================================================@
 /* ADDPROCS.GSI */
 /* compiled file used in Albert and Chib (JBES, 1993, 11,1-15) */
   /* please contact Siddhartha Chib at chib@olin.wustl.edu
            if there are problems*/

proc rndc(a);       /* chisquare */
local x,w;

a = a/2;
w= rg1(a);
x = w * 2;

retp(x);
endp;


proc rndb(a,b);                /* beta */
local x,a1n,a1d;

a1n = rg1(a);
a1d = rg1(b);
x = a1n / (a1n + a1d);

retp(x);
endp;


proc rg1(a);
local x,j,w,u;

if a gt 1;
x = rg2(a);
elseif a lt 1;
a = a + 1;
u = rndu(1,1);
x = rg2(a)*u^(1/a);
elseif a == 1;
x = -ln(rndu(1,1));
endif;

retp(x);
endp;


proc rg2(a);
local gam,accept,b,c,j,x,z,u,v,w,y;

b = a-1;
c = 3*a - .75;
accept = 0;
do while accept == 0;
u = rndu(1,1);
v = rndu(1,1);
w = u*(1-u);
y = sqrt(c/w)*(u-.5);
x = b+y;
if x ge 0;
z = 64*(w^3)*(v^2);
accept = z le ( 1-(2*y^2)/x );
if accept == 0;
accept = ln(z) le 2*(b*ln(x/b) - y);
endif;
endif;
endo;

retp(x);
endp;

