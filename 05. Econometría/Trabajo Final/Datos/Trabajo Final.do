clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/5. Econometría/Trabajo Final/Datos"


capture log close
log using "Trabajo Final", replace


global seed=2205


*##############################################################################*
***************** 1. INFERENCIA EN EL MODELO DE REGRESIÓN LINEAL ***************
*##############################################################################*


global alpha=3
global beta=1
global reps=2000


********************************************************************************
							* EJERCICIOS 1-7 *
********************************************************************************


*PROGRAMA*

program define mcc, rclass

	*Seteo*
	drop _all
	set obs $n

	*Variables*
	generate x=rnormal(2,1)
	if (${model}==1)				generate u=runiform(-6,6)
	if (${model}==2)				generate u=sqrt(2542/5)*(rbeta(2,5)-2/7)
	if (${model}==3)				generate u=rt(2.1818)
	if (${model}==4)				generate u=sqrt(75)*(rbinomial(1,0.8)-0.8)
	if (${model}==5 | ${model}==6)	generate u=rnormal(0,12^(1/2))
	if (${model}==6)				replace u=500 in 1
	generate y=${alpha}+${beta}*x+u

	*Estimación*
	regress y x

	*Resultados*
	test x=${beta}
	return scalar pvalue=r(p)

end

*SIMULACIONES*

local samples="10 20 100 200 500 1000 5000 10000"
local cols: word count `samples'

matrix define   mcc = J(6,`cols',.)
matrix rownames mcc = "model_1" "model_2" "model_3" "model_4" "model_5" "model_6"
matrix colnames mcc = "n_10" "n_20" "n_100" "n_200" "n_500" "n_1000" "n_5000" "n_10000"

