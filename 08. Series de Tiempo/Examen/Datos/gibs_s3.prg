/* Written by Chang-Jin Kim  cjkim@korea.ac.kr 
                             changjin@u.washington.edu  */

new;
library pgraph;


OUTPUT FILE=gibs_ew.OUT RESET;  output off;

seed=198011;
rndns(1,1,seed);
RNDUS(1,1,SEED);

format /m1 /rd 8,4;

load xxx[732,4] = D:\Descargas\MCMC_PS8\MCMC_PS8\Ch9\crspd.prn;
 yyy = xxx[.,3];  @ table 1 of KNS equal-weighted excess return
               (including dividend)@
/* yyy = xxx[.,4];  @ table 1 of KNS value-weighted excess return @ */


yy0 = ln(1+yyy);
t=rows(yy0);

yy=yy0-meanc(yy0);

         @=================  PRIOR PARAMETERS ====================@

     U1_1=1; U1_23=1;  U1_2_23=1;   U1_3_23=1;
     U2_13=1; U2_2=1;  U2_1_13=1;   U2_3_13=1;   @FOR TRAN. PROB.@
     U3_3=1; U3_12=1;  U3_2_12=1;   U3_1_12=1;


     R0_M=EYE(1)/2500;        @For MU@
     T0_M=0;

     V1_=0; V11_=0;
     V2_=0; V22_=0;        @FOR SIG^2, 1+H2, 1+H3@
     V3_=0; V33_=0;



         @========INITIAL VALUES FOR THE GIBBS SAMPLER ===========@

       P1_1TT=0.9  ;  P1_2TT=0.05 ;  P2_1TT=0.05 ; P2_2TT=0.9 ;
       P3_1TT=0.1  ;  P3_2TT=0.1 ;
       MUTT=0;
       SIG1TT=0.001 ; H2TT=0.9    ; H3TT=2.5 ;
       SIG2TT=SIG1TT*(1+H2TT);  SIG3TT=SIG2TT*(1+H3TT);

       P1_3TT=1-P1_1TT-P1_2TT;
       P2_3TT=1-P2_1TT-P2_2TT;
       P3_3TT=1-P3_1TT-P3_2TT;

           @===== DESIGN  FOR THE GIBBS SAMPLER ===========@

       N0 = 100;       @NUMBER OF DRAWS TO LEAVE OUT@
       MM = 1000;       @NUMBER OF DRAWS@
       LL = 5;          @EVERY L-TH VALUE IS USED@

       CAPN = N0 + MM;  @TOTAL NUMBER OF DRAWS@


           @===== STORAGE SPACES===========================@

           SIG1MM = {};   SIG2MM = {};  SIG3MM = {};
          @ MUMM = {};@       @ The data is de meaned so this should not be there@
           P1_1MM = {};  P1_2MM={};  P2_1MM={}; P2_2MM={};
           P3_1MM={}; P3_2MM={};

           S1TTMM=ZEROS(T,1);
           S2TTMM=ZEROS(T,1);
           S3TTMM=ZEROS(T,1);
           sigmatt=zeros(t,1);
           sigmamm=zeros(t,1);
           stetmm=zeros(t,1);
           stettt=zeros(t,1);

  ITR=1;
  DO WHILE ITR LE CAPN;      ITR-n0;;"th  iteration.......";

           @=================START SAMPLING================@

     {STT,S1TT,S2TT,S3TT} = GEN_ST;


    @ MUTT=0;@


     SIG1TT= GEN_SS;
     H2TT=GEN_H2;
     H3TT=GEN_H3;


     SIG2TT=SIG1TT*(1+H2TT);
     SIG3TT=SIG1TT*(1+H2TT)*(1+H3TT);
     sigmatt=(s1tt*sig1tt)+ (s2tt*sig2tt) + (s3tt*sig3tt);

     locate 9,1;
     TRANMAT = SWITCHG(STT,1|2|3);
     "TRANMAT";;TRANMAT;
     P1_1TT;;P1_2TT;;P2_1TT;;P2_2TT;;P3_1TT;;P3_2TT;
     SIG1TT;;SIG2TT;;SIG3TT;
     H2TT;;H3TT;
     @MUTT;@   



     P1_1TT=RNDB(TRANMAT[1,1]+U1_1, TRANMAT[1,2]+TRANMAT[1,3]+U1_23);
     P1_2TT=RNDB(TRANMAT[1,2]+U1_2_23,TRANMAT[1,3]+U1_3_23)*(1-P1_1TT);
     P1_3TT=1-P1_1TT-P1_2TT;

     P2_2TT=RNDB(TRANMAT[2,2]+U2_2,TRANMAT[2,1]+TRANMAT[2,3]+U2_13);
     P2_1TT=RNDB(TRANMAT[2,1]+U2_1_13,TRANMAT[2,3]+U2_3_13)*(1-P2_2TT);
     P2_3TT=1-P2_1TT-P2_2TT;

     P3_3TT=RNDB(TRANMAT[3,3]+U3_3, TRANMAT[3,2]+TRANMAT[3,1]+U3_12);
     P3_2TT=RNDB(TRANMAT[3,2]+U3_2_12,TRANMAT[3,1]+U3_1_12)*(1-P3_3TT);
     P3_1TT=1-P3_2TT-P3_3TT;


          /*       A1TT = rndb(tranmat[1,2]+u1_01_,tranmat[1,1]+u1_00_);
                   B1TT = rndb(tranmat[2,1]+u1_10_,tranmat[2,2]+u1_11_); */



           @==========END OF ONE ITERATION ========================@



       SIG1MM = SIG1MM~SIG1TT;
       SIG2MM = SIG2MM~SIG2TT;
       SIG3MM = SIG3MM~SIG3TT;

       @MUMM = MUMM~MUTT;@
       P1_1MM=P1_1MM~P1_1TT;P1_2MM=P1_2MM~P1_2TT;P2_1MM=P2_1MM~P2_1TT;
       P2_2MM=P2_2MM~P2_2TT;P3_1MM=P3_1MM~P3_1TT;P3_2MM=P3_2MM~P3_2TT;

       IF ITR>N0;

       S1TTMM=S1TTMM+S1TT;S2TTMM=S2TTMM+S2TT;S3TTMM=S3TTMM+S3TT;
       sigmamm=sigmamm+sigmatt;
       stetmm=stetmm+ (yy-mutt)./sqrt(sigmatt);
       ENDIF;

  ITR=ITR+1;
  ENDO;

       S1TTMM=S1TTMM/MM;S2TTMM=S2TTMM/MM;S3TTMM=S3TTMM/MM;
       sigmamm=sigmamm/mm;
       stetmm=stetmm/mm;
       save sigmamm,stetmm;


       output file=rtrn_o_s.prn reset;
	   "DATA, Variance, Standardized return"; 
	   yy0~sigmamm~stetmm; 
	   output off;
       
	   output file=gibs_s3.dta reset;
	   "S1T S2T S3T SigmaT stdret data";
	   s1ttmm~s2ttmm~s3ttmm~sigmamm~stetmm~yy0; 
	   output off;

      FNL_MAT=P1_1MM'~P1_2MM'~P2_1MM'~P2_2MM'~P3_1MM'~P3_2MM'~SIG1MM'~SIG2MM'~SIG3MM';   @~MUMM';@



        save fnl_mat;





     @======== calculation of posterior expectations and std deviations@

          fnl_mat=fnl_mat[n0+1:rows(fnl_mat),.];

          INDX = ZEROS(MM,1);
          INDX[1] = 1;
          J = 1;
          DO WHILE J LE MM;
               INDX[J] = 1;
          J = J + LL;
          ENDO;


          SORT_OUT=ZEROS(cols(fnl_mat),9);
          I_NDX=1;
          DO UNTIL I_NDX>COLS(FNL_MAT);

                tmpm1 = selif(FNL_MAT[.,I_NDX],indx);
                tmpm1=sortc(tmpm1,1);
                MN_OUT = meanc(tmpm1);
                STD_OUT = stdc(tmpm1);
                MED_OUT = median(tmpm1);
                u2out = MN_OUT~STD_OUT~MED_OUT~
                tmpm1[ceil(0.025*rows(tmpm1)),1]~
                tmpm1[ceil(0.05*rows(tmpm1)),1]~
                tmpm1[ceil(0.10*rows(tmpm1)),1]~
                tmpm1[ceil(0.90*rows(tmpm1)),1]~
                tmpm1[ceil(0.95*rows(tmpm1)),1]~
                tmpm1[ceil(0.975*rows(tmpm1)),1];


        SORT_OUT[I_NDX,.]=U2OUT;

           I_NDX=I_NDX+1;
       ENDO;



