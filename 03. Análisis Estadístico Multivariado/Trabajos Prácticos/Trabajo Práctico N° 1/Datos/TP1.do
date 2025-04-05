/*==============================================================================
 Analisis Estadistico Multivariado - UTDT 
 Problem Set 1

 Fiona Franco Churruarín 
===============================================================================*/

* Settings

cap log close 
clear all 
set more off, permanently 

cd "C:\Users\fionafch\Dropbox\Materias MAECO\Análisis Estadístico Multivariado\Clases Practicas\PS1"

*log using "./logs/PS_1_Ej1_Solucion.smcl"

*-------------------------------------------------------------------------------
**# Ejercicio 1
*-------------------------------------------------------------------------------

use eurosec, clear

describe

label variable pais "País" 
label variable s1 "Agricultura" 
label variable s2 "Minería"
label variable s3 "Industria"
label variable s4 "Energía"
label variable s5 "Construcción"
label variable s6 "Servicios Industriales"
label variable s7 "Finanzas"
label variable s8 "Servicios"
label variable s9 "Transporte y Telecomunicaciones"


* 1) a) ------------------------------------------------------------------------

* Media, varianza y coeficiente de variacion de cada variable

** Saquemos los valores
summarize s*, detail
summarize s1 s2 s3 s4 s5 s6 s7 s8 s9, detail
summarize s1-s9, detail // Depende del orden de la base

** Otra forma:
tabstat s*, stat(mean variance sd cv) 


* 1) b) ------------------------------------------------------------------------

* Computamos la matriz de covariazas
correlate s1 s2 s3 s4 s5 s6 s7 s8 s9, covariance

* Que resultados esta guardando Stata?
return list

* Definimos un objeto matriz con la matriz de covarianzas
matrix S = r(C)

matrix list S


* 1) c) ------------------------------------------------------------------------

* Para computar las medidas globables de variabilidad tenemos que operar con matrices

* Vamos a computar: varianza total, generalizada, media, efectiva 

mkmat s1 s2 s3 s4 s5 s6 s7 s8 s9, matrix(X)
matrix list X

local F = rowsof(X) // numero, texto, etc, que desaparece despues de correrlo
local C = colsof(X)

**	Varianza total
local var_total = trace(S)
display `var_total'

**	Varianza media
local var_media = `var_total'/`C'
display  `var_media'

**	Varianza generalizada 
local var_gen = det(S)
display `var_gen'

**	Varianza efectiva
local var_efec = (det(S))^(1/`C')
display `var_efec'

** Todas:
display " VT= `var_total'; VM=`var_media'; VG=`var_gen'; VE=`var_efec'"

* 1) d) ------------------------------------------------------------------------

* Ahora queremos la matriz de correlaciones
correlate s1 s2 s3 s4 s5 s6 s7 s8 s9


* 1) e) ------------------------------------------------------------------------

* regress y x1 x2 ... xK
regress s2 s1 s3 s4 s5 s6 s7 s8 s9

//	Guido:
//	1)	Regress performs ordinary least-squares linear regression.

/*-------------------------------------------------------------------------*
|	Guido:
|	1)	Stata commands are classified as being:
|			-	r-class general commands that store results in r()
|			-	e-class estimation commands that store results in e()
|			-	s-class parsing commands that store results in s()
|			-	n-class commands that do not store in r(), e(), or s()
|		e-class is really no different from r-class, except for where results 
|		are stored.
|		s-class is used solely by programmers, so ignore it.
|	2)	Returned results from previous commands are replaced by subsequent 
|		commands of the same class. Try the following:
|			regress s2 s1 
|			ereturn list
|			regress s2 s4
|			ereturn list
|			summarize s1
|			return list
|			summarize s2
|			return list
*-------------------------------------------------------------------------*/

ereturn list


