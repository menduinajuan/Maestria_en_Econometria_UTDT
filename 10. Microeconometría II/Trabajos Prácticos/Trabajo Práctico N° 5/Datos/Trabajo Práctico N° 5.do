clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/10. Microeconometría II/Trabajos Prácticos/Trabajo Práctico N° 5/Datos"


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


*INCISO (a)*

clear all
set obs 100
set seed 12345

generate y0=rnormal(100,30)

*INCISO (b)*

generate te=rnormal(20,10)
generate y1=y0+te+rnormal(0,10)

drawnorm random1
sort random1
generate DD=(random1>0)

*INCISO (c)*

generate random2=runiform(0,1)

generate alwaystaker=(random2<0.25)
generate nevertaker=(random2>=0.25 & random2<0.5)
generate defier=(random2>=0.5 & random2<0.75)
generate complier=(random2>0.75)

generate D=0
replace D=1 if (alwaystaker==1)
replace D=0 if (nevertaker==1)
replace D=DD if (complier==1)
replace D=(1-DD) if (defier==1)

*INCISO (d)*

generate y=D*y1+(1-D)*y0

*INCISO (e)*

bysort DD: summarize y
bysort D: summarize y
generate U=1-D
ttest y, by(U)

summarize te if (complier==1)
display as text "LATE = " as result r(mean)
summarize te
display as text "ATE = " as result r(mean)


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