format /m1 /rd 6,4;

pa1="P1_1MM";
pa2="P1_2MM";
pa3="P2_1MM";
pa4="P2_2MM";
pa5="P3_1MM";
pa6="P3_2MM";
pa7="SIG1MM";
pa8="SIG2MM";
pa9="SIG3MM";  

paa = pa1$|pa2$|pa3$|pa4$|pa5$|pa6$|pa7$|pa8$|pa9;


"Mean STD MED  0.025  0.05 0.10  0.90 0.95 0.975";
                
paa;;SORT_OUT;


begwind;
window(2,1,0);
setwind(1);
_ptitlht=.28;
_pltype ={1,2,6};
_pframe = 0;
_pnumht = 0.15;
_plegctl={4,4,1.9,1.8};
_plegstr= "\201P(S1]t[|I]t[)\0"\
                 "\201P(S2]t[|I]t[)\0"\
                 "\"\201P(S3]t[|I]t[)";   
title("Filtered Probabilities");
xlabel("");

plotxy(seqa(1,1,rows(s1ttmm)),s1ttmm~s2ttmm~s3ttmm);

nextwind;
_pltype ={6,1};
_pframe = 0;
_pnumht = 0.15;
_plegctl={4,4,1.9,1.8};
_plegstr= "\201Volatility\0"\
                 "\"\201Returns";   