local R2_reg = e(r2)
display `R2_reg'

//	1)	Obtuvimos el coeficiente de determinacion.

estimate store Mod1					

* Queremos los residuos 
predict resid_s2, residuals


//	1)	Predict calculates predictions, residuals, influence statistics, and the 
//		like after estimation. Exactly what predict can do is determined by the 
//		previous estimation command (and the option specified).
//	2)	Here we saved the residuals of the regression, which can also be 
//		obtained by the following commands: 
//		predict b, xb           ->	linear prediction from the fitted model.
//		generate c = s2 - b
//	3)	Check the database: now we have a new variable called resid_s2. Hence
//		we can summarize it, use it in computations and so on.

summarize resid_s2, detail //uhat2
return list
display r(Var)


//	Guido:
//	1)	Obtuvimos la varianza de los residuos a partir de la regresion. 

//	Pregunta 1: Es posible obtener la varianza de los residuos a partir de la 
//	matriz de varianzas y covarianzas S ? 
//	Respuesta: Si. 
//	Proof:

* Calculamos S inversa
mat S_inv = inv(S)
matlist S_inv

local S_inv_22 = el(S_inv, 2, 2) // el=element
display `S_inv_22'

//	1) 	el(M,i,j) me busca el elemento i,j de la matriz M

local var_resid_S = 1/`S_inv_22'
display `var_resid_S'
display `var_resid_reg'

* Con esa cuenta obtuvimos var(uhat2) contra todas las demas a partir de la matriz de precision. Nos da una intuicion de que tiene la matriz de precision en la diagonal principal. Son los valores (inversos) de la varianza de cada variable controlando por todas las demas, 1/var(uhat2) = S^{-1}[2,2]

//	Pregunta 2: Es posible obtener el coeficiente de determinacion a partir de
//	la matriz de varianzas y covarianzas S ?
//	Respuesta: Si.
//	Proof:

local R2_S = 1 - 1/( el(S, 2,2) * el(S_inv, 2,2) ) 
display `R2_S'

drop resid_s2


* 1) f) ------------------------------------------------------------------------

* Con un comando
pcorr s1 s2 s3 s4 s5 s6 s7 s8 s9 //pcorr y x1 ... xK = partial correlations


* A mano 
regress s1 s3 s4 s5 s6 s7 s8 s9
predict resid_s1, residuals 

regress s2 s3 s4 s5 s6 s7 s8 s9
predict resid_s2, residuals 

correlate resid_s1 resid_s2 
return list
display r(rho) // Coeficiente de correlación parcial

//	Using S^(-1) matrix:
local r_12 = -(el(S_inv, 1,2)/sqrt(el(S_inv, 2,2)*el(S_inv, 1,1))) // Coeficiente de correlación parcial
display `r_12'


* 1) g) ------------------------------------------------------------------------

corr s*
mat S = r(C) 
display det(S)   // det = producto de autovalores
display trace(S) // traza = suma de autovalores = cantidad de variables				
 					    
matrix symeigen Avec Aval = S 
//	Guido:
//	1)	Matrix symeigen X v = A ;  where A is an n x n symmetric matrix. It 
//		creates matrix "Avec" containing the eigenvectors of CORR and vector 
//		"Aval" containing the eigenvalues of CORR.
//	2) 	Matrix symeigen returns the eigenvectors in the columns of X_n×n 
//		(SYMETRIC) and the corresponding eigenvalues in v_1×n. The eigenvalues 
//		are sorted: v[1,1] contains the largest eigenvalue (and X[1...,1] its 
//		corresponding eigenvector), and v[1,n] contains the smallest eigenvalue 
//		(and X[1...,n] its corresponding eigenvector).

matrix list Aval	

//	Question: Existe alguna relacion entre el numero de variables y los mismos ?

//	Answer: The correlation matrix is standardized and the average eigenvalue is 
//	equal to 1. Therefore, the sum of the eigenvalues = number of variables.

//	Proof:
//	Just sum the eigenvalues: 

local p = el(Aval,1,1) + el(Aval,1,2) + el(Aval,1,3) + el(Aval,1,4) + ///
el(Aval,1,5)+ el(Aval,1,6) + el(Aval,1,7) + el(Aval,1,8) + el(Aval,1,9) 

display `p'


