clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/7. Econometría de Datos de Panel/Examen/Datos"


capture log close
log using "Examen Final", replace


global seed=2205


*##############################################################################*
*********** 1. PROPIEDADES DE MUESTRA FINITA EN PANELES NO BALANCEADOS *********
*##############################################################################*


global beta=1
global gamma1=1
global gamma2=1
global reps=1000

global models="A B C"
global params="beta gamma1 gamma2"
global samples="20 40 100"


********************************************************************************
								* EJERCICIO 1 *
********************************************************************************


*PROGRAMA*

program define simulation1, rclass

	*Seteo*
	drop _all
	local N=$N
	local T=$T
	local NT=`N'*`T'
	set obs `NT'
	egen id=seq(), from(1) to(`N') block(`T')
	egen t=seq(), from(1) to(`T')
	xtset id t

	*Variables generales*
	generate w=rnormal()
	generate z=rnormal()
	generate x=w
	generate epsilon=rnormal()
	generate psi1=rnormal()
	generate u=0.6*epsilon+0.8*psi1
	forvalues i=2(1)4 {
		generate psi`i'=.
		forvalues id=1(1)`N' {
			local aux=rnormal()
			replace psi`i'=`aux' if (id==`id')
		}
	}

	*Variables de efectos fijos de los modelos (A, B, C)*
	foreach model of global models {
		generate alpha_`model'=.
		generate c_`model'=.
	}
	replace alpha_A=psi2+psi4
	replace c_A=psi3+psi4
	replace alpha_B=psi2+(z+z[_n+1])/2 if (t==1)
	replace alpha_B=psi2+(z[_n-1]+z)/2 if (t==2)
	replace c_B=psi3+(x+x[_n+1])/2 if (t==1)
	replace c_B=psi3+(x[_n-1]+x)/2 if (t==2)
	replace alpha_C=psi2+(z+z[_n+1])/2+psi4 if (t==1)
	replace alpha_C=psi2+(z[_n-1]+z)/2+psi4 if (t==2)
	replace c_C=psi3+(x+x[_n+1])/2+psi4 if (t==1)
	replace c_C=psi3+(x[_n-1]+x)/2+psi4 if (t==2)
	if (`T'>2) {
		foreach model of newlist B C {
			replace alpha_`model'=alpha_`model'[_n-1] if (t>2)
			replace c_`model'=c_`model'[_n-1] if (t>2)
		}
	}

	*Variables dependientes de los modelos (A, B, C)*
	foreach model of global models {
		generate y_star_`model'=${beta}*x+c_`model'+u
		generate s_star_`model'=${gamma1}*w+${gamma2}*z+alpha_`model'+epsilon
		generate s_`model'_obs=(s_star_`model'>0)
		generate y_`model'=y_star_`model'*s_`model'_obs
		generate s_`model'=s_star_`model'*s_`model'_obs
	}

	*Variables para estimar los modelos (A, B, C) por Wooldridge (1995) bajo el enfoque de Mundlak (1978) -----> Se utiliza este enfoque*
	foreach var of varlist x w z {
		egen mean_`var'=mean(`var'), by(id)		
	}

	*Variables para estimar los modelos (A, B, C) por Wooldridge (1995) bajo el enfoque de Chamberlain (1978) -----> No se utiliza este enfoque*
	forvalues t=1(1)`T' {
		foreach var of varlist x w z {
			generate `var'`t'=.		
		}
		forvalues id=1(1)`N' {
			foreach var of varlist x w z {
				summarize `var' if (id==`id' & t==`t')
				replace `var'`t'=r(mean) if (id==`id')
			}
		}
	}

	*Estimación de modelos (A, B, C) por FE -----> A fines comparativos*
	foreach model of global models {
		xtreg y_`model' x, fe vce(cluster id)
		xtreg s_`model' w z, fe vce(cluster id)
	}

	*Estimación de modelos (A, B, C) por Wooldridge (1995) bajo el enfoque de Mundlak (1978) -----> Se utiliza este enfoque (se retornan sus valores)*
	foreach model of global models {
		*Ecuación de interés*
		probit s_`model'_obs x mean_x
		predict yhat_mundlak_`model', xb
		generate lambda_y_mundlak_`model'=normalden(yhat_mundlak_`model')/normal(yhat_mundlak_`model')
		regress y_`model' x mean_x i.t#c.lambda_y_mundlak_`model', robust
		return scalar beta_model`model'=e(b)[1,1]
		*Ecuación de selección*
		probit s_`model'_obs w z mean_w mean_z
		predict shat_mundlak_`model', xb
		generate lambda_s_mundlak_`model'=normalden(shat_mundlak_`model')/normal(shat_mundlak_`model')
		regress s_`model' w z mean_w mean_z i.t#c.lambda_s_mundlak_`model', robust
		return scalar gamma1_model`model'=e(b)[1,1]
		return scalar gamma2_model`model'=e(b)[1,2]
	}

	*Estimación de modelos (A, B, C) por Wooldridge (1995) bajo el enfoque de Chamberlain (1980) -----> No se utiliza este enfoque (no se retornan sus valores)*
	foreach model of global models {
		*Ecuación de interés*
		probit s_`model'_obs x mean_x
		predict yhat_chamberlain_`model', xb
		generate lambda_y_chamberlain_`model'=normalden(yhat_chamberlain_`model')/normal(yhat_chamberlain_`model')
		regress y_`model' x mean_x i.t#c.lambda_y_chamberlain_`model', robust
		return scalar beta_model`model'=e(b)[1,1]
		*Ecuación de selección*
		probit s_`model'_obs w z mean_w mean_z
		predict shat_chamberlain_`model', xb
		generate lambda_s_chamberlain_`model'=normalden(shat_chamberlain_`model')/normal(shat_chamberlain_`model')
		regress s_`model' w z mean_w mean_z i.t#c.lambda_s_chamberlain_`model', robust
		return scalar gamma1_model`model'=e(b)[1,1]
		return scalar gamma2_model`model'=e(b)[1,2]
	}