title("Volatility and Returns");
plotxy(seqa(1,1,rows(s1ttmm)),sigmamm~(0.1*yy0));

endwind;

END;



@=========================================================================@
@====PROCEDURE THAT GENERATES ST==========================================@
@=========================================================================@

PROC (4) = GEN_ST;

local  flt_pr,prmtr,sv1,sv2,sv3,mu,pr_tr,a,en,steady,pr_tr1,sv_m,ss,
       j_iter,prob__,f_cast,pr_vl,pr_val,pro_,s_t,s_t___,s_tmp,p1,p2,p3,
       tstar,s_tmp1;



    TSTAR=T;
    FLT_PR=ZEROS(3,TSTAR);
    PRMTR=P1_1TT|P1_2TT|P2_1TT|P2_2TT|P3_1TT|P3_2TT|
          SIG1TT|SIG2TT|SIG3TT|MUTT;

       SV1=PRMTR[7,1];
       SV2=PRMTR[8,1];
       SV3=PRMTR[9,1];

       MU=PRMTR[10,1];

@>>>>>>>>>>>>>>>>>>>>>>>>>  INITIAL PROB. Pr[S0/Y0] @

       PR_TR=(PRMTR[1:2]|1-SUMC(PRMTR[1:2]))~
             (PRMTR[3:4]|1-SUMC(PRMTR[3:4]))~
             (PRMTR[5:6]|1-SUMC(PRMTR[5:6]));

  
       A = (eye(3)-pr_tr)|ones(1,3);

       EN=(0|0|0|1);

       STEADY = INV(A'A)*A'EN;


       PR_TR1=VEC(PR_TR);

       SV_M=(SV1|SV2|SV3);
       SS=SV_M|SV_M|SV_M;



  J_ITER = 1;
  DO UNTIL J_ITER>T;


     PROB__=VECR(STEADY~STEADY~STEADY);

     F_CAST=(YY[J_ITER,.]-MU)*ONES(9,1);

     PR_VL=V_PROB(F_CAST,SS).*PR_TR1.*PROB__;

     PR_VAL=SUMC(PR_VL);
     PRO_=PR_VL/PR_VAL;    @Pr[S1t,S2t,S1tl,S2tl|Y_t-1]@

     STEADY = PRO_[1:3]+PRO_[4:6]+PRO_[7:9];

     FLT_PR[.,J_ITER]=STEADY;  @Pr[St|Yt], 2x1@

  J_ITER = J_ITER+1;
  ENDO;



      @==========GENERATE S_T BASED ON CARTER & KOHN (1994)===========@

      S_T=ZEROS(TSTAR,1);
      S_T___=ZEROS(TSTAR,3);

      S_TMP=BINGEN(FLT_PR[1,TSTAR],FLT_PR[2,TSTAR]+FLT_PR[3,TSTAR],1);

      IF S_TMP==0;
         S_T[TSTAR,1]=1;
      ELSE;
         S_TMP1=BINGEN(FLT_PR[2,TSTAR],FLT_PR[3,TSTAR],1);
         IF S_TMP1==0; S_T[TSTAR,1]=2;
         ELSE;       S_T[TSTAR,1]=3;
         ENDIF;
      ENDIF;

      S_T___[TSTAR,S_T[TSTAR,1]]=1;



     J_ITER=TSTAR-1;
     DO UNTIL J_ITER<1;

       IF S_T[J_ITER+1,1]==1;
         P1=P1_1TT*FLT_PR[1,J_ITER];
         P2=P2_1TT*FLT_PR[2,J_ITER];
         P3=P3_1TT*FLT_PR[3,J_ITER];

       ELSEIF S_T[J_ITER+1,1]==2;
         P1=P1_2TT*FLT_PR[1,J_ITER];
         P2=P2_2TT*FLT_PR[2,J_ITER];
         P3=P3_2TT*FLT_PR[3,J_ITER];

       ELSEIF S_T[J_ITER+1,1]==3;
         P1=P1_3TT*FLT_PR[1,J_ITER];
         P2=P2_3TT*FLT_PR[2,J_ITER];
         P3=P3_3TT*FLT_PR[3,J_ITER];
       ENDIF;

        S_TMP=BINGEN(P1,P2+P3,1);
           IF S_TMP==0; S_T[J_ITER,1]=1;
           ELSE;
              S_TMP1=BINGEN(P2,P3,1);
              IF S_TMP1==0; S_T[J_ITER,1]=2;
              ELSE;        S_T[J_ITER,1]=3;
              ENDIF;
          ENDIF;

           S_T___[J_ITER,S_T[J_ITER,1]]=1;

      J_ITER=J_ITER-1;
      ENDO;


   RETP(S_T,S_T___[.,1],S_T___[.,2],S_T___[.,3]);
   ENDP;

@========================PROC THAT GENERATES SIG1TT====================@
PROC GEN_SS;
local nn,yst,xst,d,c,t2,sigma2,e_mat,n_1;


     e_mat=(YY-MUTT)./ SQRT(1+S2TT*H2TT)./SQRT((1+S3TT*H2TT).*(1+S3TT*H3TT));

@E_MAT=SELIF(E_MAT,S1TT);@

     n_1=rows(e_mat);

     nn = n_1 + v1_;
     d = v11_ + e_mat'e_mat;

     c = rndc(nn);
     t2 = c/d;
     sigma2 = 1/t2;

retp(sigma2);
endp;


@========================PROC THAT GENERATES H2====================@
PROC GEN_H2;
local nn,yst,xst,d,c,t2,sigma2,accept,n_1,ehat,jj;

     ehat=(YY-MUTT)./sqrt(SIG1TT)./sqrt(1+S3TT*H3TT);
     ehat=selif(ehat,S2TT+S3TT);

     n_1=rows(ehat);
     nn = n_1 + V2_;
     d = V22_ + (ehat)'(ehat);

     accept=0;jj=1;
     do while accept ==0;

         c = rndc(nn);
         t2 = c/d;
         sigma2 = 1/t2;

         if sigma2 gt 1 and sigma2 lt 4;
             accept = 1;
         endif;
     if jj>100; sigma2=1.01; accept=1;endif;
     jj=jj+1;
     endo;

retp(sigma2-1);
endp;


@========================PROC THAT GENERATES H3====================@
PROC GEN_H3;
local nn,yst,xst,d,c,t2,sigma2,accept,n_1,ehat,jj;

     ehat=(YY-MUTT)./sqrt(SIG1TT*(1+S3TT*H2TT));
     ehat=selif(ehat,S3TT);

     n_1=rows(ehat);
     nn = n_1 + V3_;
     d = V33_ + (ehat)'(ehat);

     accept=0;jj=1;
     do while accept ==0 ;

         c = rndc(nn);
         t2 = c/d;
         sigma2 = 1/t2;

         if sigma2 gt 1;
             accept = 1;
         endif;
     if jj>100; sigma2=1.01; accept=1;endif;
     jj=jj+1;
     endo;

retp(sigma2-1);
endp;

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


@================================================@


proc pdfn1(yt,m,s2);
local z,p;
z = (yt - m)/sqrt(s2);
p = pdfn(z)/sqrt(s2);
retp(p);
endp;
trace 0;

PROC BINGEN(P0,P1,M);
local pr0,s,u;

pr0 = p0/(p0+p1);       /* prob(s=0) */
u = rndu(m,1);
s = u .ge pr0;

retp(s);
endp;

proc markov(a,b,ss0,n);
local s,u,i ;

s = zeros(n,1);
s[1,1] = ss0;

i = 2;
 do while i le n;

if s[i-1,1] == 0;
u = rndu(1,1);

if u le a ;
s[i,1] = 1;
else;
s[i,1] = 0;
endif;

elseif s[i-1,1] == 1;
u = rndu(1,1);

if u le (1-b) ;
s[i,1] = 1;
else;
s[i,1] = 0;
endif;

endif;

i = i + 1;
endo;
retp(s);
endp;

proc switchg(s,g);
local n,m,switch,t,st1,st;

     n = rows(s);
     m = rows(g);
     switch = zeros(m,m);     /* to store the transitions */

     t = 2;
     do while t le n;

     st1 = s[t-1];
     st = s[t];
     switch[st1,st] = switch[st1,st] + 1;
     t = t+ 1;
     endo;

     retp(switch);
     endp;

@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@

PROC V_PROB(EV, HE);      @ CALCULATES    Pr[Yt/St,Yt-1]@
LOCAL VAL;
VAL=(1./SQRT(2*PI*HE)).*EXP(-0.5*EV.*EV./HE);
RETP(VAL);
ENDP;

