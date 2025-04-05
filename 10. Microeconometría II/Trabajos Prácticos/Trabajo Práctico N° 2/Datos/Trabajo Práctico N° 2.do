clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/10. Microeconometría II/Trabajos Prácticos/Trabajo Práctico N° 2/Datos"


/*
findit install nnmatch
findit install pscore
ssc install psestimate, replace
ssc install psmatch2, replace
ssc install rbounds, replace
*/


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


use "cattaneo2", clear
describe

local vars="mmarried alcohol deadkids nprenatal monthslb prenatal fbaby"

*INCISO (a)*

bysort mbsmoke: summarize `vars'

*INCISO (b)*

foreach var of varlist `vars' {
	display as text "Test de diferencia de medias para `var'"
	ttest `var', by(mbsmoke) unequal
}

*INCISO (c)*

psestimate mbsmoke, totry(`vars')
local propensity_score=r(h)

logit mbsmoke `propensity_score'
predict e_x, pr

optselect e_x
keep if (e_x>=r(bound) & e_x<=1-r(bound))

psmatch2 mbsmoke, pscore(e_x) noreplacement
keep if (_weight==1)
drop e_x

pscore `vars', pscore(e_x) blockid(blockid)

bysort mbsmoke: summarize `vars'
foreach var of varlist `vars' {
	display as text "Test de diferencia de medias para `var'"
	ttest `var', by(mbsmoke) unequal
}

*INCISO (d)*

attnd bweight mbsmoke, pscore(e_x)
attnd bweight mbsmoke, pscore(e_x) bootstrap reps(10)

attr bweight mbsmoke, pscore(e_x)
attr bweight mbsmoke, pscore(e_x) bootstrap reps(10)

attk bweight mbsmoke, pscore(e_x)
attk bweight mbsmoke, pscore(e_x) bootstrap reps(10)

atts bweight mbsmoke, pscore(e_x) blockid(blockid)
atts bweight mbsmoke, pscore(e_x) blockid(blockid) bootstrap reps(10)

*INCISO (e)*

nnmatch bweight mbsmoke e_x, biasadj(`vars')

*INCISO (f)*

teffects ra (bweight `vars', linear) (mbsmoke), ate

*INCISO (g)*

teffects ipw (bweight) (`vars', logit), ate

*INCISO (h)*

teffects aipw (bweight `vars', linear) (mbsmoke `vars', logit), ate