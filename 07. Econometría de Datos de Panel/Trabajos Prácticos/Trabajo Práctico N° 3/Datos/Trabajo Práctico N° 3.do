clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/7. Econometría de Datos de Panel/Trabajos Prácticos/Trabajo Práctico N° 3/Datos"


use "mod_abdata", clear
describe

xtset id year
xtdescribe


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


*INCISO (a)*

regress n nL1
estimates store est_pols

*INCISO (b)*

xtreg n nL1, fe
estimates store est_fe

*INCISO (d)*

ivregress 2sls D.n (D.(nL1)=nL2), noconstant
estimates store est_iv

*INCISO (e)*

xtabond2 n nL1, gmmstyle(L.n) noleveleq
estimates store est_gmm_os1
xtabond2 n nL1, gmmstyle(L.n) twostep noleveleq
estimates store est_gmm_ts1

*INCISO (f)*

xtabond2 n nL1, gmmstyle(L.n)
estimates store est_sgmm_os1
xtabond2 n nL1, gmmstyle(L.n) twostep
estimates store est_sgmm_ts1

*INCISO (g)*

xtabond2 n nL1 yr*, gmmstyle(L.n) iv(yr*) noleveleq
estimates store est_gmm_os2
xtabond2 n nL1 yr*, gmmstyle(L.n) iv(yr*) twostep noleveleq
estimates store est_gmm_ts2
xtabond2 n nL1 yr*, gmmstyle(L.n) iv(yr*, equation(level))
estimates store est_sgmm_os2
xtabond2 n nL1 yr*, gmmstyle(L.n) iv(yr*, equation(level)) twostep
estimates store est_sgmm_ts2

esttab est_pols est_fe est_iv est_gmm_os1 est_gmm_ts1 est_sgmm_os1 est_sgmm_ts1 est_gmm_os2 est_gmm_ts2 est_sgmm_os2 est_sgmm_ts2,										///
						se star(* 0.10 ** 0.05 *** 0.01) stats(N r2)																									///
						mtitles("POLS" "FE" "IV" "GMM (OT) 1" "GMM (TS) 1" "SGMM (OS) 1" "SGMM (TS) 1" "GMM (OT) 2" "GMM (TS) 2" "SGMM (OS) 2" "SGMM (TS) 2")			///
						keep(nL1) rename(D.nL1 nL1 L.n nL1)


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


*INCISO (a)*

regress n nL1 nL2 w wL1 k kL1 kL2 ys ysL1 ysL2 yr*, vce(cluster id)
estimates store est_pols

*INCISO (b)*

xtreg n nL1 nL2 w wL1 k kL1 kL2 ys ysL1 ysL2 yr*, fe vce(cluster id)
estimates store est_fe

*INCISO (c)*

ivregress 2sls D.n (D.nL1=nL2) D.(nL2 w wL1 k kL1 kL2 ys ysL1 ysL2 yr*)
estimates store est_iv

*INCISO (d)*

xtabond2 n L(1/2).n L(0/1).w L(0/2).(k ys) yr*, gmmstyle(L.n) ivstyle(L(0/1).w L(0/2).(k ys) yr*) robust noleveleq
estimates store est_gmm_os1
xtabond2 n L(1/2).n L(0/1).w L(0/2).(k ys) yr*, gmmstyle(L.n) ivstyle(L(0/1).w L(0/2).(k ys) yr*) twostep robust noleveleq
estimates store est_gmm_ts1

*INCISO (e)*

xtabond2 n L(1/2).n L(0/1).w L(0/2).(k ys) yr*, gmmstyle(L.(n w k)) ivstyle(L(0/2).ys yr*) robust noleveleq
estimates store est_gmm_os2
xtabond2 n L(1/2).n L(0/1).w L(0/2).(k ys) yr*, gmmstyle(L.(n w k)) ivstyle(L(0/2).ys yr*) twostep robust noleveleq
estimates store est_gmm_ts2

*INCISO (f)*

xtabond2 n L.n L(0/1).(w k) yr*, gmmstyle(L.(n w k)) ivstyle(yr*, equation(level)) robust
estimates store est_sgmm_os
xtabond2 n L.n L(0/1).(w k) yr*, gmmstyle(L.(n w k)) ivstyle(yr*, equation(level)) twostep robust
estimates store est_sgmm_ts

