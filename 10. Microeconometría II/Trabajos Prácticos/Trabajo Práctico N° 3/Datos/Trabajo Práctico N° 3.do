clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/10. Microeconometría II/Trabajos Prácticos/Trabajo Práctico N° 3/Datos"


*ssc install diff, replace


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


use "Panel101", clear
describe

*INCISO (a)*

generate Y=y/1000000000
generate time=(year>=1994 & !missing(year))
generate treated=(country>4 & !missing(country))
generate did=time*treated
xtset country year

*INCISO (b)*

regress Y time treated did

*INCISO (c)*

xtreg Y time treated did, fe
xtreg Y time##treated, fe 

*INCISO (d)*

diff Y, period(time) treated(treated)


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


use "CardKrueger1994", clear
describe

*INCISO (c)*

bysort treated: summarize
bysort treated t: summarize fte

diff fte, period(t) treated(treated)

*INCISO (d)*

diff fte, period(t) treated(treated) bs

*INCISO (e)*

diff fte, period(t) treated(treated) cov(bk kfc roys) report
diff fte, period(t) treated(treated) cov(bk kfc roys) bs report


*##############################################################################*
								* EJERCICIO 4 *
*##############################################################################*


use "hospdd", clear
describe

*INCISO (c)*

summarize
tabulate procedure
tabulate month procedure
tabulate hospital procedure

bysort hospital: egen treated=max(procedure)
generate post=(month>=4 & !missing(procedure))

tabulate treated
tabulate proc treated

didregress (satis i.treated i.post) (procedure), group(hospital) time(month)

*INCISO (e)*

didregress (satis i.treated i.post) (procedure), group(hospital) time(month) vce(robust)
didregress (satis i.treated i.post) (procedure), group(hospital) time(month) vce(hc2)
didregress (satis i.treated i.post) (procedure), group(hospital) time(month) vce(bootstrap)