end

*SIMULACIONES*

local cols: word count $samples

matrix define   results1 = J(45,`cols',.)
matrix rownames results1 = "sesgo_medio_beta_modelA"	"sesgo_mediano_beta_modelA"   "de_beta_modelA"   "rmse_beta_modelA"   "amd_beta_modelA"		///
						   "sesgo_medio_gamma1_modelA"	"sesgo_mediano_gamma1_modelA" "de_gamma1_modelA" "rmse_gamma1_modelA" "amd_gamma1_modelA"	///
						   "sesgo_medio_gamma2_modelA"	"sesgo_mediano_gamma2_modelA" "de_gamma2_modelA" "rmse_gamma2_modelA" "amd_gamma2_modelA"	///
						   "sesgo_medio_beta_modelB"	"sesgo_mediano_beta_modelB"   "de_beta_modelB"   "rmse_beta_modelB"   "amd_beta_modelB"		///
						   "sesgo_medio_gamma1_modelB"	"sesgo_mediano_gamma1_modelB" "de_gamma1_modelB" "rmse_gamma1_modelB" "amd_gamma1_modelB"	///
						   "sesgo_medio_gamma2_modelB"	"sesgo_mediano_gamma2_modelB" "de_gamma2_modelB" "rmse_gamma2_modelB" "amd_gamma2_modelB"	///
						   "sesgo_medio_beta_modelC"	"sesgo_mediano_beta_modelC"   "de_beta_modelC"   "rmse_beta_modelC"   "amd_beta_modelC"		///
						   "sesgo_medio_gamma1_modelC"	"sesgo_mediano_gamma1_modelC" "de_gamma1_modelC" "rmse_gamma1_modelC" "amd_gamma1_modelC"	///
						   "sesgo_medio_gamma2_modelC"	"sesgo_mediano_gamma2_modelC" "de_gamma2_modelC" "rmse_gamma2_modelC" "amd_gamma2_modelC"
matrix colnames results1 = "N_20" "N_40" "N_100"

local i=1
quietly foreach N of global samples {

	noisily display as text "Simulación con tamaño de muestra N=" as result `N'

	*Simulación*
	global N=`N'
	global T=2
	simulate beta_modelA_N`N'=r(beta_modelA) gamma1_modelA_N`N'=r(gamma1_modelA) gamma2_modelA_N`N'=r(gamma2_modelA) ///
			 beta_modelB_N`N'=r(beta_modelB) gamma1_modelB_N`N'=r(gamma1_modelB) gamma2_modelB_N`N'=r(gamma2_modelB) ///
			 beta_modelC_N`N'=r(beta_modelC) gamma1_modelC_N`N'=r(gamma1_modelC) gamma2_modelC_N`N'=r(gamma2_modelC), reps(${reps}) seed(${seed}): simulation1

	*Base resultados*
	generate n=_n
	if (`N'!=20) {
		merge 1:1 n using "results1_base"
		drop _merge
	}
	order _all, sequential
	order n, first
	save "results1_base", replace

	*Matriz resultados*
	local j=0
	foreach model of global models {
		foreach param of global params {
			summarize `param'_model`model'_N`N', detail
			matrix results1 [`j'+1,`i']=r(mean)-${`param'}
			matrix results1 [`j'+2,`i']=r(p50)-${`param'}
			matrix results1 [`j'+3,`i']=r(sd)
			generate rmse_model`model'_`param'=(`param'_model`model'_N`N'-${`param'})^2
			summarize rmse_model`model'_`param'
			matrix results1 [`j'+4,`i']=sqrt(r(mean))
			generate amd_model`model'_`param'=abs(`param'_model`model'_N`N'-${`param'})
			summarize amd_model`model'_`param'
			matrix results1 [`j'+5,`i']=r(mean)
			local j=`j'+5
		}
	}

	local i=`i'+1

}

*RESULTADOS FINALES*

drop _all
matrix list results1
matrix define results1_t=results1'
svmat results1_t, names(col)

