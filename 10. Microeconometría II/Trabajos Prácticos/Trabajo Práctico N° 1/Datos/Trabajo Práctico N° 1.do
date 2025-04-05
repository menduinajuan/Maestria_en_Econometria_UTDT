clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/10. Microeconometría II/Trabajos Prácticos/Trabajo Práctico N° 1/Datos"


global seed=12345


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


global reps=10000

program define simulation, rclass

    drop _all
    set obs 10

	generate id=_n

    generate y1=7 in 1
    replace y1=5 in 2
    replace y1=5 in 3
    replace y1=7 in 4
    replace y1=4 in 5
    replace y1=10 in 6
    replace y1=1 in 7
    replace y1=5 in 8
    replace y1=3 in 9
    replace y1=9 in 10

    generate y0=1 in 1
    replace y0=6 in 2
    replace y0=1 in 3
    replace y0=8 in 4
    replace y0=2 in 5
    replace y0=1 in 6
    replace y0=10 in 7
    replace y0=6 in 8
    replace y0=7 in 9
    replace y0=8 in 10

	drawnorm random
    sort random

    generate d=.
	replace d=1 in 1/5
    replace d=0 in 6/10

    generate y=d*y1+(1-d)*y0

    egen ybar1=mean(y) if (d==1)
    egen ybar0=mean(y) if (d==0)

    collapse (mean) ybar1 ybar0
    generate dif=ybar1-ybar0

	return scalar mean=dif[1]

end

simulate mean=r(mean), reps(${reps}) seed(${seed}): simulation
summarize mean
display as text "La media de las diferencias de medias de cada simulación es " as result r(mean)


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


*INCISO (c)*

clear all
set obs 100
set seed $seed

generate y0=rnormal(100,30)

*INCISO (d)*

generate te=20
generate y1=y0+te+rnormal(0,10)

drawnorm random 
sort random
generate D=(random>0)

generate y=D*y1+(1-D)*y0

bysort D: summarize y
generate U=1-D
ttest y, by(U)

summarize te
display as text "ATE = " as result r(mean)
summarize te if (D==1)
display as text "ATT = " as result r(mean)
summarize te if (D==0)
display as text "ATU = " as result r(mean)

*INCISO (e)*

clear all
set obs 100
set seed $seed

generate y0=rnormal(100,30)

generate te=rnormal(20,10)
generate y1=y0+te+rnormal(0,10)

drawnorm random 
sort random
generate D=(random>0)

generate y=D*y1+(1-D)*y0

bysort D: summarize y
generate U=1-D
ttest y, by(U)

summarize te
display as text "ATE = " as result r(mean)
summarize te if (D==1)
display as text "ATT = " as result r(mean)
summarize te if (D==0)
display as text "ATU = " as result r(mean)

*INCISO (f)*

clear all
set obs 100
set seed $seed

generate y0=rnormal(100,30)

drawnorm random 
sort random
generate W=(random>0)

generate te=.
replace te=rnormal(20,10) if (W==1)
replace te=rnormal(10,10) if (W==0)

generate y1=y0+te+rnormal(0,10)

generate y=W*y1+(1-W)*y0

bysort W: summarize y
generate U=1-W
ttest y, by(U)

summarize te
display as text "ATE = " as result r(mean)
summarize te if (W==1)
display as text "ATT = " as result r(mean)
summarize te if (W==0)
display as text "ATU = " as result r(mean)

*INCISO (g)*

clear all
set obs 100
set seed $seed

generate y0=rnormal(100,30)

drawnorm random
sort random
generate W=(random>0)

generate te=.
replace te=rnormal(20,10) if (W==1)
replace te=rnormal(10,10) if (W==0)

generate y1=y0+te+rnormal(0,10)

drawnorm random2
sort random2
generate D=(random2>0)

generate y=D*y1+(1-D)*y0

bysort D: summarize y
generate U=1-D
ttest y, by(U)

summarize te
display as text "ATE = " as result r(mean)
summarize te if (D==1)
display as text "ATT = " as result r(mean)
summarize te if (D==0)
display as text "ATU = " as result r(mean)