esttab est_pols est_fe est_iv est_gmm_os1 est_gmm_ts1 est_gmm_os2 est_gmm_ts2 est_sgmm_os est_sgmm_ts,																	  ///
																	se star(* 0.10 ** 0.05 *** 0.01) stats(N r2)														  ///
																	mtitles("POLS" "FE" "IV" "GMM (OT) 1" "GMM (TS) 1" "GMM (OS) 2" "GMM (TS) 2" "SGMM (OS)" "SGMM (TS)") ///
																	keep(nL1) rename(D.nL1 nL1 L.n nL1)

																				 
*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


xtabond2 n L(1/2).n L(0/1).w L(0/2).(k ys) yr*, gmmstyle(L.(n w k), laglimits(1 2)) ivstyle(L(0/2).ys yr*) robust noleveleq
estimates store est_gmm_os3
xtabond2 n L(1/2).n L(0/1).w L(0/2).(k ys) yr*, gmmstyle(L.(n w k), laglimits(1 2)) ivstyle(L(0/2).ys yr*) twostep robust noleveleq
estimates store est_gmm_ts3

xtabond2 n L(1/2).n L(0/1).w L(0/2).(k ys) yr*, gmmstyle(L.(n w k), laglimits(1 3)) ivstyle(L(0/2).ys yr*) robust noleveleq
estimates store est_gmm_os4
xtabond2 n L(1/2).n L(0/1).w L(0/2).(k ys) yr*, gmmstyle(L.(n w k), laglimits(1 3)) ivstyle(L(0/2).ys yr*) twostep robust noleveleq
estimates store est_gmm_ts4

xtabond2 n L(1/2).n L(0/1).w L(0/2).(k ys) yr*, gmmstyle(L.(n w k), collapse) ivstyle(L(0/2).ys yr*) robust noleveleq
estimates store est_gmm_os5
xtabond2 n L(1/2).n L(0/1).w L(0/2).(k ys) yr*, gmmstyle(L.(n w k), collapse) ivstyle(L(0/2).ys yr*) twostep robust noleveleq
estimates store est_gmm_ts5

esttab est_gmm_os2 est_gmm_ts2 est_gmm_os3 est_gmm_ts3 est_gmm_os4 est_gmm_ts4 est_gmm_os5 est_gmm_ts5,																	  ///
													se star(* 0.10 ** 0.05 *** 0.01)																					  ///
													mtitles("GMM (OS) 2" "GMM (TS) 2" "GMM (OS) 3" "GMM (TS) 3" "GMM (OS) 4" "GMM (TS) 4" "GMM (OS) 5" "GMM (TS) 5")	  ///
													keep(nL1) rename(D.nL1 nL1 L.n nL1)


*##############################################################################*
								* EJERCICIO 4 *
*##############################################################################*


xtlsdvc n, initial(ah) bias(2)
estimates store est_lsdvc1
xtlsdvc n yr*, initial(ah) bias(2)
estimates store est_lsdvc2

esttab est_lsdvc1 est_lsdvc2, se star(* 0.10 ** 0.05 *** 0.01) mtitles("LSDVC 1" "LSDVC 2") keep(L.n)

xtlsdvc n, initial(ah) bias(2)

scalar b_lsdvc=e(b)[1,1]
scalar NT=e(N)
scalar T=e(Tbar)
scalar N=e(N_g)
scalar K=colsof(e(b))

egen mean_n=mean(n), by(id)
egen mean_nL1=mean(nL1), by(id)

generate within_n=n-mean_n
generate within_nL1=nL1-mean_nL1
generate u=within_n-b_lsdvc*within_nL1

matrix accum ZtZ=within_nL1, noconstant
matrix list ZtZ
matrix accum utu=u, noconstant
matrix list utu
matrix define s2=utu/(NT-N-T-K+1)
matrix list s2
matrix define V=s2*invsym(ZtZ)
matrix list V

scalar se_lsdvc=sqrt(V[1,1])
scalar tstat=b_lsdvc/se_lsdvc
scalar pvalue=2*ttail(NT-K,abs(tstat))
scalar list b_lsdvc se_lsdvc tstat pvalue

display as text "tstat = " as result tstat
display as text "El P-valor es " as result pvalue