clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/6. Microeconometría I/Trabajos Prácticos/Trabajo Práctico N° 1/Datos"


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


use "insurance", replace
describe

local vars="i.retire age i.hstatusg hhincome educyear i.married i.hisp"

*INCISO (a)*

regress ins `vars'
estimates store est_ols
predict yhat_ols, xb
matrix define betas_ols=e(b)
matrix list betas_ols

logit ins `vars'
estimates store est_logit
predict phat_logit
matrix define betas_logit=e(b)
matrix list betas_logit

probit ins `vars'
estimates store est_probit
predict phat_probit
matrix define betas_probit=e(b)
matrix list betas_probit

esttab est_ols est_logit est_probit, se star(* 0.10 ** 0.05 *** 0.01) r2 pr2 mtitles("OLS" "Logit" "Probit")

*INCISO (d)*

*Manual*

generate yhat_logit=(phat_logit>0.5)
tabulate ins yhat_logit, matcell(aciertos_logit)
display as text "La tasa de aciertos del Logit es de " as result round((aciertos_logit[1,1]+aciertos_logit[2,2])/r(N)*100,0.01)

generate yhat_probit=(phat_probit>0.5)
tabulate ins yhat_probit, matcell(aciertos_probit)
display as text "La tasa de aciertos del Probit es de " as result round((aciertos_probit[1,1]+aciertos_probit[2,2])/r(N)*100,0.01)

*Automáticamente*

logit ins `vars'
estat classification
probit ins `vars'
estat classification

*INCISO (e)*

matrix define prueba_logit=(betas_logit',4*betas_ols')
matrix colnames prueba_logit="Betas Logit" "4 * Betas OLS"
matrix list prueba_logit

matrix define prueba_probit=(betas_probit',2.5*betas_ols')
matrix colnames prueba_probit="Betas Probit" "2,5 * Betas OLS"
matrix list prueba_probit

*INCISO (f)*

regress ins `vars'
margins, atmeans
display as text "La probabilidad esperada que ins= 1 cuando las variables están evaluadas en la media en el modelo OLS es " as result r(b)[1,1]

logit ins `vars'
margins, atmeans
display as text "La probabilidad esperada que ins= 1 cuando las variables están evaluadas en la media en el modelo Logit es " as result r(b)[1,1]

probit ins `vars'
margins, atmeans
display as text "La probabilidad esperada que ins= 1 cuando las variables están evaluadas en la media en el modelo Probit es " as result r(b)[1,1]

*INCISO (g)*

logit ins `vars', or


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


use "mroz", replace
describe

local vars="educ city exper kidslt6 expersq"

*INCISO (a)*

describe
summarize
browse

*INCISO (b)*

generate educ_cent=educ-r(mean)
summarize educ educ_cent

*INCISO (c)*

graph twoway scatter wage educ
graph twoway scatter wage educ, by(inlf)
graph twoway scatter wage educ, by(kidslt6)

*INCISO (d)*

mdesc
duplicates list

*INCISO (e)*

regress inlf `vars'
predict yhat_ols

*INCISO (f)*

regress inlf `vars', robust
estimates store est_ols

*INCISO (g)*

regress inlf `vars', noconst robust

*INCISO (h)*

regress inlf `vars' if (city==1), robust

*INCISO (i)*

logit inlf `vars'
estimates store est_logit

*INCISO (j)*

predict yhat_logit

*INCISO (k)*

lroc

*INCISO (l)*

margins, dydx(*) atmeans

*INCISO (m)*

margins, dydx(*) at(educ=10 city=1 exper=20 kidslt6=3 expersq=400)

*INCISO (n)*

probit inlf `vars'
estimates store est_probit

esttab est_ols est_logit est_probit, se star(* 0.10 ** 0.05 *** 0.01) r2 pr2 mtitles("OLS" "Logit" "Probit")


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


use "Individual_t215", clear
describe

keep if (ch03==1 & ch04==1 & (ch06>=25 & ch06<=65) & (estado==1 | estado==2))

local vars="i.aglomerado ch06 i.ch07"

*INCISO (a)*

generate desempleado=.
replace desempleado=0 if (estado==1)
replace desempleado=1 if (estado==2)

regress desempleado `vars' [w=pondera]
predict yhat_ols
estimates store est_ols

count if (yhat_ols>1)
local obs_mayor_1=r(N)
display as text "La proporción de la muestra que tiene probabilidades predecidas mayores a 1 es " as result `obs_mayor_1'/`=_N'

count if (yhat_ols<0)
local obs_menor_0=r(N)
display as text "La proporción de la muestra que tiene probabilidades predecidas menores a 0 es " as result `obs_menor_0'/`=_N'

*INCISO (b)*

probit desempleado `vars' [w=pondera]
predict yhat_probit
estimates store est_probit

logit desempleado `vars' [w=pondera]
predict yhat_logit
estimates store est_logit

esttab est_ols est_probit est_logit, se star(* 0.10 ** 0.05 *** 0.01) r2 pr2 mtitles("OLS" "Probit" "Logit")

*INCISO (c)*

levelsof aglomerado, local(aglomerados)

probit desempleado `vars' [w=pondera]
margins, at(aglomerado=(`aglomerados') ch06=(25(1)65) ch07=2)
margins, dydx(ch06)
generate em_edad_probit=ch06*r(b)[1,1]
graph twoway scatter yhat_probit em_edad_probit

logit desempleado `vars' [w=pondera]
margins, at(aglomerado=(`aglomerados') ch06=(25(1)65) ch07=2)
margins, dydx(ch06)
generate em_edad_logit=ch06*r(b)[1,1]
graph twoway scatter yhat_logit em_edad_logit