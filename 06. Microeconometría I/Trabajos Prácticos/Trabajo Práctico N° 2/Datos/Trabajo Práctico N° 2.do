clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/6. Microeconometría I/Trabajos Prácticos/Trabajo Práctico N° 2/Datos"


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


use "BWGHT", clear
describe

local vars="motheduc white lfaminc"

*INCISO (a)*

tabulate cigs
generate smokes=(cigs>0)
tabulate smokes

probit smokes `vars'
margins, at(white==0 motheduc==12 motheduc==16) atmeans
display as text "La diferencia estimada en la probabilidad de fumar para una mujer con 16 años de educación y una con 12 años de educación es " as result r(b)[1,2]-r(b)[1,1]

*INCISO (c)*

regress lfaminc motheduc white fatheduc
predict v2hat, residuals

*INCISO (d)*

probit smokes `vars' v2hat
test v2hat

probit smokes `vars' if (v2hat!=.)
estimates store probit

ivprobit smokes motheduc white (lfaminc=fatheduc)
estimates store ivprobit

esttab probit ivprobit, se star(* 0.10 ** 0.05 *** 0.01) pr2 mtitles("Probit" "IV Probit")


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


use "pricedata", clear
describe

local varsX="Gender WealthIndex i.AgeCategory i.LaborCategory i.v0024 i.CompleteEduc Student MonthlyIncome MaritalStatus"
local varsZ="Gender WealthIndex i.AgeCategory i.LaborCategory i.v0024"

*INCISO (b)*

*Alternativa 1*

svy: regress LogPricePack `varsX'
predict LogPricePack_hat0
predict resid0, residuals
summarize resid0
generate random=rnormal(r(mean),r(sd))
generate LogPricePack_hat1=LogPricePack
replace LogPricePack_hat1=LogPricePack_hat0+random if (LogPricePack==.)

regress LogPricePack_hat1 `varsX'
predict resid1, residuals

svy: probit SmokeCigs `varsZ' LogPricePack_hat1 resid1
test resid1

*Alternativa 2*

svy: regress LogPricePack i.UPA_PNS
predict LogPricePack_hat2

regress LogPricePack_hat2 `varsX'
predict resid2, residuals

svy: probit SmokeCigs `varsZ' LogPricePack_hat2 resid2
test resid2

*INCISO (c)*

*Alternativa 1*

ivprobit SmokeCigs `varsZ' (LogPricePack_hat1 = i.CompleteEduc Student MonthlyIncome MaritalStatus)
predict xb1, xb
generate elast1=_b[LogPricePack_hat1]*normal(xb1)/normalden(xb1)
svy: mean elast1

*Alternativa 2*

ivprobit SmokeCigs `varsZ' (LogPricePack_hat2 = i.CompleteEduc Student MonthlyIncome MaritalStatus)
predict xb2, xb
generate elast2=_b[LogPricePack_hat2]*normal(xb2)/normalden(xb2)
svy: mean elast2


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


clear all
set obs 1000
set seed 12345

generate x=runiform(-1,1)
generate xhet=runiform()
generate sigma=exp(1.5*xhet)
generate p=normal((0.3+2*x)/sigma)
generate y=cond(p>=runiform(),1,0)

hetprobit y x, het(xhet)
estimates store hetprobit
test x==2

probit y x
estimates store probit
test x==2

esttab hetprobit probit, se star(* 0.10 ** 0.05 *** 0.01) pr2 mtitles("Probit Heterocedástico" "Probit")