local i=1
quietly forvalues model=1(1)6 {

	local j=1
	foreach n of local samples {

		noisily display as text "Simulación mediante estimación por MCC de modelo (1) " as result `model' as text " con tamaño de muestra n=" as result `n'

		*Simulación (MCC)*
		global model=`model'
		global n=`n'
		simulate pvalue_model`model'_n`n'=r(pvalue), reps(${reps}) seed(${seed}): mcc

		*Base resultados*
		generate n=_n
		if ((`model'==1 & `n'!=10) | `model'==2 | `model'==3 | `model'==4 | `model'==5 | `model'==6) {
			merge 1:1 n using "mcc_base"
			drop _merge
		}
		order _all, sequential
		order n, first
		save "mcc_base", replace

		*Matriz resultados*
		count if (pvalue_model`model'_n`n'<0.05)
		matrix mcc [`i',`j']=r(N)/${reps}*100

		local j=`j'+1

	}

	local i=`i'+1

}

*RESULTADOS FINALES*

drop _all
matrix list mcc
matrix define mcc_t=mcc'
svmat mcc_t, names(col)

local i=1
generate n=.
foreach n of local samples {
	replace n=`n' in `i'
	local i=`i'+1
}

graph twoway (line model_1 n) (line model_2 n) (line model_3 n)	(line model_4 n) (line model_5 n) (line model_6 n),	///
			 ytitle("") xtitle("Tamaño de muestra (n)")	yline(5, lcolor(black))										///
			 legend(label(1 "Modelo 1") label(2 "Modelo 2") label(3 "Modelo 3") label(4 "Modelo 4") label(5 "Modelo 5") label(6 "Modelo 6"))

order n, first
save "mcc_matriz", replace


*##############################################################################*
******************** 2. PROPIEDADES DE MUESTRA FINITA DE FGLS ******************
*##############################################################################*


global beta0=-3
global beta1=0.8
global reps=5000
matrix define omega=(4,0,0,0,0\0,9,0,0,0\0,0,16,0,0\0,0,0,25,0\0,0,0,0,36)


********************************************************************************
							* EJERCICIOS 1-6 *
********************************************************************************


*PROGRAMA*

program define fgls_gls, rclass

	*Seteo*
	drop _all
	set obs $n

	*Variables*
	local n1=${n}/5
	local n11=`n1'+1
	local n2=2*`n1'
	local n21=`n2'+1
	local n3=3*`n1'
	local n31=`n3'+1
	local n4=4*`n1'
	local n41=`n4'+1
	local n5=5*`n1'
	generate c=1
	generate x=runiform(1,50)
	generate u=.
	replace u=rnormal(0,omega[1,1]^(1/2)) in	 1/`n1'
	replace u=rnormal(0,omega[2,2]^(1/2)) in `n11'/`n2'
	replace u=rnormal(0,omega[3,3]^(1/2)) in `n21'/`n3'
	replace u=rnormal(0,omega[4,4]^(1/2)) in `n31'/`n4'
	replace u=rnormal(0,omega[5,5]^(1/2)) in `n41'/`n5'
	generate y=${beta0}+${beta1}*x+u

	*FGLS (matriz omega desconocida y, por lo tanto, estimada)*

		*Estimación de matriz omega (se hace imponiendo una estructura particular, en donde la diagonal principal de la matriz corresponde a los residuos de la estimación por MCC elevados al cuadrado -es decir, se supone heterocedasticidad- y, por fuera de esta diagonal, todos los elementos son ceros -es decir, se supone ausencia de correlación serial-)*
		regress y x c, noconstant
		predict r, residuals
		generate r2=r^2
		matrix define omega_est=J(${n},${n},0)
		forvalues i=1(1)$n {
			matrix omega_est [`i',`i']=r2[`i']
		}

		*Matrices P y P^-1*
		matrix define P=cholesky(omega_est)
		matrix define P_inv=inv(P)
		matrix list P
		matrix list P_inv

		*Variables transformadas*
		foreach var of varlist y x c {
			mkmat `var', matrix(`var')
			matrix define p`var'=P_inv*`var'
			matrix list p`var'
			svmat p`var'
		}
		rename (py1 px1 pc1) (py_fgls px_fgls pc_fgls)

		*Estimación*
		regress py_fgls px_fgls pc_fgls, noconstant

		*Resultados*
		test px_fgls=${beta1}
		return scalar pvalue_b1_08_fgls=r(p)
		test px_fgls=0
		return scalar pvalue_b1_00_fgls=r(p)
		test px_fgls=0.4
		return scalar pvalue_b1_04_fgls=r(p)
		return scalar beta0_fgls=e(b)[1,2]
		return scalar beta1_fgls=e(b)[1,1]

	*GLS (matriz omega conocida)*

	if (${n}==5) {

		*Matrices P y P^-1*
		matrix define P=cholesky(omega)
		matrix define P_inv=inv(P)
		matrix list P
		matrix list P_inv

		*Variables transformadas*
		foreach var of varlist y x c {
			matrix define p`var'=P_inv*`var'
			matrix list p`var'
			svmat p`var'
		}
		rename (py1 px1 pc1) (py_gls px_gls pc_gls)

		*Estimación*
		regress py_gls px_gls pc_gls, noconstant

		*Resultados*
		test px_gls=${beta1}
		return scalar pvalue_b1_08_gls=r(p)
		test px_gls=0
		return scalar pvalue_b1_00_gls=r(p)
		test px_gls=0.4
		return scalar pvalue_b1_04_gls=r(p)
		return scalar beta0_gls=e(b)[1,2]
		return scalar beta1_gls=e(b)[1,1]

	}

end

*SIMULACIONES*

local samples="5 10 30 100 200 500"
local cols: word count `samples'

matrix define   fgls_gls = J(10,`cols'+1,.)
matrix rownames fgls_gls = "tam_test_1" "tam_test_5" "poder_test_b1_00" "poder_test_b1_04" "media_b0" "mediana_b0" "de_b0" "media_b1" "mediana_b1" "de_b1"
matrix colnames fgls_gls = "5N_5_fgls" "5N_5_gls" "5N_10_fgls" "5N_30_fgls" "5N_100_fgls" "5N_200_fgls" "5N_500_fgls"

local i=1
quietly foreach n of local samples {

	noisily display as text "Simulación mediante estimación por FGLS-GLS de modelo (2) con tamaño de muestra 5N=" as result `n'

	*Simulación (FGLS y GLS para 5N=5 y sólo FGLS para el resto de las posibilidades de tamaño de muestra)*
	global n=`n'
	if (`n'!=5) simulate pvalue_b1_08_fgls_n`n'=r(pvalue_b1_08_fgls) pvalue_b1_00_fgls_n`n'=r(pvalue_b1_00_fgls) pvalue_b1_04_fgls_n`n'=r(pvalue_b1_04_fgls)	///
						 beta0_fgls_n`n'=r(beta0_fgls) beta1_fgls_n`n'=r(beta1_fgls), reps(${reps}) seed(${seed}): fgls_gls
	else		simulate pvalue_b1_08_fgls_n`n'=r(pvalue_b1_08_fgls) pvalue_b1_00_fgls_n`n'=r(pvalue_b1_00_fgls) pvalue_b1_04_fgls_n`n'=r(pvalue_b1_04_fgls)	///
						 beta0_fgls_n`n'=r(beta0_fgls) beta1_fgls_n`n'=r(beta1_fgls)																			///
						 pvalue_b1_08_gls_n`n' =r(pvalue_b1_08_gls)	 pvalue_b1_00_gls_n`n' =r(pvalue_b1_00_gls)  pvalue_b1_04_gls_n`n' =r(pvalue_b1_04_gls)		///
						 beta0_gls_n`n' =r(beta0_gls)  beta1_gls_n`n' =r(beta1_gls) , reps(${reps}) seed(${seed}): fgls_gls
	*Base resultados*
	generate n=_n
	if (`n'!=5) {
		merge 1:1 n using "fgls_gls_base"
		drop _merge
	}
	order _all, sequential
	order n, first
	save "fgls_gls_base", replace

	*Matriz resultados FGLS*
	count if (pvalue_b1_08_fgls_n`n'<0.01)
	matrix fgls_gls [1,`i']=r(N)/${reps}*100
	count if (pvalue_b1_08_fgls_n`n'<0.05)
	matrix fgls_gls [2,`i']=r(N)/${reps}*100
	count if (pvalue_b1_00_fgls_n`n'<0.05)
	matrix fgls_gls [3,`i']=r(N)/${reps}*100
	count if (pvalue_b1_04_fgls_n`n'<0.05)
	matrix fgls_gls [4,`i']=r(N)/${reps}*100
	local j=0
	forvalues beta=0(1)1 {
		summarize beta`beta'_fgls_n`n', detail
		matrix fgls_gls [5+`j',`i']=r(mean)
		matrix fgls_gls [6+`j',`i']=r(p50)
		matrix fgls_gls [7+`j',`i']=r(sd)
		local j=`j'+3
	}

	*Matriz resultados GLS*
	if (`n'==5) {
		local i=`i'+1
		count if (pvalue_b1_08_gls_n`n'<0.01)
		matrix fgls_gls [1,`i']=r(N)/${reps}*100
		count if (pvalue_b1_08_gls_n`n'<0.05)
		matrix fgls_gls [2,`i']=r(N)/${reps}*100
		count if (pvalue_b1_00_gls_n`n'<0.05)
		matrix fgls_gls [3,`i']=r(N)/${reps}*100
		count if (pvalue_b1_04_gls_n`n'<0.05)
		matrix fgls_gls [4,`i']=r(N)/${reps}*100
		local j=0
		forvalues beta=0(1)1 {
			summarize beta`beta'_gls_n`n', detail
			matrix fgls_gls [5+`j',`i']=r(mean)
			matrix fgls_gls [6+`j',`i']=r(p50)
			matrix fgls_gls [7+`j',`i']=r(sd)
			local j=`j'+3
		}
	}

	local i=`i'+1

}

*RESULTADOS FINALES*

drop _all
matrix list fgls_gls
matrix define fgls_gls_t=fgls_gls'
svmat fgls_gls_t, names(col)

local i=1
generate n=.
foreach n of local samples {
	replace n=`n' in `i'
	local i=`i'+1
}

order n, first
save "fgls_gls_matriz", replace


*##############################################################################*
* 3. CORRECCIÓN DE LA MATRIZ DE VARIANZAS Y COVARIANZAS EN PRESENCIA DE HETEROCEDASTICIDAD, WHITE (1980) *
*##############################################################################*


global b0=1
global b1=1
global b2=1
global reps=5000


********************************************************************************
							* EJERCICIOS (a)-(g) *
********************************************************************************


*PROGRAMA*

program define mcc_white, rclass

	*Seteo*
	drop _all
	set obs $n

	*Variables*
	local n=${n}/20
	local j=0
	generate c=1
	generate x1=.
	forvalues i=1(1)`n' {
		local j1 =`j'+1
		local j2 =`j'+2
		local j19=`j'+19
		local j20=`j'+20
		replace x1=-1 in `j1'
		replace x1=runiform(-1,1) in `j2'/`j19'
		replace x1=1 in `j20'
		local j=`j'+20
	}
	generate x2=rnormal()
	generate u1=rnormal()
	generate u2=rt(5)
	generate v=exp(0.25*x1+0.25*x2)
	generate e_d1=sqrt(v)*u1
	generate e_d2=sqrt(v)*u2
	generate y1=${b0}+${b1}*x1+${b2}*x2+e_d1
	generate y2=${b0}+${b1}*x1+${b2}*x2+e_d2

	*MCC-WHITE_R2 (construyendo la estimación de la matriz de White con una matriz diagonal con los residuos de la estimación por MCC elevados al cuadrado)*

		*DISEÑO 1*

			*Estimación*
			regress y1 x1 x2 c, noconstant
			matrix define var_est_d1=e(V)
			matrix list var_est_d1

			*Matriz de White*
			predict r_d1, residuals
			generate r2_d1=r_d1^2
			matrix define omega_d1_r2=J(${n},${n},0)
			forvalues i=1(1)$n {
				matrix omega_d1_r2 [`i',`i']=r2_d1[`i']
			}
			mkmat x1 x2 c, matrix(X)
			matrix define var_white_d1_r2=inv(X'*X)*X'*omega_d1_r2*X*inv(X'*X)
			matrix list var_white_d1_r2

			*Resultados*
			return scalar sesgo_rel_b0_d1_r2=(var_est_d1[3,3]-var_white_d1_r2[3,3])/var_white_d1_r2[3,3]
			return scalar sesgo_rel_b1_d1_r2=(var_est_d1[1,1]-var_white_d1_r2[1,1])/var_white_d1_r2[1,1]
			return scalar sesgo_rel_b2_d1_r2=(var_est_d1[2,2]-var_white_d1_r2[2,2])/var_white_d1_r2[2,2]

		*DISEÑO 2*

			*Estimación*
			regress y2 x1 x2 c, noconstant
			matrix define var_est_d2=e(V)
			matrix list var_est_d2

			*Matriz de White*
			predict r_d2, residuals
			generate r2_d2=r_d2^2
			matrix define omega_d2_r2=J(${n},${n},0)
			forvalues i=1(1)$n {
				matrix omega_d2_r2 [`i',`i']=r2_d2[`i']
			}
			matrix define var_white_d2_r2=inv(X'*X)*X'*omega_d2_r2*X*inv(X'*X)
			matrix list var_white_d2_r2

			*Resultados*
			return scalar sesgo_rel_b0_d2_r2=(var_est_d2[3,3]-var_white_d2_r2[3,3])/var_white_d2_r2[3,3]
			return scalar sesgo_rel_b1_d2_r2=(var_est_d2[1,1]-var_white_d2_r2[1,1])/var_white_d2_r2[1,1]
			return scalar sesgo_rel_b2_d2_r2=(var_est_d2[2,2]-var_white_d2_r2[2,2])/var_white_d2_r2[2,2]

	*MCC-WHITE_E2 (construyendo la estimación de la matriz de White con una matriz diagonal con los errores verdaderos elevados al cuadrado)*

		*DISEÑO 1*

			*Matriz de White*
			generate e2_d1=e_d1^2
			matrix define omega_d1_e2=J(${n},${n},0)
			forvalues i=1(1)$n {
				matrix omega_d1_e2 [`i',`i']=e2_d1[`i']
			}
			mkmat x1 x2 c, matrix(X)
			matrix define var_white_d1_e2=inv(X'*X)*X'*omega_d1_e2*X*inv(X'*X)
			matrix list var_white_d1_e2

			*Resultados*
			return scalar sesgo_rel_b0_d1_e2=(var_est_d1[3,3]-var_white_d1_e2[3,3])/var_white_d1_e2[3,3]
			return scalar sesgo_rel_b1_d1_e2=(var_est_d1[1,1]-var_white_d1_e2[1,1])/var_white_d1_e2[1,1]
			return scalar sesgo_rel_b2_d1_e2=(var_est_d1[2,2]-var_white_d1_e2[2,2])/var_white_d1_e2[2,2]

		*DISEÑO 2*

			*Matriz de White*
			generate e2_d2=e_d2^2
			matrix define omega_d2_e2=J(${n},${n},0)
			forvalues i=1(1)$n {
				matrix omega_d2_e2 [`i',`i']=e2_d2[`i']
			}
			matrix define var_white_d2_e2=inv(X'*X)*X'*omega_d2_e2*X*inv(X'*X)
			matrix list var_white_d2_e2

			*Resultados*
			return scalar sesgo_rel_b0_d2_e2=(var_est_d2[3,3]-var_white_d2_e2[3,3])/var_white_d2_e2[3,3]
			return scalar sesgo_rel_b1_d2_e2=(var_est_d2[1,1]-var_white_d2_e2[1,1])/var_white_d2_e2[1,1]
			return scalar sesgo_rel_b2_d2_e2=(var_est_d2[2,2]-var_white_d2_e2[2,2])/var_white_d2_e2[2,2]

end

*SIMULACIONES*

local samples="20 60 100 200 400 600"
local cols: word count `samples'

matrix define   mcc_white = J(16,`cols',.)
matrix rownames mcc_white = "sesgo_rel_b0_d1_r2" "sesgo_rel_b1_d1_r2" "sesgo_rel_b2_d1_r2" "sesgo_rel_tot_d1_r2" ///
							"sesgo_rel_b0_d2_r2" "sesgo_rel_b1_d2_r2" "sesgo_rel_b2_d2_r2" "sesgo_rel_tot_d2_r2" ///
							"sesgo_rel_b0_d1_e2" "sesgo_rel_b1_d1_e2" "sesgo_rel_b2_d1_e2" "sesgo_rel_tot_d1_e2" ///
							"sesgo_rel_b0_d2_e2" "sesgo_rel_b1_d2_e2" "sesgo_rel_b2_d2_e2" "sesgo_rel_tot_d2_e2"
matrix colnames mcc_white = "n_20" "n_60" "n_100" "n_200" "n_400" "n_600"

local i=1
quietly foreach n of local samples {

	noisily display as text "Simulación mediante MCC-White de modelo (3) con tamaño de muestra n=" as result `n'

	*Simulación (MCC-White)*
	global n=`n'
	simulate sesgo_rel_b0_d1_r2_n`n'=r(sesgo_rel_b0_d1_r2) sesgo_rel_b1_d1_r2_n`n'=r(sesgo_rel_b1_d1_r2) sesgo_rel_b2_d1_r2_n`n'=r(sesgo_rel_b2_d1_r2)	///
			 sesgo_rel_b0_d2_r2_n`n'=r(sesgo_rel_b0_d2_r2) sesgo_rel_b1_d2_r2_n`n'=r(sesgo_rel_b1_d2_r2) sesgo_rel_b2_d2_r2_n`n'=r(sesgo_rel_b2_d2_r2)	///
			 sesgo_rel_b0_d1_e2_n`n'=r(sesgo_rel_b0_d1_e2) sesgo_rel_b1_d1_e2_n`n'=r(sesgo_rel_b1_d1_e2) sesgo_rel_b2_d1_e2_n`n'=r(sesgo_rel_b2_d1_e2)	///
			 sesgo_rel_b0_d2_e2_n`n'=r(sesgo_rel_b0_d2_e2) sesgo_rel_b1_d2_e2_n`n'=r(sesgo_rel_b1_d2_e2) sesgo_rel_b2_d2_e2_n`n'=r(sesgo_rel_b2_d2_e2), ///
			 reps(${reps}) seed(${seed}): mcc_white

	*Base resultados*
	generate n=_n
	if (`n'!=20) {
		merge 1:1 n using "mcc_white_base"
		drop _merge
	}
	order _all, sequential
	order n, first
	save "mcc_white_base", replace

	*Matriz resultados*
	local j=0
	foreach d=1(1)2 {
		summarize sesgo_rel_b0_d`d'_r2_n`n'
		matrix mcc_white [1+`j',`i']=r(mean)
		summarize sesgo_rel_b1_d`d'_r2_n`n'
		matrix mcc_white [2+`j',`i']=r(mean)
		summarize sesgo_rel_b2_d`d'_r2_n`n'
		matrix mcc_white [3+`j',`i']=r(mean)
		matrix mcc_white [4+`j',`i']=abs(mcc_white[1+`j',`i'])+abs(mcc_white[2+`j',`i'])+abs(mcc_white[3+`j',`i'])
		local j=`j'+4
	}
	foreach d=1(1)2 {
		summarize sesgo_rel_b0_d`d'_e2_n`n'
		matrix mcc_white [1+`j',`i']=r(mean)
		summarize sesgo_rel_b1_d`d'_e2_n`n'
		matrix mcc_white [2+`j',`i']=r(mean)
		summarize sesgo_rel_b2_d`d'_e2_n`n'
		matrix mcc_white [3+`j',`i']=r(mean)
		matrix mcc_white [4+`j',`i']=abs(mcc_white[1+`j',`i'])+abs(mcc_white[2+`j',`i'])+abs(mcc_white[3+`j',`i'])
		local j=`j'+4
	}

	local i=`i'+1

}

*RESULTADOS FINALES*

drop _all
matrix list mcc_white
matrix define mcc_white_t=mcc_white'
svmat mcc_white_t, names(col)

local i=1
generate n=.
foreach n of local samples {
	replace n=`n' in `i'
	local i=`i'+1
}

graph twoway (line sesgo_rel_tot_d1_r2 n) (line sesgo_rel_tot_d2_r2 n)		///
			 (line sesgo_rel_tot_d1_e2 n) (line sesgo_rel_tot_d2_e2 n),		///
			 ytitle("Sesgo relativo total") xtitle("Tamaño de muestra (n)") ///
			 legend(label(1 "Diseño 1 - White r2") label(2 "Diseño 2 - White r2") label(3 "Diseño 1 - White e2") label(4 "Diseño 2 - White e2"))

order n, first
save "mcc_white_matriz", replace


log close