local i=1
generate N=.
foreach N of global samples {
	replace N=`N' in `i'
	local i=`i'+1
}

order N, first
save "results1_matriz", replace


********************************************************************************
								* EJERCICIO 2 *
********************************************************************************


*SIMULACIÓN (S=1)*

quietly foreach N of global samples {

	noisily display as text "Simulación (S=1) con tamaño de muestra N=" as result `N'

	*Seteo*
	drop _all
	set seed $seed
	local T=10
	local NT=`N'*`T'
	set obs `NT'
	egen id=seq(), from(1) to(`N') block(`T')
	egen t=seq(), from(1) to(`T')
	xtset id t

	*Variables generales*
	generate w=rnormal()
	generate z=rnormal()
	generate x=w
	generate epsilon=rnormal()
	generate psi1=rnormal()
	generate u=0.6*epsilon+0.8*psi1
	forvalues i=2(1)4 {
		generate psi`i'=.
		forvalues id=1(1)`N' {
			local aux=rnormal()
			replace psi`i'=`aux' if (id==`id')
		}
	}

	*Variables de efectos fijos de los modelos (A, B, C)*
	foreach model of global models {
		generate alpha_`model'=.
		generate c_`model'=.
	}
	replace alpha_A=psi2+psi4
	replace c_A=psi3+psi4
	replace alpha_B=psi2+(z+z[_n+1])/2 if (t==1)
	replace alpha_B=psi2+(z[_n-1]+z)/2 if (t==2)
	replace c_B=psi3+(x+x[_n+1])/2 if (t==1)
	replace c_B=psi3+(x[_n-1]+x)/2 if (t==2)
	replace alpha_C=psi2+(z+z[_n+1])/2+psi4 if (t==1)
	replace alpha_C=psi2+(z[_n-1]+z)/2+psi4 if (t==2)
	replace c_C=psi3+(x+x[_n+1])/2+psi4 if (t==1)
	replace c_C=psi3+(x[_n-1]+x)/2+psi4 if (t==2)
	if (`T'>2) {
		foreach model of newlist B C {
			replace alpha_`model'=alpha_`model'[_n-1] if (t>2)
			replace c_`model'=c_`model'[_n-1] if (t>2)
		}
	}

	*Variables dependientes de los modelos (A, B, C)*
	foreach model of global models {
		generate y_star_`model'=${beta}*x+c_`model'+u
		generate s_star_`model'=${gamma1}*w+${gamma2}*z+alpha_`model'+epsilon
		generate s_`model'_obs=(s_star_`model'>0)
		generate y_`model'=y_star_`model'*s_`model'_obs
		generate s_`model'=s_star_`model'*s_`model'_obs
	}

	*Variables para estimar los modelos (A, B, C) por Wooldridge (1995) bajo el enfoque de Mundlak (1978)*
	foreach var of varlist x w z {
		egen mean_`var'=mean(`var'), by(id)		
	}

	*Estimación de modelos (A, B, C) por Wooldridge (1995) bajo el enfoque de Mundlak (1978)*
	foreach model of global models {
		*Ecuación de interés*
		probit s_`model'_obs x mean_x
		predict yhat_mundlak_`model', xb
		generate lambda_y_mundlak_`model'=normalden(yhat_mundlak_`model')/normal(yhat_mundlak_`model')
		regress y_`model' x mean_x i.t#c.lambda_y_mundlak_`model', robust
		scalar beta_model`model'_N`N'=e(b)[1,1]
		scalar Ky_model`model'_N`N'=e(rank)
		matrix define Vy_model`model'_N`N'=e(V)
		*Ecuación de selección*
		probit s_`model'_obs w z mean_w mean_z
		predict shat_mundlak_`model', xb
		generate lambda_s_mundlak_`model'=normalden(shat_mundlak_`model')/normal(shat_mundlak_`model')
		regress s_`model' w z mean_w mean_z i.t#c.lambda_s_mundlak_`model', robust
		scalar gamma1_model`model'_N`N'=e(b)[1,1]
		scalar gamma2_model`model'_N`N'=e(b)[1,2]
		predict epsilon_hat_model`model', residuals
		scalar Ks_model`model'_N`N'=e(rank)
		matrix define Vs_model`model'_N`N'=e(V)
	}

	*Base*
	save "base_S1_N`N'", replace

}


*INTERVALOS DE CONFIANZA DE 95% A PARTIR DE BOOTSTRAPPING*


