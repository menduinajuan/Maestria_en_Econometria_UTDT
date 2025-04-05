clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/3. Análisis Estadístico Multivariado/Trabajos Prácticos/Trabajo Práctico N° 3/Datos"


quietly include "kmedtest"


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


use "firmas", clear
describe
drop group

local vars="ebitass rotc"
local vars_std=""
foreach var of local vars {
	egen `var'_std=std(`var')
	local vars_std="`vars_std' `var'_std"
}

*INCISO (a)*

forvalues i=1(1)5 {
	display as text "Groups: " as result `i'
	kmedtest `vars_std', k(`i')
}
local groups=2

scatter `vars_std'
cluster kmeans `vars_std', k(`groups') generate(group)
graph twoway (scatter `vars_std' if (group==1)) (scatter `vars_std' if (group==2)), title("Análisis de clusters con algoritmo k-medias", color(black))
																					legend(label(1 "Grupo 1") label(2 "Grupo 2"))

*INCISO (b)*

local metodos="singlelinkage averagelinkage completelinkage waveragelinkage medianlinkage centroidlinkage wardslinkage"
foreach met of local metodos {
	cluster `met' `vars_std', name(cluster_`met')
	cluster stop cluster_`met'
	cluster generate cluster_`met'=group(`groups'), name(cluster_`met')
	cluster dendrogram cluster_`met', title("Dendrograma para análisis de clusters con método jerárquico `met'", color(black))
}


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*





*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


import excel "govt_bond_returns", firstrow clear

local vars="mo_1 mo_3 mo_6 mo_8 yr_1 yr_3 yr_5"
local vars_std=""
foreach var of local vars {
	egen `var'_std=std(`var')
	local vars_std="`vars_std' `var'_std"
}

forvalues i=1(1)5 {
	display as text "Groups: " as result `i'
	kmedtest `vars_std', k(`i')
}
local groups=2

local metodos="singlelinkage averagelinkage completelinkage waveragelinkage centroidlinkage wardslinkage"
foreach met of local metodos {
	cluster `met' `vars_std', name(cluster_`met')
	cluster stop cluster_`met'
	cluster generate cluster_`met'=group(`groups'), name(cluster_`met')
	cluster dendrogram cluster_`met', title("Dendrograma para análisis de clusters con método jerárquico `met'", color(black))
}