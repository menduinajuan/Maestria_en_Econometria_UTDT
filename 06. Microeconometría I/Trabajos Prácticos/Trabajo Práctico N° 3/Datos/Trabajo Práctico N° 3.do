clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/6. Microeconometría I/Trabajos Prácticos/Trabajo Práctico N° 3/Datos"


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


*INCISO (a)*

use "fishingchoice", clear
describe

summarize
tabulate mode
version 16: table mode, contents(N income mean income sd income)
version 16: table mode, contents(mean pbeach mean ppier mean pprivate mean pcharter)
version 16: table mode, contents(mean qbeach mean qpier mean qprivate mean qcharter)

*INCISO (b)*

mlogit mode income, baseoutcome(1)
mlogit mode income, baseoutcome(1) rrr
test income
estimates store mlogit
predict pr_mlogit1 pr_mlogit2 pr_mlogit3 pr_mlogit4, pr
summarize pr_mlogit* dbeach dpier dprivate dcharter, separator(4)
mfx, predict(pr outcome(1))
mfx, predict(pr outcome(2))
mfx, predict(pr outcome(3))
mfx, predict(pr outcome(4))

*INCISO (c)*

generate id=_n
reshape long d p q, i(id) j(fishmode beach pier private charter)

asclogit d p q, case(id) alternatives(fishmode) casevars(income) basealternative(beach)
estimates store clogit1
predict pr_clogit1, pr
version 16: table fishmode, contents(mean d mean pr_clogit1 sd pr_clogit1)

asclogit d, case(id) alternatives(fishmode) casevars(income) basealternative(beach)
estimates store clogit2
predict pr_clogit2, pr
version 16: table fishmode, contents(mean d mean pr_clogit2 sd pr_clogit2)


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


*INCISO (a)*

use "NPS", clear
describe
set seed 12345

duplicates list
mdesc
summarize
keep if (nps!=.)

local vars="i.gender_code edad i.segmento"

*INCISO (b)*

generate clasificacion=.
replace clasificacion=1 if (nps<=6)
replace clasificacion=2 if (nps>=7 & nps<=8)
replace clasificacion=3 if (nps>=9)

label define clasificacion 1 "Detractor" 2 "Neutral" 3 "Promotor"
label values clasificacion clasificacion

tabulate clasificacion

*INCISO (c)*

sort clasificacion espera
by clasificacion: summarize espera
graph box espera, over(clasificacion)

*INCISO (d)*

sample 10
xi: mlogit clasificacion `vars' espera, baseoutcome(1)
xi: mlogit clasificacion `vars' espera, rrr baseoutcome(1)
estimates store mlogit
predict pr_mlogit1 pr_mlogit2 pr_mlogit3, pr

*INCISO (e)*

mfx, predict(pr outcome(1))
mfx, predict(pr outcome(2))
mfx, predict(pr outcome(3))

*INCISO (f)*

xi: mprobit clasificacion `vars' espera, baseoutcome(1)
estimates store mprobit
predict pr_mprobit1 pr_mprobit2 pr_mprobit3, pr

mfx, predict(pr outcome(1))
mfx, predict(pr outcome(2))
mfx, predict(pr outcome(3))

*INCISO (g)*

xi: mlogit clasificacion `vars' espera, baseoutcome(1)
test _Igender_co_2 edad _Isegmento_2 _Isegmento_3 _Isegmento_4 _Isegmento_5 espera
test _Igender_co_2
test edad
test _Isegmento_2
test _Isegmento_3
test _Isegmento_4
test _Isegmento_5
test espera

xi: mprobit clasificacion `vars' espera, baseoutcome(1)
test _Igender_co_2 edad _Isegmento_2 _Isegmento_3 _Isegmento_4 _Isegmento_5 espera
test _Igender_co_2
test edad
test _Isegmento_2
test _Isegmento_3
test _Isegmento_4
test _Isegmento_5
test espera


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


*import excel "usu_individual_t416.xlsx", sheet("Sheet 1") firstrow case(lower)
*save "usu_individual_t416", replace
use "usu_individual_t416", clear
describe

keep if (estado==1 | estado==2 | estado==3)

local vars="i.aglomerado ch06 i.ch07"

generate d_ocupado=(estado==1)
generate d_desocupado=(estado==2)
generate d_inactivo=(estado==3)

mlogit estado `vars', baseoutcome(3)
mlogit estado `vars', baseoutcome(3) rrr
estimates store mlogit
predict pr_mlogit1 pr_mlogit2 pr_mlogit3, pr
summarize pr_mlogit* d_ocupado d_desocupado d_inactivo, separator(3)