local n=1
quietly foreach N of global samples {

	noisily display as text "Intervalos de confianza de 95% a partir de bootstrapping con tamaño de muestra N=" as result `N'

	use "base_S1_N`N'", clear
	set seed $seed

	forvalues boot=1(1)$reps {

		noisily display as result "`boot' " _continue

		*Muestreo aleatorio simple con reemplazo para obtener una nueva muestra de errores de la ecuación de selección*
		preserve
		bsample, strata(id)
		foreach model of global models {
			mkmat epsilon_hat_model`model', matrix(epsilon_hat_model`model'_boot)
			matrix colnames epsilon_hat_model`model'_boot="epsilon_hat_model`model'_boot"
		}
		restore

		*Nuevas variables epsilon_hat de los modelos (A, B, C)*
		preserve
		foreach model of global models {
			svmat epsilon_hat_model`model'_boot, names(col)
		}

		*Nuevas variables dependientes de los modelos (A, B, C)*
		foreach model of global models {
			generate new_y_star_`model'=beta_model`model'_N`N'*x+c_`model'+u
			generate new_s_star_`model'=gamma1_model`model'_N`N'*w+gamma2_model`model'_N`N'*z+alpha_`model'+epsilon_hat_model`model'_boot
			generate new_s_`model'_obs=(new_s_star_`model'>0)
			generate new_y_`model'=new_y_star_`model'*new_s_`model'_obs
			generate new_s_`model'=new_s_star_`model'*new_s_`model'_obs
		}

		*Nueva estimación de modelos (A, B, C) por Wooldridge (1995) bajo el enfoque de Mundlak (1978)*
		foreach model of global models {
			*Ecuación de interés*
			probit new_s_`model'_obs x mean_x
			predict new_yhat_mundlak_`model', xb
			generate new_lambda_y_mundlak_`model'=normalden(new_yhat_mundlak_`model')/normal(new_yhat_mundlak_`model')
			regress new_y_`model' x mean_x i.t#c.new_lambda_y_mundlak_`model', robust
			scalar beta_model`model'_N`N'_boot=e(b)[1,1]
			*Ecuación de selección*
			probit new_s_`model'_obs w z mean_w mean_z
			predict new_shat_mundlak_`model', xb
			generate new_lambda_s_mundlak_`model'=normalden(new_shat_mundlak_`model')/normal(new_shat_mundlak_`model')
			regress new_s_`model' w z mean_w mean_z i.t#c.new_lambda_s_mundlak_`model', robust
			scalar gamma1_model`model'_N`N'_boot=e(b)[1,1]
			scalar gamma2_model`model'_N`N'_boot=e(b)[1,2]
		}

		*Matriz resultados*
		matrix define params_boot=(beta_modelA_N`N'_boot,gamma1_modelA_N`N'_boot,gamma2_modelA_N`N'_boot,beta_modelB_N`N'_boot,gamma1_modelB_N`N'_boot,gamma2_modelB_N`N'_boot,beta_modelC_N`N'_boot,gamma1_modelC_N`N'_boot,gamma2_modelC_N`N'_boot)
		matrix colnames params_boot="beta_modelA" "gamma1_modelA" "gamma2_modelA" "beta_modelB" "gamma1_modelB" "gamma2_modelB" "beta_modelC" "gamma1_modelC" "gamma2_modelC"
		if (`boot'==1)	matrix define results_boot_N`N'=params_boot
		else			matrix define results_boot_N`N'=(results_boot_N`N'\params_boot)

		restore

	}

	*Base resultados*
	drop _all
	matrix list results_boot_N`N'
	svmat results_boot_N`N', names(col)
	local i=1
	generate boot=.
	forvalues boot=1(1)$reps {
		replace boot=`boot' in `i'
		local i=`i'+1
	}
	order boot, first
	save "results_boot_N`N'", replace

	*Intervalos de confianza de 95%*
	if (`N'==20) {
		matrix define	IC95_boot = J(9,6,.)
		matrix colnames IC95_boot = "modelA_inf" "modelA_sup" "modelB_inf" "modelB_sup" "modelC_inf" "modelC_sup"
	}
	local j=0
	foreach model of global models {
		local i=`n'
		foreach param of global params {
			pctile pctile_`param'_model`model'=`param'_model`model', nquantiles(1000)
			matrix IC95_boot [`i',`j'+1]=pctile_`param'_model`model'[25]
			matrix IC95_boot [`i',`j'+2]=pctile_`param'_model`model'[975]
			local i=`i'+1
		}
		local j=`j'+2
	}

	local n=`n'+3

	noisily display _newline

}

*Resultados finales*

drop _all
matrix list IC95_boot
svmat IC95_boot, names(col)

generate N=.
replace N=20 in 1/3
replace N=40 in 4/6
replace N=100 in 7/9

generate param=""
forvalues i=1(1)9 {
	if (`i'==1 | `i'==4 | `i'==7) replace param="beta" in `i'
	if (`i'==2 | `i'==5 | `i'==8) replace param="gamma1" in `i'
	if (`i'==3 | `i'==6 | `i'==9) replace param="gamma2" in `i'
}

order N param, first
save "results_boot_IC95", replace


*INTERVALOS DE CONFIANZA A PARTIR DE LA MATRIZ DE VARIANZAS Y COVARIANZAS ASINTÓTICA*


local n=1
quietly foreach N of global samples {

	noisily display as text "Intervalos de confianza de 95% a partir de la matriz de varianzas y covarianzas asintóticas con tamaño de muestra N=" as result `N'

	*Random multivariate normal distribution vectors*
	foreach model of global models {
		foreach var of newlist y s {
			local ceros_`var'_model`model'_N`N'=""
			local K`var'_model`model'_N`N'=K`var'_model`model'_N`N'
			forvalues i=1(1)`K`var'_model`model'_N`N'' {
				if (`i'!=K`var'_model`model'_N`N') local ceros_`var'_model`model'_N`N'="`ceros_`var'_model`model'_N`N''0,"
				if (`i'==K`var'_model`model'_N`N') local ceros_`var'_model`model'_N`N'="`ceros_`var'_model`model'_N`N''0"
			}
			set seed $seed
			rmvnormal, mean("`ceros_`var'_model`model'_N`N''") sigma(V`var'_model`model'_N`N') n(${reps})
			matrix define V`var'_model`model'_N`N'_rmvnormal=r(rmvnormal)
		}
	}

	*Matriz resultados*
	forvalues boot=1(1)$reps {
		noisily display as result "`boot' " _continue
		foreach model of global models {
			scalar beta_model`model'_N`N'_var=beta_model`model'_N`N'+Vy_model`model'_N`N'_rmvnormal[`boot',1]
			scalar gamma1_model`model'_N`N'_var=gamma1_model`model'_N`N'+Vs_model`model'_N`N'_rmvnormal[`boot',1]
			scalar gamma2_model`model'_N`N'_var=gamma2_model`model'_N`N'+Vs_model`model'_N`N'_rmvnormal[`boot',2]
		}
		matrix define params_var=(beta_modelA_N`N'_var,gamma1_modelA_N`N'_var,gamma2_modelA_N`N'_var,beta_modelB_N`N'_var,gamma1_modelB_N`N'_var,gamma2_modelB_N`N'_var,beta_modelC_N`N'_var,gamma1_modelC_N`N'_var,gamma2_modelC_N`N'_var)
		matrix colnames params_var="beta_modelA" "gamma1_modelA" "gamma2_modelA" "beta_modelB" "gamma1_modelB" "gamma2_modelB" "beta_modelC" "gamma1_modelC" "gamma2_modelC"
		if (`boot'==1)	matrix define results_var_N`N'=params_var
		else			matrix define results_var_N`N'=(results_var_N`N'\params_var)
	}

	*Base resultados*
	drop _all
	matrix list results_var_N`N'
	svmat results_var_N`N', names(col)
	local i=1
	generate boot=.
	forvalues boot=1(1)$reps {
		replace boot=`boot' in `i'
		local i=`i'+1
	}
	order boot, first
	save "results_var_N`N'", replace

	*Intervalos de confianza de 95%*
	if (`N'==20) {
		matrix define	IC95_var = J(9,6,.)
		matrix colnames IC95_var = "modelA_inf" "modelA_sup" "modelB_inf" "modelB_sup" "modelC_inf" "modelC_sup"
	}
	local j=0
	foreach model of global models {
		local i=`n'
		foreach param of global params {
			pctile pctile_`param'_model`model'=`param'_model`model', nquantiles(1000)
			matrix IC95_var [`i',`j'+1]=pctile_`param'_model`model'[25]
			matrix IC95_var [`i',`j'+2]=pctile_`param'_model`model'[975]
			local i=`i'+1
		}
		local j=`j'+2
	}

	local n=`n'+3

	noisily display _newline

}

*Resultados finales*

drop _all
matrix list IC95_var
svmat IC95_var, names(col)

generate N=.
replace N=20 in 1/3
replace N=40 in 4/6
replace N=100 in 7/9

generate param=""
forvalues i=1(1)9 {
	if (`i'==1 | `i'==4 | `i'==7) replace param="beta" in `i'
	if (`i'==2 | `i'==5 | `i'==8) replace param="gamma1" in `i'
	if (`i'==3 | `i'==6 | `i'==9) replace param="gamma2" in `i'
}

order N param, first
save "results_var_IC95", replace


*##############################################################################*
************** 2. PROPIEDADES DE MUESTRA FINITA EN PANELES DINÁMICOS ***********
*##############################################################################*


global reps=1000

*PROGRAMA*

program define simulation2, rclass

	*Seteo*
	drop _all
	local N=$N
	local T=${T}+10
	local NT=`N'*`T'
	set obs `NT'
	egen id=seq(), from(1) to(`N') block(`T')
	egen t=seq(), from(1) to(`T')
	xtset id t

	*Variables*
	generate c=.
	forvalues id=1(1)`N' {
		local aux=rnormal()
		replace c=`aux' if (id==`id')
	}
	generate u=rnormal()
	generate v=rnormal(0,0.9^(1/2))
	generate x=0
	replace x=0.8*x[_n-1]+v if (t>=2)
	generate y=0
	replace y=${alpha}*y[_n-1]+${beta}*x+c+u if (t>=2)
	generate yL1=L.y
	generate yL2=L.yL1
	generate yD1=y-y[_n-1]
	generate yL1D1=yL1-yL1[_n-1]
	generate xD1=x-x[_n-1]
	keep if (t>10)
	replace t=t-10
	sort id t

	*LSDV*
	regress y yL1 x i.id, robust
	return scalar alpha_lsdv=e(b)[1,1]
	test yL1=${alpha}
	return scalar pvalue_alpha_lsdv=r(p)
	if (${ej}==6) {
		return scalar beta_lsdv=e(b)[1,2]
		test x=${beta}
		return scalar pvalue_beta_lsdv=r(p)
	}

	*AB GMM1*
	xtabond2 y yL1 x, gmmstyle(L.y) ivstyle(x) robust noleveleq
	return scalar alpha_ab_gmm1=e(b)[1,1]
	test yL1=${alpha}
	return scalar pvalue_alpha_ab_gmm1=r(p)
	if (${ej}==6) {
		return scalar beta_ab_gmm1=e(b)[1,2]
		test x=${beta}
		return scalar pvalue_beta_ab_gmm1=r(p)
	}

	*AB GMM2*
	xtabond2 y yL1 x, gmmstyle(L.y) ivstyle(x) twostep robust noleveleq
	return scalar alpha_ab_gmm2=e(b)[1,1]
	test yL1=${alpha}
	return scalar pvalue_alpha_ab_gmm2=r(p)
	if (${ej}==6) {
		return scalar beta_ab_gmm2=e(b)[1,2]
		test x=${beta}
		return scalar pvalue_beta_ab_gmm2=r(p)
	}

	*BB GMM1*
	xtabond2 y yL1 x, gmmstyle(L.y) ivstyle(x, equation(level)) robust
	return scalar alpha_bb_gmm1=e(b)[1,1]
	test yL1=${alpha}
	return scalar pvalue_alpha_bb_gmm1=r(p)
	if (${ej}==6) {
		return scalar beta_bb_gmm1=e(b)[1,2]
		test x=${beta}
		return scalar pvalue_beta_bb_gmm1=r(p)
	}

	*AH*
	ivregress 2sls yD1 (yL1D1=yL2) xD1, noconstant robust
	return scalar alpha_ah=e(b)[1,1]
	test yL1D1=${alpha}
	return scalar pvalue_alpha_ah=r(p)
	if (${ej}==6) {
		return scalar beta_ah=e(b)[1,2]
		test xD1=${beta}
		return scalar pvalue_beta_ah=r(p)
	}

	*KIVIET*
	xtlsdvc y x, initial(ah) bias(2)
	return scalar alpha_kiviet=e(b)[1,1]
	scalar alpha_lsdvc=e(b)[1,1]
	scalar beta_lsdvc=e(b)[1,2]
	scalar NT=e(N)
	scalar T=e(Tbar)
	scalar N=e(N_g)
	scalar K=colsof(e(b))
	egen mean_y=mean(y), by(id)
	egen mean_yL1=mean(yL1), by(id)
	egen mean_x=mean(x), by(id)
	generate within_y=y-mean_y
	generate within_yL1=yL1-mean_yL1
	generate within_x=yL1-mean_x
	generate e=within_y-alpha_lsdvc*within_yL1-beta_lsdvc*within_x
	matrix accum ZtZ=within_yL1 within_x, noconstant
	matrix accum ete=e, noconstant
	matrix define s2=ete/(NT-N-T-K+1)
	matrix define V=s2*invsym(ZtZ)
	scalar se_alpha_lsdvc=sqrt(V[1,1])
	scalar tstat_alpha=(alpha_lsdvc-${alpha})/se_alpha_lsdvc
	scalar pvalue_alpha=2*ttail(NT-K,abs(tstat_alpha))
	return scalar pvalue_alpha_kiviet=pvalue_alpha
	if (${ej}==6) {
		return scalar beta_kiviet=e(b)[1,2]
		scalar se_beta_lsdvc=sqrt(V[2,2])
		scalar tstat_beta=(beta_lsdvc-${beta})/se_beta_lsdvc
		scalar pvalue_beta=2*ttail(NT-K,abs(tstat_beta))
		return scalar pvalue_beta_kiviet=pvalue_beta
	}

end

*SIMULACIONES*

local models="lsdv ab_gmm1 ab_gmm2 bb_gmm1 ah kiviet"
local exercises="1 2 3 4 5 6 7"
local cols: word count `exercises'

matrix define   params=[0.5,0,30,10\0.5,0,50,10\0.8,0,30,20\0.92,0,30,20\0.5,0,50,30\0.8,1,100,7\0.8,0,100,4]
matrix rownames params="ej1" "ej2" "ej3" "ej4" "ej5" "ej6" "ej7"
matrix colnames params="alpha" "beta" "N" "T"
matrix list params

matrix define   results2 = J(48,`cols',.)
matrix rownames results2 = "media_alpha_lsdv"	 "de_alpha_lsdv"	"rmse_alpha_lsdv"	 "tam_test_alpha_lsdv"		///
						   "media_alpha_ab_gmm1" "de_alpha_ab_gmm1" "rmse_alpha_ab_gmm1" "tam_test_alpha_ab_gmm1"	///
						   "media_alpha_ab_gmm2" "de_alpha_ab_gmm2" "rmse_alpha_ab_gmm2" "tam_test_alpha_ab_gmm2"	///
						   "media_alpha_bb_gmm1" "de_alpha_bb_gmm1" "rmse_alpha_bb_gmm1" "tam_test_alpha_bb_gmm1"	///
						   "media_alpha_ah"		 "de_alpha_ah"		"rmse_alpha_ah"		 "tam_test_alpha_ah"		///
						   "media_alpha_kiviet"  "de_alpha_kiviet"  "rmse_alpha_kiviet2" "tam_test_alpha_kiviet"	///
						   "media_beta_lsdv"	 "de_beta_lsdv"		"rmse_beta_lsdv"	 "tam_test_beta_lsdv"		///
						   "media_beta_ab_gmm1"	 "de_beta_ab_gmm1"	"rmse_beta_ab_gmm1"  "tam_test_beta_ab_gmm1"	///
						   "media_beta_ab_gmm2"  "de_beta_ab_gmm2"	"rmse_beta_ab_gmm2"  "tam_test_beta_ab_gmm2"	///
						   "media_beta_bb_gmm1"  "de_beta_bb_gmm1"	"rmse_beta_bb_gmm1"  "tam_test_beta_bb_gmm1"	///
						   "media_beta_ah"		 "de_beta_ah"		"rmse_beta_ah"		 "tam_test_beta_ah"			///
						   "media_beta_kiviet"   "de_beta_kiviet"	"rmse_beta_kiviet"	 "tam_test_beta_kiviet"
matrix colnames results2 = "ej1" "ej2" "ej3" "ej4" "ej5" "ej6" "ej7"

quietly foreach ej of local exercises {

	noisily display as text "Simulación con parámetros de ejercicio " as result `ej'

	*Simulación*
	global ej=`ej'
	global alpha=params[`ej',1]
	global beta=params[`ej',2]
	global N=params[`ej',3]
	global T=params[`ej',4]
	if (`ej'!=6) simulate alpha_lsdv_ej`ej'	  =r(alpha_lsdv)	pvalue_alpha_lsdv_ej`ej'   =r(pvalue_alpha_lsdv)	///
						  alpha_ab_gmm1_ej`ej'=r(alpha_ab_gmm1)	pvalue_alpha_ab_gmm1_ej`ej'=r(pvalue_alpha_ab_gmm1)	///
						  alpha_ab_gmm2_ej`ej'=r(alpha_ab_gmm2)	pvalue_alpha_ab_gmm2_ej`ej'=r(pvalue_alpha_ab_gmm2)	///
						  alpha_bb_gmm1_ej`ej'=r(alpha_bb_gmm1)	pvalue_alpha_bb_gmm1_ej`ej'=r(pvalue_alpha_bb_gmm1)	///
						  alpha_ah_ej`ej'	  =r(alpha_ah)		pvalue_alpha_ah_ej`ej'	   =r(pvalue_alpha_ah)		///
						  alpha_kiviet_ej`ej' =r(alpha_kiviet)	pvalue_alpha_kiviet_ej`ej' =r(pvalue_alpha_kiviet), reps(${reps}) seed(${seed}): simulation2
	else		 simulate alpha_lsdv_ej`ej'	  =r(alpha_lsdv)	pvalue_alpha_lsdv_ej`ej'   =r(pvalue_alpha_lsdv)	///
						  alpha_ab_gmm1_ej`ej'=r(alpha_ab_gmm1)	pvalue_alpha_ab_gmm1_ej`ej'=r(pvalue_alpha_ab_gmm1)	///
						  alpha_ab_gmm2_ej`ej'=r(alpha_ab_gmm2)	pvalue_alpha_ab_gmm2_ej`ej'=r(pvalue_alpha_ab_gmm2)	///
						  alpha_bb_gmm1_ej`ej'=r(alpha_bb_gmm1)	pvalue_alpha_bb_gmm1_ej`ej'=r(pvalue_alpha_bb_gmm1)	///
						  alpha_ah_ej`ej'	  =r(alpha_ah)		pvalue_alpha_ah_ej`ej'	   =r(pvalue_alpha_ah)		///
						  alpha_kiviet_ej`ej' =r(alpha_kiviet)  pvalue_alpha_kiviet_ej`ej' =r(pvalue_alpha_kiviet)	///
						  beta_lsdv_ej`ej'	  =r(beta_lsdv)	   	pvalue_beta_lsdv_ej`ej'	   =r(pvalue_beta_lsdv)		///
						  beta_ab_gmm1_ej`ej' =r(beta_ab_gmm1)  pvalue_beta_ab_gmm1_ej`ej' =r(pvalue_beta_ab_gmm1)	///
						  beta_ab_gmm2_ej`ej' =r(beta_ab_gmm2)  pvalue_beta_ab_gmm2_ej`ej' =r(pvalue_beta_ab_gmm2)	///
						  beta_bb_gmm1_ej`ej' =r(beta_bb_gmm1)  pvalue_beta_bb_gmm1_ej`ej' =r(pvalue_beta_bb_gmm1)	///
						  beta_ah_ej`ej'	  =r(beta_ah)		pvalue_beta_ah_ej`ej'	   =r(pvalue_beta_ah)		///
						  beta_kiviet_ej`ej'  =r(beta_kiviet)	pvalue_beta_kiviet_ej`ej'  =r(pvalue_beta_kiviet), reps(${reps}) seed(${seed}): simulation2

	*Base resultados*
	generate n=_n
	if (`ej'!=1) {
		merge 1:1 n using "results2_base"
		drop _merge
	}
	order _all, sequential
	order n, first
	save "results2_base", replace

	*Matriz resultados*
	local i=0
	foreach model of local models {
		summarize alpha_`model'_ej`ej'
		matrix results2 [`i'+1,`ej']=r(mean)
		matrix results2 [`i'+2,`ej']=r(sd)
		generate rmse_`model'_alpha=(alpha_`model'_ej`ej'-${alpha})^2
		summarize rmse_`model'_alpha
		matrix results2 [`i'+3,`ej']=sqrt(r(mean))
		count if (pvalue_alpha_`model'_ej`ej'<0.01)
		matrix results2 [`i'+4,`ej']=r(N)/${reps}*100
		local i=`i'+4
	}
	if (`ej'==6) {
		foreach model of local models {
			summarize beta_`model'_ej`ej'
			matrix results2 [`i'+1,`ej']=r(mean)
			matrix results2 [`i'+2,`ej']=r(sd)
			generate rmse_`model'_beta=(beta_`model'_ej`ej'-${beta})^2
			summarize rmse_`model'_beta
			matrix results2 [`i'+3,`ej']=sqrt(r(mean))
			count if (pvalue_beta_`model'_ej`ej'<0.01)
			matrix results2 [`i'+4,`ej']=r(N)/${reps}*100
			local i=`i'+4
		}
	}

}

*RESULTADOS FINALES*

drop _all
matrix list results2
matrix define results2_t=results2'
svmat results2_t, names(col)

local i=1
generate ej=.
foreach ej of local exercises {
	replace ej=`ej' in `i'
	local i=`i'+1
}

order ej, first
save "results2_matriz", replace


*##############################################################################*
*************** 3. ELASTICIDAD PRECIO DE DEMANDA DE LOS CIGARRILLOS ************
*##############################################################################*


use "cigs", clear
describe

xtset state year
xtdescribe

local vars="ln_price ndi cpi pop16"


********************************************************************************
								* EJERCICIO 1 *
********************************************************************************


generate ln_sales=ln(sales)
generate ln_price=ln(price)

regress ln_sales `vars', robust
estimates store est_pols


********************************************************************************
								* EJERCICIO 2 *
********************************************************************************


xtreg ln_sales `vars', fe
estimates store est_fe
matrix define b_fe=e(b)
matrix define V_fe=e(V)

xtreg ln_sales `vars', re
estimates store est_re
matrix define b_re=e(b)
matrix define V_re=e(V)

hausman est_fe est_re

matrix define V=V_fe-V_re
matrix list V
matrix eigenvalues r c=V
matrix list r						/* Efectivamente, la matriz V no es positiva definida */
matrix list c

matselrc V VV, row(1 2 4) col(1 2 4)
matrix list VV
matrix eigenvalues r c=VV
matrix list r						/* Excluyendo las variables que varían sólo a través del tiempo (cpi), el problema persiste (VV no es positiva definida) */
matrix list c

hausman est_fe est_re, sigmamore	/* Se utilizan versiones más robustas de este test, ya que la matriz V (y VV) no es positiva definida */
hausman est_fe est_re, sigmaless	/* En ambos casos, se rechaza la hipótesis nula */

xtreg ln_sales `vars', fe robust
estimates store est_fe


********************************************************************************
								* EJERCICIO 3 *
********************************************************************************


ivregress 2sls D.ln_sales (D.(L.ln_sales)=L2.ln_sales) D.(`vars'), noconstant robust
estimates store est_iv


********************************************************************************
								* EJERCICIO 4 *
********************************************************************************


xtabond2 ln_sales L.ln_sales `vars', gmmstyle(L.ln_sales, collapse) ivstyle(`vars') robust noleveleq
estimates store est_gmm_os
xtabond2 ln_sales L.ln_sales `vars', gmmstyle(L.ln_sales, collapse) ivstyle(`vars') twostep robust noleveleq
estimates store est_gmm_ts

esttab est_pols est_fe est_iv est_gmm_os est_gmm_ts, se star(* 0.10 ** 0.05 *** 0.01) stats(N r2) mtitles("POLS" "FE" "IV" "GMM (One-Step)" "GMM (Two-Step)")


log close