clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/3. Análisis Estadístico Multivariado/Trabajos Prácticos/Trabajo Práctico N° 7/Datos"


quietly include "gmtest"


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


use "firmas", clear
describe

local vars="ebitass rotc"

*INCISO (a)*

summarize `vars'
summarize `vars' if (group==0)
summarize `vars' if (group==1)

graph twoway (scatter `vars' if (group==0)) (scatter `vars' if (group==1)), ///
											title("Scatterplot", color(black)) ///
											legend(label(1 "Good performing companies") label(2 "Bad performing companies"))

*INCISO (b)*

gmtest group `vars'

*INCISO (c)*

discrim lda `vars', group(group) priors(0.5, 0.5)

estat loadings, unstandardized
matrix define unstd=r(L_unstd)
matrix list unstd

scalar define w0=unstd[3,1]
scalar define w1=unstd[2,1]
scalar define w2=unstd[1,1]
scalar define a0=-w0/w2
scalar define a1=-w1/w2

graph twoway (scatter `vars' if (group==0)) (scatter `vars' if (group==1)) (function y=a0+a1*x, range(rotc)), ///
											title("Análisis discriminante", color(black)) ytitle("EBITASS") xtitle("ROTC") ///
											legend(label(1 "Good performing companies") label(2 "Bad performing companies") label(3 "Line"))

estat list
estat classfunctions

*INCISO (d)*

predict pp_1 pp_2, pr
predict classification, classification 
predict d_mahalanobis, mahalanobis

*INCISO (e)*

local ebitass=0.1
local rotc=0.1

graph twoway (scatter `vars' if (group==0)) (scatter `vars' if (group==1)) (function y=a0+a1*x, range(rotc)), ///
											title("Análisis discriminante", color(black)) ytitle("EBITASS") xtitle("ROTC") ///
											yline(`ebitass', lcolor(red)) xline(`rotc', lcolor(red)) ///
											legend(label(1 "Good performing companies") label(2 "Bad performing companies") label(3 "Line"))


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


use "muestra_engh", clear
describe

local cols=9
local vars=""
forvalues i=1(1)`cols' {
	local vars="`vars' cap`i'"
}
local groups=3

*INCISO (a)*

summarize `vars'
summarize `vars' if (region==1)
summarize `vars' if (region==4)
summarize `vars' if (region==6)

gmtest region `vars'

*INCISO (b)*

sort region
egen id=group(region)

matrix accum aux=`vars', noconstant deviations
matrix define S=aux/(_N-1)
matrix define S_inv=inv(S)

matrix list aux
matrix list S
matrix list S_inv

forvalues i=1(1)`groups' {

	matrix define mean`i'=J(`cols',1,.)

	forvalues j=1(1)`cols' {
		summarize cap`j' if (id==`i')
		matrix mean`i' [`j',1]=r(mean)
	}

	matrix define alpha`i'=mean`i''*S_inv
	matrix define c`i'=alpha`i'*mean`i'

	matrix list mean`i'
    matrix list alpha`i'
	matrix list c`i'

}

*INCISO (c)*

forvalues i=1(1)`groups' {

	local c`i'=c`i'[1,1] 

	forvalues j=1(1)`cols' {
		local a`j'=alpha`i'[1,`j']
    }

    generate p`i'=(`a1'*cap1+`a2'*cap2+`a3'*cap3+`a4'*cap4+`a5'*cap5+`a6'*cap6+`a7'*cap7+`a8'*cap8+`a9'*cap9)-`c`i''/2

}

generate predict1=.
replace predict1=1 if ((p1>p2 & p2>p3) | (p1>p3 & p3>p2))
replace predict1=2 if ((p2>p1 & p1>p3) | (p2>p3 & p3>p1))
replace predict1=3 if ((p3>p1 & p1>p2) | (p3>p2 & p2>p1))

*INCISO (d)*

forvalues i=1(1)`groups' {
	generate d`i'=.
}

forvalues i=1(1)_N {

     forvalues j=1(1)`groups' {
	 	mkmat `vars' in `i', matrix(x)
		matrix define aux=(x'-mean`j')'*S_inv*(x'-mean`j')
		local a=aux[1,1]
		quietly replace d`j'=`a' if (_n==`i')
	 }

}

generate predict2=.
replace predict2=1 if ((d1<d2 & d2<d3) | (d1<d3 & d3<d2))
replace predict2=2 if ((d2<d1 & d1<d3) | (d2<d3 & d3<d1))
replace predict2=3 if ((d3<d1 & d1<d2) | (d3<d2 & d2<d1))

table predict1 predict2

*INCISO (e)*

matrix define	table1 = J(`groups',`groups',.)
matrix rownames table1 = "id_1" "id_2" "id_3"
matrix colnames table1 = "predict_1" "predict_2" "predict_3"

forvalues i=1(1)`groups' {

	forvalues j=1(1)`groups' {
		count if (id==`i' & predict1==`j')
        local a`i'`j'=r(N)
        matrix table1 [`i',`j']=`a`i'`j''
	}

}

matrix list table1

local pred_ok=table1[1,1]+table1[2,2]+table1[3,3]
local pred_wr=_N-`pred_ok'

display as text "Correct = " as result `pred_ok'
display as text "Incorrect = " as result `pred_wr'

discrim lda `vars', group(id)

*INCISO (f)*

forvalues i=1(1)`groups' {
	count if (id==`i')
	local n=r(N)
	matrix accum aux=`vars' if (id==`i'), noconstant deviations
	matrix define S`i'=aux/(`n'-1)
	matrix define S`i'_inv=inv(S`i')
	matrix list aux
	matrix list S`i'
	matrix list S`i'_inv
	local c`i'=ln(det(S`i'))/2
	display as text "c`i' = " as result `c`i''
}

forvalues i=1(1)`groups' {
	generate d`i'_new=.
}

forvalues i=1(1)_N {

     forvalues j=1(1)`groups' {
	 	mkmat `vars' in `i', matrix(x)
		matrix define aux=(x'-mean`j')'*S`j'_inv*(x'-mean`j')
		local a=aux[1,1]/2
		quietly replace d`j'_new=`a'+`c`j'' if (_n==`i')
	 }

}

generate predict2_new=.
replace predict2_new=1 if ((d1_new<d2_new & d2_new<d3_new) | (d1_new<d3_new & d3_new<d2_new))
replace predict2_new=2 if ((d2_new<d1_new & d1_new<d3_new) | (d2_new<d3_new & d3_new<d1_new))
replace predict2_new=3 if ((d3_new<d1_new & d1_new<d2_new) | (d3_new<d2_new & d2_new<d1_new))

matrix define	table2 = J(`groups',`groups',.)
matrix rownames table2 = "id_1" "id_2" "id_3"
matrix colnames table2 = "predict_1" "predict_2" "predict_3"

forvalues i=1(1)`groups' {

	forvalues j=1(1)`groups' {
		count if (id==`i' & predict2_new==`j')
        local a`i'`j'=r(N)
        matrix table2 [`i',`j']=`a`i'`j''
	}

}

matrix list table2

local pred_ok=table2[1,1]+table2[2,2]+table2[3,3]
local pred_wr=_N-`pred_ok'

display as text "Correct = " as result `pred_ok'
display as text "Incorrect = " as result `pred_wr'

discrim qda `vars', group(id)