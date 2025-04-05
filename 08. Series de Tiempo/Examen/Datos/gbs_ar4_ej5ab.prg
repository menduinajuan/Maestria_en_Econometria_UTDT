@================================================================================@
/*
Una aproximación de Gibbs Sampling a un modelo con 3 regresores:
log(m_t) - log(p_t) = alpha_0 + alpha_1 * i_t + alpha_2 * log(y_t) + e_t
e_t -- i.i.d. N(0, sigma^2)
basado en Albert and Chibs (1993, Journal of Econometrics)
*/
@================================================================================@


@@@@@ SETEO @@@@@


new;
setvwrmode("many");
library pgraph;
format /m1 /rd 14,8;


@@@@@ SEMILLA @@@@@


rndseed(12345);


@@@@@ CARGA DE DATOS @@@@@


load data[213,13] = C:\datos_modify.dat;


@@@@@ DEFINICIÓN DE VARIABLES @@@@@


@ Para toda la muestra (1962q1-2014q4) @
dif_log_m_p = data[2:213,5];
i = data[2:213,9];
log_y = data[2:213,8];

@ Para la submuestra (1962q1-1979q3) @
/*
dif_log_m_p = data[2:72,5];
i = data[2:72,9];
log_y = data[2:72,8];
*/

@ Para la submuestra (1982q4-2014q4) @
/*
dif_log_m_p = data[85:213,5];
i = data[85:213,9];
log_y = data[85:213,8];
*/


@@@@@ MATRIZ DE DISEÑO @@@@@


T = rows(dif_log_m_p);
Y = dif_log_m_p;
X = ONES(T,1)~i~log_y;


@@@@@ PARÁMETROS PARA DISTRIBUCIONES A PRIORI @@@@@


R0 = EYE(3) * 4000;
BETA0 = 0 | 0 | 0;                          @ Para alpha_0, alpha_1 y alpha_2 @
nu0 = 0;
d0 = 0;                                     @ Para sig2_v del componente individual @


@@@@@ VALORES INICIALES PARA EL GIBBS SAMPLER @@@@@


SIG2 = 0.5;


@@@@@ DISEÑO PARA EL GIBBS SAMPLER @@@@@


N0 = 500;                                   @ Número de muestras a descartar @
MM = 1500;                                  @ Número de muestras @
CAPN = N0 + MM;                             @ Número total de muestras @


@@@@@ ESPACIOS DE ALMACENAMIENTO @@@@@


SIG2MM = {};
BETAMM = {};

ITR = 1;
DO WHILE ITR <= CAPN;
    ITR;;"th iteration .....";
    BETA = GEN_BETA;
    SIG2 = GEN_SIG2;
    IF ITR > N0;
        SIG2MM = SIG2MM~SIG2;
        BETAMM = BETAMM~BETA;
    ENDIF;
    ITR = ITR + 1;
ENDO;

FNL_MAT = BETAMM'~SIG2MM';


@@@@@ CÁLCULO DE LAS EXPECTATIVAS A POSTERIORI Y DESVIACIONES ESTÁNDAR @@@@@


INDX = ZEROS(MM,1);
INDX[1] = 1;
J = 1;
DO WHILE J <= MM;
    INDX[J] = 1;
    J = J + 5;
ENDO;

SORT_OUT = ZEROS(cols(fnl_mat),3);
I_NDX = 1;
DO UNTIL I_NDX > COLS(FNL_MAT);
    tmpm1 = selif(FNL_MAT[.,I_NDX],indx);
    MN_OUT = meanc(tmpm1);
    MED_OUT = median(tmpm1);
    STD_OUT = stdc(tmpm1);
    u2out = MN_OUT~MED_OUT~STD_OUT;
    SORT_OUT[I_NDX,.] = U2OUT;
    I_NDX = I_NDX + 1;
ENDO;


@@@@@ GRÁFICOS @@@@@


"Para alpha_0, alpha_1, alpha_2, sig2";
"mean, median, sd";

SORT_OUT;

"sig^2 - VER GRÁFICOS";
PlotXY(seqa(1,1,rows(sig2mm')),sig2mm');
wait;
PlotHist(sig2mm',50);
wait;

"alpha_0 - VER GRÁFICOS";
PlotXY(seqa(1,1,rows(betamm[1,.]')),betamm[1,.]');
wait;
PlotHist(betamm[1,.]',50);
wait;

"alpha_1 - VER GRÁFICOS";
PlotXY(seqa(1,1,rows(betamm[2,.]')),betamm[2,.]');
wait;
PlotHist(betamm[2,.]',50);
wait;

"alpha_2 - VER GRÁFICOS";
PlotXY(seqa(1,1,rows(betamm[3,.]')),betamm[3,.]');
wait;
PlotHist(betamm[3,.]',50);
wait;

END;


@ GENERACIÓN DE BETA (alpha_0, alpha_1, alpha_2) CONDICIONAL EN SIG2 @


PROC GEN_BETA;
     LOCAL V, BETA1, BETA_F, C;
     V = inv(INV(R0) + SIG2^(-1) * X'X);
     BETA1 = V * (INV(R0) * BETA0 + SIG2^(-1) * X'Y);
     C = chol(V);
     BETA_F = BETA1 + C'rndn(3,1);
RETP(BETA_F);
ENDP;


@@@@@ GENERACIÓN DE SIG2 CONDICIONAL EN BETA (alpha_0, alpha_1, alpha_2) @@@@@


PROC GEN_SIG2;
     LOCAL NU1, D1, C, T2, SIG2_F;
     NU1 = T + NU0;
     D1 = D0 + (Y - X * BETA)' (Y - X * BETA);
     c = rndc(NU1);
     t2 = c / D1;
     SIG2_F = 1 / t2;
RETP(SIG2_F);
ENDP;


@@@@@ ADDPROCS.GSI @@@@@


proc rndc(a);
local x, w;

a = a / 2;
w = rg1(a);
x = w * 2;

retp(x);
endp;

proc rndb(a, b);
local x, a1n, a1d;

a1n = rg1(a);
a1d = rg1(b);
x = a1n / (a1n + a1d);

retp(x);
endp;

proc rg1(a);
local x, j, w, u;

if a > 1;
x = rg2(a);
elseif a < 1;
a = a + 1;
u = rndu(1,1);
x = rg2(a) * u^(1/a);
elseif a == 1;
x = -ln(rndu(1,1));
endif;

retp(x);
endp;

proc rg2(a);
local gam, accept, b, c, j, x, z, u, v, w, y;

b = a - 1;
c = 3 * a - 0.75;
accept = 0;
do while accept == 0;
u = rndu(1,1);
v = rndu(1,1);
w = u * (1 - u);
y = sqrt(c / w) * (u - 0.5);
x = b + y;
if x >= 0;
z = 64 * (w^3) * (v^2);
accept = z <= (1 - (2 * y^2) / x);
if accept == 0;
accept = ln(z) <= 2 * (b * ln(x / b) - y);
endif;
endif;
endo;

retp(x);
endp;
