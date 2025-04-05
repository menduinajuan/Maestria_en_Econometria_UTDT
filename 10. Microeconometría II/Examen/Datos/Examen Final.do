clear all
set more off
set graphics off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/10. Microeconometría II/Examen/Datos"


/*
ssc install csdid, replace
ssc install did_imputation, replace
ssc install gtools, replace
ssc install jwdid, replace
ssc install reghdfe, replace
*/


global seed=02205


*##############################################################################*
*************************** DATA-GENERATING PROCESSES **************************
*##############################################################################*


*Globales*
global reps=100
global models="hom het"
global estims="twfe cs bjs jw"
global samples="50 500"
global periods="2 4 6 8 10 12 14 16 18 20 22 24 26 28 30"
global ATTs="0.2 0.5 0.8"
global results="figure3 figure5 table3 figure11"

*Locales*
local n_models: word count $models
local n_estims: word count $estims
local n_atts: word count $ATTs
local rows=`n_models'*`n_estims'*`n_atts'
local cols: word count $periods
local T_ini: word 1 of $periods
local att_ini: word 1 of $ATTs
local conf=0.95
local alpha=1-`conf'
local z=invnormal(1-`alpha'/2)


********************************************************************************
								* PROGRAMA *
********************************************************************************


program define simulation, rclass

	*Seteo*
	drop _all
	local N=$N
	local T=$T
	local NT=`N'*`T'
	set obs `NT'
	gegen id=seq(), from(1) to(`N') block(`T')
	gegen t=seq(), from(1) to(`T')
	xtset id t

	*Efectos fijos por id*
	generate alpha=id/10

	*Efectos fijos por t*	
	gsort t
	generate gamma=.
	by t: replace gamma=rnormal() if (_n==1)
	by t: replace gamma=gamma[_n-1] if (_n>1)

	*Término de error*
	generate epsilon=rnormal()

	*Variables de tratamiento del modelo homogéneo*
	gsort id t
	generate Treated=(id>`N'/2)
	generate g_hom=0
	by id: replace g_hom=1+ceil(runiform()*(`T'-1)) if (Treated==1 & _n==1)
	by id: replace g_hom=g_hom[_n-1] if (Treated==1 & _n>1)
	clonevar g_hom_m=g_hom
	replace g_hom_m=. if (g_hom==0)
	generate Post_hom=0
	replace Post_hom=(t>=g_hom) if (Treated==1)
	generate D_hom=Treated*Post_hom

	*Variables de tratamiento del modelo heterogéneo*
	generate g_het=0
	local delta=round((`N'/2)/(`T'-1))
	replace g_het=2+int((id-(`N'/2+1))/`delta') if (Treated==1)
	clonevar g_het_m=g_het
	replace g_het_m=. if (g_het==0)
	gegen mean_effect=mean(id-`N'/2) if (g_het>0)
	generate tau=0
	replace tau=(id-`N'/2)*(${att}/mean_effect) if (Treated==1)
	replace tau=tau-10*${att} if (id>=`N'/2+1 & id<=`N'/2*1.2)
	replace tau=tau+5*10*${att} if (id>`N'*0.98)
	generate Post_het=0
	replace Post_het=(t>=g_het) if (Treated==1)
	generate D_het=Treated*Post_het

	*Variable dependiente de los modelos (homogéneo y heterogéneo)*
	generate y_hom=${att}*D_hom+alpha+gamma+epsilon
	generate y_het=tau*D_het+alpha+gamma+epsilon

	*Estimaciones*
	foreach model of global models {
		*TWFE*
		reghdfe y_`model' D_`model', absorb(id t) vce(cluster id)
		return scalar att_`model'_twfe=e(b)[1,1]
		return scalar se_`model'_twfe=sqrt(e(V)[1,1])
		*CS*
		csdid y_`model', ivar(id) time(t) gvar(g_`model') method(reg)
		estat simple
		return scalar att_`model'_cs=r(b)[1,1]
		return scalar se_`model'_cs=sqrt(r(V)[1,1])
		*BJS*
		did_imputation y_`model' id t g_`model'_m, minn(0)
		return scalar att_`model'_bjs=e(b)[1,1]
		return scalar se_`model'_bjs=sqrt(e(V)[1,1])
		*JW*
		capture jwdid y_`model', ivar(id) tvar(t) gvar(g_`model') never group
		estat simple
		return scalar att_`model'_jw=r(b)[1,1]
		return scalar se_`model'_jw=sqrt(r(V)[1,1])
	}

end


********************************************************************************
								* SIMULACIONES *
********************************************************************************


quietly foreach N of global samples {

	*Generar matrices resultados*
	foreach result of global results {
		if ("`result'"=="figure3")	local name="ATT_Bias"
		if ("`result'"=="figure5")  local name="SE_Bias"
		if ("`result'"=="table3")	local name="Coverage_Proba"
		if ("`result'"=="figure11") local name="Statistical_Power"
		matrix define	results_N`N'_`result' = J(`rows',`cols',.)
		matrix rownames results_N`N'_`result' = "`name'_att2_hom_twfe" "`name'_att5_hom_twfe" "`name'_att8_hom_twfe"	///
												"`name'_att2_hom_cs"   "`name'_att5_hom_cs"   "`name'_att8_hom_cs"		///
												"`name'_att2_hom_bjs"  "`name'_att5_hom_bjs"  "`name'_att8_hom_bjs"		///
												"`name'_att2_hom_jw"   "`name'_att5_hom_jw"   "`name'_att8_hom_jw"		///
												"`name'_att2_het_twfe" "`name'_att5_het_twfe" "`name'_att8_het_twfe"	///
												"`name'_att2_het_cs"   "`name'_att5_het_cs"   "`name'_att8_het_cs"		///
												"`name'_att2_het_bjs"  "`name'_att5_het_bjs"  "`name'_att8_het_bjs"		///
												"`name'_att2_het_jw"   "`name'_att5_het_jw"   "`name'_att8_het_jw"
		matrix colnames results_N`N'_`result' = "T_2" "T_4" "T_6" "T_8" "T_10" "T_12" "T_14" "T_16" "T_18" "T_20" "T_22" "T_24" "T_26" "T_28" "T_30"
	}

	*Correr simulaciones para N*
	local i=1
	foreach T of global periods {

		local j=1
		foreach att of global ATTs {

			noisily display as text "Simulación: N=" as result `N' as text " - T=" as result `T' as text " - ATT=" as result `att'

			*Simulación*
			global N=`N'
			global T=`T'
			global att=`att'
			local att_aux=mod(floor(`att'*10),10)
			simulate att_hom_twfe_T`T'_att`att_aux'=r(att_hom_twfe) att_het_twfe_T`T'_att`att_aux'=r(att_het_twfe)	///
					 att_hom_cs_T`T'_att`att_aux'  =r(att_hom_cs)	att_het_cs_T`T'_att`att_aux'  =r(att_het_cs)	///
					 att_hom_bjs_T`T'_att`att_aux' =r(att_hom_bjs)	att_het_bjs_T`T'_att`att_aux' =r(att_het_bjs)	///
					 att_hom_jw_T`T'_att`att_aux'  =r(att_hom_jw)	att_het_jw_T`T'_att`att_aux'  =r(att_het_jw)	///
					 se_hom_twfe_T`T'_att`att_aux' =r(se_hom_twfe)	se_het_twfe_T`T'_att`att_aux' =r(se_het_twfe)	///
					 se_hom_cs_T`T'_att`att_aux'   =r(se_hom_cs)	se_het_cs_T`T'_att`att_aux'   =r(se_het_cs)		///
					 se_hom_bjs_T`T'_att`att_aux'  =r(se_hom_bjs)	se_het_bjs_T`T'_att`att_aux'  =r(se_het_bjs)	///
					 se_hom_jw_T`T'_att`att_aux'   =r(se_hom_jw)	se_het_jw_T`T'_att`att_aux'   =r(se_het_jw), reps(${reps}) seed(${seed}): simulation

			*Guardar en matrices resultados*
			local k=0
			foreach model of global models {
				local l=0
				foreach estim of global estims {
					local name="`model'_`estim'_T`T'_att`att_aux'"
					*Figure 3 (ATT Bias)*
					summarize att_`name'
					local att_mean=r(mean)
					matrix results_N`N'_figure3 [`j'+`k'+`l',`i']=`att_mean'-`att'
					*Figure 5 (SE Bias)*
					summarize se_`name'
					local se_att_mean=r(mean)
					summarize att_`name'
					local sd_att=r(sd)
					matrix results_N`N'_figure5 [`j'+`k'+`l',`i']=`se_att_mean'-`sd_att'
					*Table 3 (Coverage Probability)*
					generate ic_inf_`name'=att_`name'-`z'*se_`name'
					generate ic_sup_`name'=att_`name'+`z'*se_`name'
					count if (`att'>=ic_inf_`name' & `att'<=ic_sup_`name')
					matrix results_N`N'_table3 [`j'+`k'+`l',`i']=r(N)/${reps}
					*Figure 11 (Statistical Power)*
					generate t_`name'=att_`name'/`sd_att'
					generate p_`name'=2*ttail(`N'-1,abs(t_`name'))
					count if (p_`name'<`alpha')
					matrix results_N`N'_figure11 [`j'+`k'+`l',`i']=r(N)/${reps}
					local l=`l'+`n_atts'
				}
				local k=`k'+`n_atts'*`n_estims'
			}

			*Guardar base resultados actualizada*
			generate n=_n
			if !(`T'==`T_ini' & `att'==`att_ini') {
				merge 1:1 n using "results_N`N'_base"
				drop _merge
			}
			order _all, sequential
			order n, first
			save "results_N`N'_base", replace

			local j=`j'+1

		}

		local i=`i'+1

	}

	*Guardar matrices resultados*
	foreach result of global results {
		drop _all
		matrix list results_N`N'_`result'
		matrix define results_N`N'_`result'_t=results_N`N'_`result''
		svmat results_N`N'_`result'_t, names(col)
		local i=1
		generate T=.
		foreach T of global periods {
			replace T=`T' in `i'
			local i=`i'+1
		}
		order T, first
		save "results_N`N'_matriz_`result'", replace
	}

}


*##############################################################################*
********************************** EJERCICIOS **********************************
*##############################################################################*


quietly foreach N of global samples {

	foreach result of global results {

		noisily display as text "Corriendo: N=" as result `N' as text " - result=" as result "`result'"

		use "results_N`N'_matriz_`result'", replace

		if ("`result'"=="figure3") {
			local var="ATT_Bias"
			local yline=0
		}
		if ("`result'"=="figure5") {
			local var="SE_Bias"
			local yline=0
		}
		if ("`result'"=="figure11") {
			local var="Statistical_Power"
			local yline=0.8
			local y_min=0
			local y_max=1
			local delta=0.2
		}

		*FIGURE 3, FIGURE 5 Y FIGURE 11*

		if ("`result'"!="table3") {

			foreach att of global ATTs {

				local att_aux=mod(floor(`att'*10),10)

				foreach model of global models {

					if ("`model'"=="hom") {
						local m="Constant Effects"
						if ("`result'"=="figure3") {
							local y_min=-0.2
							local y_max=0.2
							local delta=0.1
						}
						if ("`result'"=="figure5") {
							local y_min=-0.1
							local y_max=0.1
							local delta=0.05
						}
					}
					if ("`model'"=="het") {
						local m="Heterogeneous Effects"
						if ("`result'"=="figure3" & `N'==50) {
							local y_min=-4.0
							local y_max=0.5
							local delta=0.5
						}
						if ("`result'"=="figure5" & `N'==50) {
							local y_min=-0.3
							local y_max=1.5
							local delta=0.3
						}
						if ("`result'"=="figure3" & `N'==500) {
							local y_min=-3.0
							local y_max=0.5
							local delta=0.5
						}
						if ("`result'"=="figure5" & `N'==500) {
							local y_min=-0.1
							local y_max=0.5
							local delta=0.1
						}
					}

					local ytitle=subinstr("`var'","_"," ",.)

					graph twoway (line `var'_att`att_aux'_`model'_twfe T, lcolor(black))								///
								 (line `var'_att`att_aux'_`model'_cs   T, lcolor(blue))									///
								 (line `var'_att`att_aux'_`model'_bjs  T, lcolor(green))								///
								 (line `var'_att`att_aux'_`model'_jw   T, lcolor(orange)),								///
								 title("ATT=`att' - `m'", color(black)) ytitle(`ytitle') xtitle("Time Periods")			///
								 yline(`yline', lcolor(red)) ylabel(`y_min'(`delta')`y_max', angle(0)) xlabel(2(4)30)	///
								 legend(label(1 "TWFE") label(2 "CS") label(3 "BJS") label(4 "JW") rows(1))				///
								 graphregion(color(white))

					graph save 	 "../Figuras/`result'_N`N'_att`att_aux'_`model'.gph", replace
					graph export "../Figuras/`result'_N`N'_att`att_aux'_`model'.png", replace

				}

			}

		}

		*TABLE 3*

		else {

			local var="Coverage_Proba"
			local att_aux="5"
			local periods="2 10 20 30"
			local rows: word count `periods'
			local cols=`n_models'*`n_estims'
			matrix define	`result'_N`N' = J(`rows',`cols',.)
			matrix rownames `result'_N`N' = "T_2" "T_10" "T_20" "T_30"
			matrix colnames `result'_N`N' = "TWFE_hom" "CS_hom" "BJS_hom" "JW_hom" "TWFE_het" "CS_het" "BJS_het" "JW_het"

			local i=1
			foreach T of local periods {
				local j=0
				foreach model of global models {
					local k=1
					foreach estim of global estims {
						summarize `var'_att`att_aux'_`model'_`estim' if (T==`T')
						matrix `result'_N`N' [`i',`j'+`k']=round(r(mean),0.001)
						local k=`k'+1
					}
					local j=`j'+`n_estims'
				}
				local i=`i'+1
			}

			noisily matrix list `result'_N`N'

		}

	}

}