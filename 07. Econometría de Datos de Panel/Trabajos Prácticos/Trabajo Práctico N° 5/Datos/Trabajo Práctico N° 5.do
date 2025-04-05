clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/7. Econometría de Datos de Panel/Trabajos Prácticos/Trabajo Práctico N° 5/Datos"


use "wagepan", clear
describe

xtset nr year
xtdescribe


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


*INCISO (a)*

regress union educ
estimates store est_pols

*INCISO (b)*

probit union educ
margins, dydx(educ)
margins, dydx(educ) atmeans post
estimates store est_pprobit

*INCISO (c)*

logit union educ
margins, dydx(educ)
margins, dydx(educ) atmeans post
estimates store est_plogit

logit union educ
matrix define V=e(V)
summarize educ
local mean_educ=r(mean)
local p=exp(_b[_cons]+_b[educ]*`mean_educ')/(1+exp(_b[_cons]+_b[educ]*`mean_educ'))
matrix define G=[`p'*(1-`p')+_b[educ]*(1-2*`p')*`p'*(1-`p')*`mean_educ',_b[educ]*(1-2*`p')*`p'*(1-`p')]
matrix list G
matrix define V_md=G*V*G'
matrix list V_md
display as text "El error estándar para esta estimación es " as result sqrt(V_md[1,1])

esttab est_pols est_pprobit est_plogit, se star(* 0.10 ** 0.05 *** 0.01) stats(N r2) mtitles("POLS" "PPROBIT" "PLOGIT") keep(educ)

*INCISO (d)*

xtprobit union educ, re
margins, dydx(educ) predict(pu0)
margins, dydx(educ) atmeans predict(pu0) post
estimates store est_reprobit

*INCISO (e)*

xtlogit union educ, re
margins, dydx(educ) predict(pu0)
margins, dydx(educ) atmeans predict(pu0) post
estimates store est_relogit

*INCISO (f)*

xtlogit union educ, fe
margins, dydx(educ) predict(pu0)
margins, dydx(educ) atmeans predict(pu0) post
estimates store est_felogit

esttab est_reprobit est_relogit est_felogit, se star(* 0.10 ** 0.05 *** 0.01) mtitles("REPROBIT" "RELOGIT" "FELOGIT") keep(educ)

*INCISO (g)*

egen mean_married=mean(married), by(nr)
summarize educ if (black==1 & married==1)
local mean_educ=r(mean) 
summarize mean_married if (black==1 & married==1)
local mean_married=r(mean)

probit union educ black married mean_married, vce(cluster nr)
margins, dydx(educ) at(educ=`mean_educ' black=1 married=1 mean_married=`mean_married') post


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


*INCISO (a)*

probit union l.union
display as text "El efecto marginal de estar afiliado a un sindicato en el año t-1 en la probabilidad de estar afiliado a un sindicato en el año t es " as result normal(_b[_cons]+_b[l.union])-normal(_b[_cons])

*INCISO (b)*

probit union l.union d82-d87
forvalues t=82(1)87 {
	local t_1=`t'-1
	display as text "El efecto marginal de estar afiliado a un sindicato en el año 19`t_1' en la probabilidad de estar afiliado a un sindicato en el año 19`t' es " as result normal(_b[_cons]+_b[l.union]+_b[d`t'])-normal(_b[_cons]+_b[d`t'])
}

*INCISO (c)*

generate union80=.
forvalues i=0(1)7 {
    replace union80=union[_n-`i'] if (year==1980+`i')
}

xtprobit union l.union d82-d87 union80, re
generate prob=normal((_b[_cons]+_b[l.union]+_b[d87]+_b[union80]*union80)/sqrt(1+e(sigma_u)^2)) if (year==1987)
summarize prob
display as text "La probabilidad promedio de estar afiliado a un sindicato en el año 1987 dado que estaba afiliado en el período anterior es " as result r(mean)