* 1) h) ------------------------------------------------------------------------
 
//	Coeficiente de dependencia efectiva: recordar que |R_p| mide dependencia conjunta

/* D(R_p)=1-|R_p|^{1/(p-1)} */

local F = rowsof(X) // numero, texto, etc, que desaparece despues de correrlo
local C = colsof(X)

local coef_dep_efec = 1-(det(S))^(1/(`C'-1))
di `coef_dep_efec'
















** Como podemos operar con esto? Los guardamos. Como son muchos, usamos vectores

*** Preasignacion

* Generamos matriz con datos

local F = rowsof(X) 
local C = colsof(X) 
matrix vector_medias = J(`C',1,.)
matrix vector_var = J(`C',1,.)
matrix vector_cv = J(`C',1,.) 

local C = colsof(X) 
forvalues i=1(1)`C' {
	summarize s`i'
	matrix vector_medias [`i', 1] = r(mean)
    matrix vector_var [`i', 1] = r(Var)		//Var not var
    matrix vector_cv [`i', 1] = r(sd)/r(mean)
}




local F = rowsof(X) 

matrix uno = J(`F',1,1)
//	Guido:
//	1)	Vector all filled with 1.
matrix I = I(`F')
//	Guido:
//	1)	Identity matrix FxF.
matrix P = I - (1/`F')*uno*uno'
//	Guido:
//	1)	As P matrix is symmetric, Stata doesn't need to show you all the matrix.
matrix S = (1/`F')*X'*P*X
matrix list S
//	Guido:
//	1)	Notice the values are not equal to those obtained by correlate s*, covariance
//		That happens because correlate s*, covariance uses n-1 instead of n.
//	2)	Try the following and you will get the same results:
		matrix drop S
		matrix S = (1/(`F'-1))*X'*P*X
		matrix list S


/*==============================================================================
 Analisis Estadistico Multivariado - UTDT 
 Problem Set 1

 Fiona Franco Churruarín 
===============================================================================*/

* Settings

cap log close 
clear all 
set more off, perma
cd "C:\Users\fionafch\Dropbox\Materias MAECO\Análisis Estadístico Multivariado\Clases Practicas\PS1"


*-------------------------------------------------------------------------------
**# Ejercicio 2
*-------------------------------------------------------------------------------

use individual_t410.dta, clear

* Primero inspeccionemos la base
describe
*browse

* Queremos armar el dataset de relevancia 
codebook aglomerado estado ch06 pp04b_cod

keep if estado==1 & ch06>15 & ch06 != . // en stat .>numero es siempre verdadera

* Nos quedamos con los primeros dos digitos de la ocupacion 
gen sector_empleo = substr(pp04b_cod,1,2) // substring
order sector_empleo, after(pp04b_cod)

* Armamos variable categorica numerica
destring sector_empleo, replace

* Nos generamos un codigo para cada valor 
replace sector_empleo = 1 if sector_empleo >= 1  & sector_empleo <= 5 
replace sector_empleo = 2 if sector_empleo >= 10 & sector_empleo <= 14
replace sector_empleo = 3 if sector_empleo >= 15 & sector_empleo <= 37
replace sector_empleo = 4 if sector_empleo == 40
replace sector_empleo = 5 if sector_empleo == 45
replace sector_empleo = 6 if sector_empleo >= 50 & sector_empleo <= 53
replace sector_empleo = 7 if sector_empleo == 64
replace sector_empleo = 8 if sector_empleo >= 65 & sector_empleo <= 67
replace sector_empleo = 9 if sector_empleo == 41
replace sector_empleo = 9 if sector_empleo == 55
replace sector_empleo = 9 if sector_empleo >= 60 & sector_empleo <= 63
replace sector_empleo = 9 if sector_empleo >= 70 & sector_empleo <= 74
replace sector_empleo = 9 if sector_empleo == 80
replace sector_empleo = 9 if sector_empleo == 85
replace sector_empleo = 9 if sector_empleo >= 90 & sector_empleo <= 99
replace sector_empleo = 10 if sector_empleo == 75

sort aglomerado sector_empleo

label define sector_empleo  1 "Agricultura, Ganadería, Caza y Pesca" ///
						    2 "Minería" ////
						    3 "Industria" ////
						    4 "Energía" ////
						    5 "Construcción" ////
						    6 "Comercio" ////
						    7 "Correo y Telecomunicaciones" ////
						    8 "Ss. Financieros" //// 
						    9 "Otros Ss." ////
						    10 "Administración Pública" 

label values sector_empleo sector_empleo

* Revisamos la variable creada

tab sector_empleo, m

* Ordenamos 
sort aglomerado sector_empleo


**# 1) a) ------------------------------------------------------------------------


tab aglomerado sector_empleo 
tab aglomerado sector_empleo, cell nofreq matcell(tabmat)

matrix define X = tabmat * (1/_N) * 100
mat list X

local C = colsof(X)
matrix vector_medias = J(`C',1,.)
matrix vector_var = J(`C',1,.)
matrix vector_cv = J(`C',1,.)

svmat X // devuelve la matriz a la hoja de datos

forvalues i=1/`C' {
    summ X`i'
	matrix vector_medias [`i', 1] = r(mean)
    matrix vector_var [`i', 1] = r(Var)
    matrix vector_cv [`i', 1] = r(sd)/r(mean)
}

matrix list vector_medias
matrix list vector_var
matrix list vector_cv


**# 1) b) ------------------------------------------------------------------------

* Ahora queremos analizar la estructura de correlaciones entre las proporciones de ocupados de las ramas de actividad consideradas

correlate X*, covariance
matrix S = r(C)

correlate X*

local F = rowsof(X)
local C = colsof(X)

//	Varianza total
local var_total = trace(S)
display `var_total'

//	Varianza media
local var_media = `var_total'/`C'
display  `var_media'

//	Varianza generalizada 
local var_gen = det(S)
display `var_gen'

// 	Varianza efectiva
local var_efec = (det(S))^(1/`C')
display `var_efec'


* Para computar esta matriz manualmente
 *...

**# 1) c) ------------------------------------------------------------------------

regress X9 X1 X2 X3 X4 X5 X6 X7 X8 X10

//	Coefficient of determination (mediante regresion)
local R2_reg = e(r2)
display `R2_reg'

//	Coefficient of determination (mediante S)
matrix S_inv = inv(S)
local R2_S = 1-(1/(el(S_inv, 9,9)*el(S, 9,9))) 
display `R2_S'

//	Variance of the residuals (mediante regresion)
predict resid_s9, residuals
summarize resid_s9
local var_resid_reg = r(Var)
display `var_resid_reg'

//	Variance of the residuals (mediante S)
matrix S_inv = inv(S)
local S_inv_99 = el(S_inv, 9, 9)
local var_resid_S = 1/`S_inv_99'
display `var_resid_S'

drop resid_s9



**# 1) d) ------------------------------------------------------------------------

pcorr X9 X1 X2 X3 X4 X5 X6 X7 X8 X10

* Para hacerlo a mano 

regress X6 X1 X2 X3 X4 X5 X7 X8 X10 
predict resid_s6, residuals 

regress X9 X1 X2 X3 X4 X5 X7 X8 X10
predict resid_s9, residuals 

correlate resid_s6 resid_s9

local r69_reg = r(rho)

display `r69_reg'

//	Partial correlation coefficient (using S^(-1) matrix)
 
local r_69 = -(el(S_inv, 6,9)/sqrt(el(S_inv, 9,9)*el(S_inv, 6,6)))
display `r_69'


**# 1) e) ------------------------------------------------------------------------
corr X*
mat S = r(C) 
matrix symeigen Avec Aval = S  				
matrix list Aval	

**# 1) f) ------------------------------------------------------------------------
local C = colsof(X)

local cdf = 1-(det(S))^(1/(`C'-1))
display `cdf'


/*==============================================================================
 Analisis Estadistico Multivariado - UTDT 
 Problem Set 1

 Fiona Franco Churruarín 
===============================================================================*/

* Settings

cap log close 
clear all 
set more off, perma
cd "C:\Users\fiona\Dropbox\Materias MAECO\Análisis Estadístico Multivariado\Clases Practicas\PS1"


*-------------------------------------------------------------------------------
**# Ejercicio 3
*-------------------------------------------------------------------------------

use records.dta, clear


**# 3) a) ------------------------------------------------------------------------

* Analisis descriptivo 
describe
summarize
correlate
pwcorr
pcorr m_* k* ma*

**# 3) b) ------------------------------------------------------------------------

* Componentes principales

* PCA = principal component analysis

pca m_100 m_200 m_400 m_800 m_1500 km_5 km_10 maraton	
ereturn list

matrix eigenvalues = e(Ev)'
matrix list eigenvalues 
matrix eigenvectors = e(L)
matrix list eigenvectors


**# 3) c) i) -------------------------------------------------------------------


/*-------------------------------------------------------------------------*
|	Vamos a realizar un gráfico de λi frente a i. La idea es buscar un punto a
|	partir del cual los valores propios son aproximadamente iguales. El 
|	criterio es quedarse con un número de componentes que excluya los asociados
|	a valores pequeños y aproximadamente del mismo tamaño.
 *------------------------------------------------------------------------*/

greigen			
screeplot
											
//	Guido:
//	1)	To obtain a scree plot of the eigenvalues, you can use the greigen 
//		command.  We have included another scree plot with a a reference line on 
//		the y axis at one to aid in determining how many factors should be 
//		retained.

graph export 3ci1.emf, replace												
greigen, xline(3) yline(1) text(1 0 "1", place(n))					
graph export 3ci2.emf, replace


**# 3) c) ii) ------------------------------------------------------------------


local traza = el(e(Ev),1,1) + el(e(Ev),1,2) + el(e(Ev),1,3) + el(e(Ev),1,4) ///
+ el(e(Ev),1,5) + el(e(Ev),1,6) + el(e(Ev),1,7) + el(e(Ev),1,8) 
display `traza'

matrix prop = J(8,2,.)													
forvalues i=1(1)8 {													
		           matrix prop[`i',1]=`i'
		           matrix prop[`i',2]= el(e(Ev),1,`i')/`traza' // Vector con proporción explicada por cada componente
	               }
matrix list prop	

svmat prop
//	Guido:
//	1)	svmat takes a matrix and stores its columns as new variables. It is the 
//		reverse of the mkmat command, which creates a matrix from existing 
//		variables.
//	2)	If we check the Data Editor we will find two new variables prop1 and
//		prop2.
//	3)	If you find yourself with the following error message: "new variables 
//		cannot be uniquely named or already defined" you need to drop "prop" 
//		variable (if existed before) and then run the code.

gen prop3 = sum(prop2)
																				
graph bar prop2, over(prop1)												
graph export 3cii1.emf, replace										
graph bar prop3, over(prop1)													
graph export 3cii2.emf, replace


**# 3) d) ------------------------------------------------------------------------

predict u_1 u_2	//Los dos componentes principales														
scatter u_2 u_1, mlabel(pais)													
graph export 3d1.emf, replace
//	Guido:
//	1)	Proyección de los países en el plano generado por las dos primeras 
//		componentes (matriz de correlaciones).