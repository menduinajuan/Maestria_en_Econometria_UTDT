/******************************************************************
                  TEST DE NORMALIDAD MULTIVARIADA
*******************************************************************/


capture program drop mvnorm

program define mvnorm

          syntax varlist(max=25) , confianza(real)
          
          local p: word count `varlist'
          local N = _N
          
          tokenize `varlist'
           
          forvalues i= 1(1) `p' {
								tempvar var_`i'
								gen `var_`i'' = ``i''
								}
				   
/*MEDIAS*/
          matrix vector_medias = J(`p',1,.)
          matrix vector_sd = J(`p',1,.)
                  forvalues i=1(1)`p' {
										quietly sum `var_`i''
										matrix vector_medias [`i', 1] = r(mean)
										matrix vector_sd [`i', 1] = r(sd)
										}

/*MATRIZ DE VARIANZAS Y COVARIANZAS*/
          quietly matrix accum aux = `varlist', deviation nocons
          mat S = aux/(_N-1)
          mat S_inv =inv(S)

quietly forvalues i=1(1) `N' {
								mkmat `varlist' in `i', matrix(x_`i')
								mat x_`i'_tr = (x_`i')'
          
								}

quietly forvalues i=1(1) `N' {
								tempvar aux_`i'
								gen `aux_`i''=.
								}

/*COEFICIENTE DE ASIMETRÍA MULTIVARIADA*/

quietly forvalues i=1(1) `N' {
								forvalues j=1(1) `N' {
														mat A = ((x_`i'_tr-vector_medias)')*S_inv*((x_`j'_tr-vector_medias))
														local a = el(A,1,1)^(3)
														replace `aux_`i''= `a' in `j'
													}
								}


quietly forvalues i= 1(1) `N' {
								egen sum_aux_`i' = sum(`aux_`i'')
							   }



mkmat sum_aux_* in 1, matrix(sumas)
mat sumas_trasp = sumas'
svmat sumas_trasp

egen suma = sum(sumas_trasp)
mkmat suma, mat(M)

local Asimetria = el(M, 1,1)/((`N')^(2))

display in yellow "----------Asimetria-----------------"
display in green  " Ap   = `Asimetria'"
display in yellow "------------------------------------"

drop sum_aux_* sumas_trasp1 suma
mat drop sumas M
							   
/*COEFICIENTE DE KURTOSIS MULTIVARIADA*/

quietly forvalues i=1(1) `N' {
								replace `aux_`i''=.
							  }


quietly forvalues i=1(1) `N' {
								mat A = ((x_`i'_tr-vector_medias)')*S_inv*((x_`i'_tr-vector_medias))
								local a = el(A,1,1)^(2)
								replace `aux_`i''= `a' in `i'
							}


quietly forvalues i= 1(1) `N' {
								egen sum_aux_`i' = sum(`aux_`i'')
							  }

mkmat sum_aux_* in 1, matrix(sumas)
mat sumas_trasp = sumas'
svmat sumas_trasp

egen suma = sum(sumas_trasp)
mkmat suma, mat(M)

local Kurtosis = el(M, 1,1)/`N'

display in yellow "----------Kurtosis------------------"
display in green " Kp   = `Kurtosis'"
display in yellow "------------------------------------"

drop sum_aux_* sumas_trasp1 suma
mat drop sumas M

/*TESTS DE ASIMETRIA, KURTORIS Y NORMALIDAD MULTIVARIADOS*/

local f = ((`p'*(`p'+1)*(`p'+2))/6)
local u = `p'*(`p'+2)
local v = (8*`p'*(`p'+2))/`N'

display in red "---------TEST-----------------------"

display in yellow "---------Asimetria------------------"
local statistic = ((`N'*`Asimetria')/6)
di in green "Estadistico = `statistic'"
local valor_critico = invchi2((`f'), (1-`confianza'))
di in green "Valor critico (`confianza') = `valor_critico'"
local pvalue = chi2tail((`f'), `statistic')
di in green "p-value = `pvalue'"

display in yellow "---------Kurtosis-------------------"
local statistic = (`Kurtosis'-`u')/(`v'^(1/2))
di in green "Estadistico = `statistic'"
local valor_critico = invnormal(1-(`confianza')/2)
di in green "Valor critico (`confianza') = `valor_critico'"
local pvalue = 2*(1-normal(abs(`statistic')))
di in green "p-value = `pvalue'"

display in yellow "---------Conjunto-------------------"
local statistic = ((`N'*`Asimetria')/6)+((`Kurtosis'-`u')/(`v'^(1/2)))^(2)
di in green "Estadistico = `statistic'"
local gl = `f'+1
local valor_critico = invchi2((`gl'), (1-`confianza'))
di in green "Valor critico (`confianza') = `valor_critico'"
di in green "Grados de lib. = (`gl')"
local pvalue = chi2tail((`gl'), `statistic')
di in green "p-value = `pvalue'"
display in yellow "------------------------------------"

end