/*-------------------------------------------------------------------------*
 |
 |            				    PS2:AEM, 2021
 |
 *------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                                                                         
 |            			Problem 1: Inicializando Stata							   
 |																		   
 *------------------------------------------------------------------------*/

clear all
set more off
cd "C:\Users\fiona\Dropbox\Materias MAECO\Análisis Estadístico Multivariado\Clases Practicas\PS2"

use ine.dta

/*-------------------------------------------------------------------------*
 |
 |            					Problem 1: a)
 |
 *------------------------------------------------------------------------*/

local lista = "alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"
correlate `lista', covariance 
 
local lista = "alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"
correlate `lista'

summarize `lista'
//	Guido:
//	1)	Means are very different from each other. 
//	2)	Same happens with the std.dev. 
//	3)	Using "summarize" will perform the command for every variable. 

correlate `lista'
//	Guido:
//	1)	PCA is more powerful when the variables are correlated. If these 
//		variables are orthogonal (or with a small correlation) then PCA will
//		lose power.

//	The default of -pca- is to use the correlation matrix; that is entirely 
//	equivalent to using standardised variables, so that there is absolutely no 
//	need to standardise yourself, except possibly as an exercise.
//	When Stata calculates the components using -predict- following -pca-, the
// 	results are centered at 0 (or very close to zero, with minor rounding error), 
//	but they are not standardized to variance 1. The variance of each component 
//	will instead be equal to the corresponding eigenvalue (again, with minimal 
//	rounding errors). 

//	You tend to use the covariance matrix when the variable scales are similar 
//	and the correlation matrix when variables are on different scales.

//	Using the correlation matrix is equivalent to standardizing each of the 
//	variables (to mean 0 and standard deviation 1). In general, PCA with and 
//	without standardizing will give different results. Especially when the 
//	scales are different.

//	Anyway: (egen's std() function converts a variable to its standardized form 
//	(mean 0, variance 1);


/*-------------------------------------------------------------------------*
 |
 |            					Problem 1: b)
 |
 *------------------------------------------------------------------------*/
 
local lista = "alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"
pca `lista', covariance //using covariance matrix

/*
Principal components/covariance                  Number of obs    =         18
                                                 Number of comp.  =         11
                                                 Trace            =    4639612
    Rotation: (unrotated = principal)            Rho              =     1.0000	-------->	Fraction of explained variance.

    --------------------------------------------------------------------------
       Component |   Eigenvalue   Difference         Proportion   Cumulative
    -------------+------------------------------------------------------------
           Comp1 |      3687478      3054180             0.7948       0.7948	-------->	First principal component explains 0.7948 of the total variance.
           Comp2 |       633298       456210             0.1365       0.9313	-------->	Second principal component explains 0.1365 of the total variance	
           Comp3 |       177088       130083             0.0382       0.9694				(and so on).
           Comp4 |      47004.7      5090.15             0.0101       0.9796
           Comp5 |      41914.5      23807.5             0.0090       0.9886
           Comp6 |        18107      5406.33             0.0039       0.9925
           Comp7 |      12700.7      510.343             0.0027       0.9953
           Comp8 |      12190.3      4652.97             0.0026       0.9979
           Comp9 |      7537.36      6015.16             0.0016       0.9995
          Comp10 |       1522.2      750.196             0.0003       0.9998
          Comp11 |      772.001            .             0.0002       1.0000
    --------------------------------------------------------------------------
*/
//	Guido:
//	1)	The first panel lists the eigenvalues of the covariance matrix, ordered
//		from largest to smallest.
//	2)	The corresponding eigenvectors (to each eigenvalue) are listed in the
//		second panel:
/*
    ------------------------------------------------------------------------------------------------------------------------------------------
        Variable |    Comp1     Comp2     Comp3     Comp4     Comp5     Comp6     Comp7     Comp8     Comp9    Comp10    Comp11 | Unexplained 
    -------------+--------------------------------------------------------------------------------------------------------------+-------------
          alybnh |   0.0638    0.8748    0.0036   -0.3835   -0.0667    0.1843   -0.1913   -0.0431   -0.0210   -0.0181    0.0771 |           0 	-------->	Unexplained variance of "alybnh" is zero 
         vestcal |   0.0674    0.4068   -0.2632    0.4366   -0.1017   -0.5842    0.4014    0.1016   -0.1445    0.0458   -0.1550 |           0 	-------->	Unexplained variance of "vestcal" is zero
        vivagelo |   0.9596   -0.1403   -0.0612   -0.1929   -0.1053   -0.0776    0.0174    0.0039    0.0315   -0.0062   -0.0122 |           0 				(and so on)
        mobymant |   0.0756    0.0907    0.0793    0.3368    0.0122   -0.0716   -0.1282   -0.8100    0.4121    0.0663    0.1192 |           0 				This happens because all principal components
           salud |   0.0325    0.1034    0.0181   -0.0021    0.2610    0.2465    0.5642    0.2636    0.6688   -0.0669    0.1393 |           0 				explain all variance in all varaibles
          transp |   0.0559    0.0724    0.9261   -0.0395    0.1198   -0.2521    0.1785    0.0056   -0.1481   -0.0271   -0.0018 |           0 
            comu |   0.0363    0.0463    0.0764    0.0249    0.0980    0.2043   -0.0221    0.0149    0.1007    0.6585   -0.7031 |           0 
            ocio |   0.1662    0.0812    0.0016    0.3749    0.1859    0.6086    0.2876   -0.1949   -0.4906   -0.2321   -0.0707 |           0 
            educ |   0.0455   -0.0020   -0.0093    0.0953    0.0272    0.0785    0.0867    0.0706   -0.2086    0.7023    0.6578 |           0 
          esparc |   0.1514    0.1031   -0.0276    0.3115    0.7140   -0.1199   -0.5073    0.2790    0.0444   -0.0676    0.0522 |           0 
           otros |   0.0823    0.0777    0.2368    0.5126   -0.5803    0.2381   -0.2953    0.3757    0.2055   -0.0525    0.0391 |           0 
    ------------------------------------------------------------------------------------------------------------------------------------------
*/
//		We can prove this:
//	First build X from the database:
local lista = "alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"
mkmat `lista', matrix(X)
matrix list X
//	Second build S from X
local F = rowsof(X) 
matrix uno = J(`F',1,1)
matrix I = I(`F')
matrix P = I - (1/`F')*uno*uno'
matrix S = (1/(`F'-1))*X'*P*X
matrix list S
correlate `lista', covariance
//	Third capture the eigenvalues of S with symeigen:
matrix symeigen Avec Aval = S
matrix list Aval	//--->	These are the same numbers that figure in the column 
					//		"Eigenvalue" from the first panel of the pca
					//		command.
matrix list Avec	//--->	These vectors are in the second panel of the pca
					//		command.

//	Guido:
//	1)	Eigenvectors have unit lenght:
//		We can prove this (e.g. for the first eigenvector):
local sum_of_elementssq_1 = Avec[1,1]^2 + Avec[2,1]^2 + Avec[3,1]^2 + ///
Avec[4,1]^2 + Avec[5,1]^2 + Avec[6,1]^2 + Avec[7,1]^2 + Avec[8,1]^2 + ///
Avec[9,1]^2 + Avec[10,1]^2 + Avec[11,1]^2
display `sum_of_elementssq_1'
//		For each eigenvector:
forvalues i = 1(1)11 {
	display "{it:Proving that the principal component  `i' has unit length}"
	display "Avec[1,`i']^2 + Avec[2,`i']^2 + Avec[7,`i']^2 + Avec[8,`i']^2 + Avec[9,`i']^2 + Avec[10,`i']^2 + Avec[11,`i']^2 ="
	local sum_of_elementssq_of_pc_`i' = Avec[1,`i']^2 + Avec[2,`i']^2 + ///
	Avec[3,`i']^2 + Avec[4,`i']^2 + Avec[5,`i']^2 + Avec[6,`i']^2 + ///
	Avec[7,`i']^2 + Avec[8,`i']^2 + Avec[9,`i']^2 + Avec[10,`i']^2 + ///
	Avec[11,`i']^2
	display `sum_of_elementssq_of_pc_`i''
}
//
//	Guido:
//	1)	The eigenvalues add up to the sum of the variances of the variables in 
//		the analysis—the "total variance" of the variables.
//		We can prove this:
local var_total = trace(S) // Total variance
display `var_total'

matrix list Aval
local var_total_with_eigenvalues = Aval[1,1] + Aval[1,2] + Aval[1,3] + ///
Aval[1,4] + Aval[1,5] + Aval[1,6] + Aval[1,7] + Aval[1,8] + ///
Aval[1,9] + Aval[1,10] + Aval[1,11]
display `var_total_with_eigenvalues' // Total variance

ereturn list
//	Guido:
//	1)	Notice the section "matrices"
//		There we have:
matrix list e(Ev)	//	Eigenvalues
matrix list e(L)	//	Eigenvectors (principal components).

local lista = "alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"
pca `lista' //using correlation matrix 

/*----------------------------------------------------------------------------*
|	Next we will prove exactly the same we proved before (now with the correlation
| 	matrix). 
 *--------------------------------------------------------------------------*/

/*
Principal components/correlation                 Number of obs    =         18
                                                 Number of comp.  =         11
                                                 Trace            =         11
    Rotation: (unrotated = principal)            Rho              =     1.0000

    --------------------------------------------------------------------------
       Component |   Eigenvalue   Difference         Proportion   Cumulative
    -------------+------------------------------------------------------------
           Comp1 |      6.31799      4.63452             0.5744       0.5744
           Comp2 |      1.68348      .518886             0.1530       0.7274
           Comp3 |      1.16459        .4527             0.1059       0.8333
           Comp4 |      .711894      .376163             0.0647       0.8980
           Comp5 |       .33573     .0888713             0.0305       0.9285
           Comp6 |      .246859     .0686718             0.0224       0.9510
           Comp7 |      .178187     .0371071             0.0162       0.9672
           Comp8 |       .14108     .0155581             0.0128       0.9800
           Comp9 |      .125522     .0650827             0.0114       0.9914
          Comp10 |     .0604393     .0262194             0.0055       0.9969
          Comp11 |     .0342199            .             0.0031       1.0000
    --------------------------------------------------------------------------
*/
//	Guido:
//	1)	The first panel lists the eigenvalues of the correlation matrix, ordered
//		from largest to smallest.
//	2)	The corresponding eigenvectors (to each eigenvalue) are listed in the
//		second panel:
/*
 ------------------------------------------------------------------------------------------------------------------------------------------
        Variable |    Comp1     Comp2     Comp3     Comp4     Comp5     Comp6     Comp7     Comp8     Comp9    Comp10    Comp11 | Unexplained 
    -------------+--------------------------------------------------------------------------------------------------------------+-------------
          alybnh |   0.2073    0.6146    0.1074    0.0974   -0.0291    0.4075   -0.2469    0.1482    0.2589   -0.1293    0.4740 |           0 
         vestcal |   0.2441    0.5185   -0.2140    0.3225    0.0077    0.1046    0.3670    0.0381   -0.1907    0.1589   -0.5595 |           0 
        vivagelo |   0.3315   -0.3155   -0.2008   -0.0142   -0.0053    0.1415    0.1154    0.1745    0.7708    0.2617   -0.1536 |           0 
        mobymant |   0.3387   -0.0037    0.0613    0.2925   -0.5949   -0.5657   -0.1077    0.2229   -0.0724    0.1447    0.1859 |           0 
           salud |   0.2635    0.3311    0.0166   -0.6080    0.3392   -0.5052    0.2374    0.0221    0.0754    0.0557    0.1226 |           0 
          transp |   0.1628   -0.1258    0.7924   -0.1381   -0.1746    0.2416    0.4188    0.1691   -0.0608   -0.0674   -0.0976 |           0 
            comu |   0.3549   -0.0061    0.2045   -0.2695    0.0288    0.1126   -0.6905   -0.1208   -0.1672    0.2743   -0.3892 |           0 
            ocio |   0.3716   -0.1529   -0.1714   -0.0178    0.0565   -0.0395   -0.0991    0.2073   -0.0471   -0.8409   -0.2046 |           0 
            educ |   0.3285   -0.2921   -0.2482   -0.0056    0.2639    0.2693    0.1127    0.3735   -0.4946    0.2721    0.3634 |           0 
          esparc |   0.3507   -0.0735   -0.2080   -0.1840   -0.3619    0.2056    0.2194   -0.7228   -0.0861   -0.0665    0.1970 |           0 
           otros |   0.2863   -0.1195    0.3072    0.5524    0.5432   -0.2004   -0.0105   -0.3845    0.0748   -0.0081    0.1241 |           0 
    ------------------------------------------------------------------------------------------------------------------------------------------
*/
//		We can prove this:
//	First build CORR from the database:
local lista = "alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"
correlate `lista'
return list
matrix list r(C)		//	Until now we have been creating the correlation or covariance matrix by
						//	hand. But check the "matrices" section from return list. r(C) is the
						//	correlation matrix !!!
matrix CORR = r(C)
//	Second capture the eigenvalues of CORR with symeigen:
matrix symeigen Avec Aval = CORR
matrix list Aval	//--->	These are the same numbers that figure in the column 
					//		"Eigenvalue" from the first panel of the pca
					//		command.
matrix list Avec	//--->	These vectors are in the second panel of the pca
					//		command.
//	Guido:
//	1)	Eigenvectors have unit lenght, we can prove this (e.g. for the first eigenvector):
local sum_of_elementssq_1 = Avec[1,1]^2 + Avec[2,1]^2 + Avec[3,1]^2 + ///
Avec[4,1]^2 + Avec[5,1]^2 + Avec[6,1]^2 + Avec[7,1]^2 + Avec[8,1]^2 + ///
Avec[9,1]^2 + Avec[10,1]^2 + Avec[11,1]^2
display `sum_of_elementssq_1'
//		For each eigenvector:
forvalues i = 1(1)11 {
	display "{it:Proving that the principal component  `i' has unit length}"
	display "Avec[1,`i']^2 + Avec[2,`i']^2 + Avec[7,`i']^2 + Avec[8,`i']^2 + Avec[9,`i']^2 + Avec[10,`i']^2 + Avec[11,`i']^2 ="
	local sum_of_elementssq_of_pc_`i' = Avec[1,`i']^2 + Avec[2,`i']^2 + ///
	Avec[3,`i']^2 + Avec[4,`i']^2 + Avec[5,`i']^2 + Avec[6,`i']^2 + ///
	Avec[7,`i']^2 + Avec[8,`i']^2 + Avec[9,`i']^2 + Avec[10,`i']^2 + ///
	Avec[11,`i']^2
	display `sum_of_elementssq_of_pc_`i''
}
//
//	Guido:
//	1)	The eigenvalues add up to the sum of the variances of the variables in 
//		the analysis—the "total variance" of the variables.
//		We can prove this:
local var_total = trace(CORR) // Total variance
display `var_total'

matrix list Aval
local var_total_with_eigenvalues = Aval[1,1] + Aval[1,2] + Aval[1,3] + ///
Aval[1,4] + Aval[1,5] + Aval[1,6] + Aval[1,7] + Aval[1,8] + ///
Aval[1,9] + Aval[1,10] + Aval[1,11] // Total variance
display `var_total_with_eigenvalues'
//	Guido:
//	1)	Because we are analyzing a correlation matrix, the variables are 
//		standardized to have unit variance, so the total variance is 11.
//		(esto lo vimos en el TP1).

ereturn list
//	Guido:
//	1)	Notice the section "matrices"
//		There we have:
matrix list e(Ev)	//	Eigenvalues
matrix list e(L)	//	Eigenvectors (principal components).

//	Next, I capture the eigenvalues in the following matrix, because I will
//	need them later (using a command that saves data in the "e" memory will 
//	overwrite the current memory, hence it will erase my current eigenvalues
//	that are there). 

matrix aval2 = e(Ev) /*guardo los autovalores*/

/*-------------------------------------------------------------------------*
 |
 |            					Problem 1: c)
 |
 *------------------------------------------------------------------------*/

//	Selección del número de componentes

/*-------------------------------------------------------------------------*
|	i)	Busqueda del codo
*--------------------------------------------------------------------------*/

greigen

//	Guido:
//	1)	This graph is called "scree plot". It is a plot of the eigenvalues 
//		against their rank. 
//	2)	The number of eigenvalues above a distinct `elbow' in the scree plot is 
//		usually taken as the number of principal components to select.
//	3)	So, from this figure we should select the first three components.
//	4)	Informalmente, esto nos marcaba cuando el cambio de pendiente es tan 
//		chico que pasa a ser irrelevante. Podria ser 5 tambien (es decir, el
//		analisis es subjetivo).
//	5)	This values figure at the first panel after using pca with the 
//		correlation matrix.

/*-------------------------------------------------------------------------*
|	ii) Busqueda por umbral de varianza a explicar, considerando un 80%
*--------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |	Esto puede resolverse mirando directamente los resultados del comando 
 |	pca con la matriz de correlacioneds del inciso anterior. Observar el primer
 |	panel, la columna Cumulative.
 |	A continuacion vamos a generar un grafico de barras con esa misma 
 |	informacion.
 *------------------------------------------------------------------------*/

local var_total_with_eigenvalues = aval2[1,1] + aval2[1,2] + aval2[1,3] + ///
aval2[1,4] + aval2[1,5] + aval2[1,6] + aval2[1,7] + aval2[1,8] + aval2[1,9] ///
+ aval2[1,10] + aval2[1,11]
local p = 11 
display `var_total_with_eigenvalues' 
//	Guido:
//	1)	Next, we will build a matrix called Prop. In the first column, we put 
//		the principal component, in the second column we put the proportion of 
//		total variance explained by that principal component.
//		These values can be found in the first panel after using the PCA 
//		command with the correlation matrix (looking at the Proportion column).
matrix Prop = J(`p',2,.)

forvalues i = 1/`p'{
					matrix Prop[`i',1] = `i'
					matrix Prop[`i',2] = aval2[1,`i']/`var_total_with_eigenvalues'
					}
//
matrix list Prop					
					
svmat Prop
//	Guido:
//	1)	svmat takes a matrix and stores its columns as new variables. It is the 
//		reverse of the mkmat command, which creates a matrix from existing 
//		variables.
//	2)	Notice that in the Data Editor now we have two new variables called
//		"Prop1" and "Prop2".

generate Cumulative = sum(Prop2) 
//	Guido:
//	1)	We generated a new variable called "Cumulative" which has the same 
//		values found in the first panel after using the PCA command with the
//		correlation matrix (lookint at the Cumulative column).

generate varinter = 0.8 /*creo el umbral*/
graph twoway (bar Cumulative Prop1) (line varinter Prop1)
//Prop1: ranking

graph twoway (bar Cumulative Prop1) (line varinter Prop1)

//graph twoway (bar Cumulative Prop1) (line varinter Cumulative)


//graph export graf2.wmf, replace
//	Guido:
//	1)	La primer componente principal te explica menos que 0.6 entonces no 
//		aparece en el grafico. La primera me la quedo, la segunda me la quedo y
//		me deberia quedar hasta la tercera componente porque es la que me 
//		explica hasta el 80%.

/*-------------------------------------------------------------------------*
|	iii) Buqueda por tope minimo al valor de los eigenvalores, considerando
|		 la varianza media.
*-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |	Esto puede resolverse mirando directamente los resultados del comando 
 |	pca con la matriz de correlaciones del inciso anterior. Observar el primer
 |	panel, la columna Eigenvalue.
 |	A continuacion vamos a explicar el motivo. 
 *------------------------------------------------------------------------*/

//	Guido:
//	1)	Recordar que cada componente principal tiene su autovalor 
//		correspondiente.
//		Si realizamos el PCA mediante la matriz de correlaciones, estos 
//		autovalores corresponden a esta.
//		Recordar del TP anterior: en una matriz de correlaciones, las variables
//		estan estandarizadas para tener varianza en promedio 1:
local media_de_varianza = (Aval[1,1] + Aval[1,2] + Aval[1,3] + ///
Aval[1,4] + Aval[1,5] + Aval[1,6] + Aval[1,7] + Aval[1,8] + ///
Aval[1,9] + Aval[1,10] + Aval[1,11]) / 11 
display `media_de_varianza'
//		Una manera informal de elegir el numero de componentes es elegir 
//		aquellos con autovalores mayores a uno (es decir, varianzas mayores
//		al promedio). En este caso, esto nos lleva a mantener solo tres 
//		componentes (observar la columna Eigenvalue del primer panel del 
//		comando PCA con la matriz de correlaciones).

/*-------------------------------------------------------------------------*
 |
 |            					Problem 1: d)
 |
 *------------------------------------------------------------------------*/


local lista = "alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"
pca `lista', components(3) 
//	Guido:	
//	1)	Now we retain only 3 components.
/*
Principal components/correlation                 Number of obs    =         18
                                                 Number of comp.  =          3
                                                 Trace            =         11
    Rotation: (unrotated = principal)            Rho              =     0.8333	-------->	Fraction of explained variance (before: 1)

    --------------------------------------------------------------------------
       Component |   Eigenvalue   Difference         Proportion   Cumulative
    -------------+------------------------------------------------------------
           Comp1 |      6.31799      4.63452             0.5744       0.5744
           Comp2 |      1.68348      .518886             0.1530       0.7274
           Comp3 |      1.16459        .4527             0.1059       0.8333
           Comp4 |      .711894      .376163             0.0647       0.8980
           Comp5 |       .33573     .0888713             0.0305       0.9285
           Comp6 |      .246859     .0686718             0.0224       0.9510
           Comp7 |      .178187     .0371071             0.0162       0.9672
           Comp8 |       .14108     .0155581             0.0128       0.9800
           Comp9 |      .125522     .0650827             0.0114       0.9914
          Comp10 |     .0604393     .0262194             0.0055       0.9969
          Comp11 |     .0342199            .             0.0031       1.0000
    --------------------------------------------------------------------------
*/
//	Guido:
//	1)	The first panel is not affected, but now rho = 0.8333. 
//	2)	The second panel now lists the first four principal components:										
/*
    ----------------------------------------------------------
        Variable |    Comp1     Comp2     Comp3 | Unexplained 
    -------------+------------------------------+-------------
          alybnh |   0.2073    0.6146    0.1074 |      .07912 
         vestcal |   0.2441    0.5185   -0.2140 |       .1178 
        vivagelo |   0.3315   -0.3155   -0.2008 |       .0913 
        mobymant |   0.3387   -0.0037    0.0613 |       .2709 
           salud |   0.2635    0.3311    0.0166 |       .3763 
          transp |   0.1628   -0.1258    0.7924 |      .07458 
            comu |   0.3549   -0.0061    0.2045 |       .1554 
            ocio |   0.3716   -0.1529   -0.1714 |      .05395 
            educ |   0.3285   -0.2921   -0.2482 |        .103 
          esparc |   0.3507   -0.0735   -0.2080 |       .1633 
           otros |   0.2863   -0.1195    0.3072 |       .3483 
    ----------------------------------------------------------
*/
//	Guido:
//	1)	These three components do not contain all information in the data, and 
//		therefore some of the variances in the variables are unaccounted for or 
//		unexplained.
//	2)	The average unexplained variance is equal to the overall unexplained
//		variance of 0.1667 (1 - 0.83333 = 0.1667)
//		Proof:
ereturn list
matrix list e(Psi)	//-----> column "Unexplained" is saved here
matrix Psi = e(Psi)
local average_unexplained_variance = ( Psi[1,1] + Psi[1,2] + Psi[1,3] + ///
Psi[1,4] + Psi[1,5] + Psi[1,6] + Psi[1,7] + Psi[1,8] + Psi[1,9] + Psi[1,10] ///
+ Psi[1,11] ) / 11
display `average_unexplained_variance' // = 0.1667

//	Interpretacion de componentes:

/*-------------------------------------------------------------------------*
 
 Componente 1:
 
--------------------------
    Variable |    Comp1     
-------------+------------
      alybnh |   0.2073   
     vestcal |   0.2441   
    vivagelo |   0.3315
    mobymant |   0.3387  
       salud |   0.2635  
      transp |   0.1628  
        comu |   0.3549  
        ocio |   0.3716  
        educ |   0.3285  
      esparc |   0.3507   
       otros |   0.2863  
--------------------------

El primer componente puede ser interpretado como una medida global de gasto. 
Un valor negativo indica un menor nivel de gasto.
Recorda que la posicion de cada observacion en el nuevo sistema se calcula
como la combinacion lineal de las variables originales estandarizadas ponderadas
por estas cargas.

Componente 2:

--------------------------
    Variable |    Comp2    
-------------+------------
      alybnh |    0.6146    
     vestcal |    0.5185    
    vivagelo |   -0.3155   
    mobymant |   -0.0037   
       salud |    0.3311    
      transp |   -0.1258   
        comu |   -0.0061   
        ocio |   -0.1529   
        educ |   -0.2921    
      esparc |   -0.0735    
       otros |   -0.1195    
    -----------------------

El segundo vector propio pondera con un signo positivo a la primera, segunda y 
quinta variable y con signo negativo a las restantes. El segundo componente 
tomará valores altos para aquellas comunidades cuyos gastos de necesidad 
primaria resulten más importantes en términos relativos a los restantes 
(valores por encima de la media). Esta componente permitiría separar provincias 
de acuerdo con la proporción de gasto que prima.

Componente 3:

---------------------------
    Variable |    Comp3  
-------------+-------------
      alybnh |    0.1074   
     vestcal |   -0.2140   
    vivagelo |   -0.2008   
    mobymant |    0.0613   
       salud |    0.0166   
      transp |    0.7924   
        comu |    0.2045   
        ocio |   -0.1714   
        educ |   -0.2482   
      esparc |   -0.2080   
       otros |    0.3072  
---------------------------
	
El tercer componente permite agrupar provincias centroperiferia. Tomará valores 
altos en aquellas con gastos de transporte, remisiones (dentro de otros), y 
gastos en salud elevados, (expulsoras).	

-------------------------------------------------------------------------*/

//	Component 1: gasto promedio
//	Component 2: gasto en necesidad primaria
//	Component 3: gasto de centro/periferia

predict u1 u2 u3
//	Guido:
//	1)	"predict" crea un nuevo conjunto de variables con las estimaciones de 
//		los componentes principales.
//	2)	Son ortogonales: 
corr u1 u2 u3

scatter u2 u1, mlabel(comunidad) xline(0) yline(0) 
//	Guido:
//	1)	Estamos viendo las relaciones entre los componentes en dos dimensiones,
//		utilizando los primeros dos componentes principales. 
//		Particlarmente es la proyección de las co	munidades en el plano generado 
//		por las dos primeras componentes.
//	2)	Por ejemplo, EXTREMADURA tiene puntaje muy bajo en el componente 1,
//		esto indica que tiene un gasto general mas bajo que el resto de las
//		comunidades. Si me voy a madrid, ocurre lo contrario.
//	3) 	Para el componente 2: Galicia pondera de forma positiva a alybnh. 
//		Entonces como Galicia y Ceuta y Melilla tienen alto valor de estos
//		entonces figuran alto en su componente 2.
//		Vivajelo esta ponderado de forma negativa. Entonces si tienen alto valor
//		de Vivajelo, deberian irse hacia abajo (ejemplo MADRID)

scatter u3 u1, mlabel(comunidad) xline(0) yline(0)
//	Guido:
//	1)	Proyección de las comunidades en el plano generado por la primera y 
//		tercera componentes.

scatter u3 u2, mlabel(comunidad) xline(0) yline(0)
//	Guido:
//	1)	Proyección de las comunidades en el plano generado por la segunda y 
//		tercera componentes


//	Lo siguiente que hago es comprobar que el componente 1 sea en verdad una 
//	medida gneral del gasto.

preserve
keep comunidad u1
//gsort -u1
gsort -u1, generate(orden1)
//	Guido:
//	1)	gsort arranges observations to be in ascending or descending order of 
//		the specified variables and so differs from sort in that sort produces 
//		ascending-order arrangements only;
//	2)	Notar que lo guardamos en orden de forma descendiente, esto puede ser
//		una oportunidad para verificar que componente es mas importante para
//		cada pais.

save salida2.dta, replace
restore
/*
     +---------------------------------------------------+
     |                    comunidad          u1   orden1 |
     |---------------------------------------------------|
  1. |              Ceuta y Melilla    4.692456        1 |
  2. |        Madrid (Comunidad de)    3.860595        2 |
  3. |                   Pa�s Vasco    3.181463        3 |
	 .													 .
	 .													 .
	 .													 .
 18. |                  Extremadura   -5.635293       18 |
     +---------------------------------------------------+
*/
clear
insheet using renta.csv, delimiter(";")
//	Guido:
//	1)	medhog que representa el ingreso promedio por hogar, por comunidad.
//	2)	En el archivo renta yo tengo el ingreso medio por hogar. Voy a 
//		relacionar el vector del ingreso medio por hogar con el gastos medios 
//		del hogar, pero en realidad lo voy a hacer con los componentes.
//		recordar que el tercer componente estaba muy relacionado con el gasto 
//		en energia por ejemplo. Todos son una combinacion lineal de las 
//		variables originales.
//		Vamos a hacer scatters entre los componentes para ver la relacion entre 
//		ellos y sacar informacion.

gsort -imedhog, generate(orden2)
save renta2.dta, replace
use salida2.dta
sort orden1

merge m:1 comunidad using renta2.dta 
gsort orden2 
//	Guido:
//	1) 	Genere el archivo renta2 donde guarde solo los ingresos. Tenia 
//		salida2 donde guarde solo el ingreso. Le estoy diciendo juntamelos 
//		usando renta2. Ordenamelos segun orden de ingreso.

keep comunidad orden1 orden2 u1 imedhog /* saco la columna de matching*/
scatter imedhog u1, mlabel(comunidad) xline(0) yline(0) 
//	Guido:
//	1)	A clear direct relationship is observed, which is what you would 
//		expect to see. Average spending and average income per household (per 
//		community).

/*-------------------------------------------------------------------------*
 |
 |            					Problem 2
 |
 *------------------------------------------------------------------------*/
 
clear
set more off
use ine.dta

/*
Biplot of 18 observations and 11 variables

    Explained variance by component 1  0.5744	---->	This is the explained 
    Explained variance by component 2  0.1530			variance we found 
             Total explained variance  0.7274			using correlation
														matrix.

Biplot coordinates								---->	This table indicates the
												        coordinates of the dots
    Observations |     dim1      dim2 	
    -------------+--------------------
       Andaluc�a |  -0.2225    0.0112		
          Arag�n |   0.0529   -0.1300 
    Asturias(P~) |  -0.1565   -0.1742 
    Balears (I~) |   0.3213   -0.9335 
        Canarias |  -0.2977   -0.1683 
       Cantabria |  -0.0029    0.4748 
    Castilla y~n |  -0.6676   -0.0473 
    Castilla-L~a |  -0.9771    0.1038 
        Catalu�a |   0.1000   -0.3546 
    Comunitat ~a |   0.4352   -0.3787 
     Extremadura |  -1.7505    0.0388 
         Galicia |  -0.2501    0.6443 
    Madrid (Co~) |   1.1992   -0.8346 
    Murcia (Re~) |  -0.7719    0.4130 
    Navarra (C~) |   0.4789    0.0775 
      Pa�s Vasco |   0.9883   -0.2985 
      Rioja (La) |   0.0635   -0.0296 
    Ceuta y Me~a |   1.4576    1.5859 
    ----------------------------------

       Variables |     dim1      dim2 			---->	This table indicates the
    -------------+--------------------					coordinates of the 
          alybnh |   0.6674    1.4215 					arrows.
         vestcal |   0.7857    1.1992 
        vivagelo |   1.0671   -0.7296 
        mobymant |   1.0903   -0.0087 
           salud |   0.8484    0.7659 
          transp |   0.5241   -0.2909 
            comu |   1.1426   -0.0140 
            ocio |   1.1963   -0.3537 
            educ |   1.0574   -0.6756 
          esparc |   1.1291   -0.1699 
           otros |   0.9215   -0.2765 
    ----------------------------------
*/

//	Guido:
//	1)	Choosing a value for c (alpha) defines the coordinates for different 
//		types of biplots:
//			-	c = 1 (JK) is the row-metric preserving biplot, since the 
//				approximations of the Euclidean distances are optimal in this 
//				biplot. Con c = 1 la direccion y magnitud de las flechas
//				resguarda el coeficiente de cada coeficiente del autovector.
//				(pendiente):
local lista = "alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"
biplot `lista', std alpha(1) xnegate colopts(mcolor(green) lcolor(green) mlabcolor(green) mlabsize(tiny))rowopts(msize(tiny) mlcolor(blue) mcolor(none) mlabel(comunidad) mlabsize(tiny)) table auto ysize(5) xsize(5)
//				Se puede ver luego de usar:
local lista = "alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"
pca `lista', components(3) 
//				Cuando usamos c = 1 las flechas en este caso tienden a juntarse.
//				La posicion de las comunidades esta expresada por el valor
//				de componentes principales que obtuvimos (cuando utilizamos
//				predict u1 u2 u3).

//			-	c = 0 (GH) is the column-metric preserving biplot. The 
//				variance–covariance structure of the variables is best 
//				approximated in the GH biplot.
//				En este caso, los componentes principales se ven estandarizados
//				para poner mas enfasis en la longitud y relacion de las 
//				flechas (es utilizar una escala mas grande para poder 
//				interpretar).
use ine.dta,clear 
local lista = "alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"
biplot `lista', std alpha(0) xnegate colopts(mcolor(green) lcolor(green) mlabcolor(green) mlabsize(tiny))rowopts(msize(tiny) mlcolor(blue) mcolor(none) mlabel(comunidad) mlabsize(tiny)) table auto ysize(5) xsize(5)	
	//			-	c = 0.5 (SQ) is the symmetric biplot. SQ biplots represent the 
//				observational values of Y better than the other types. The 
//				coordinates of variables and observations tend to be more 
//				similar than in the two other types.
local lista = "alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"
biplot `lista', std alpha(0.5) xnegate colopts(mcolor(green) lcolor(green) mlabcolor(green) mlabsize(tiny))rowopts(msize(tiny) mlcolor(blue) mcolor(none) mlabel(comunidad) mlabsize(tiny)) table auto ysize(5) xsize(5)
//				Biplot coordinates here are approximations of the values we got 
//				in "scatter u2 u1, mlabel(comunidad) xline(0) yline(0)"
//	2)	El coseno del angulo de las flechas aproxima la correlacion entre las 
//		variables:
//			-	cos(0) = 1
//			-	cos(90) = 0
//			-	cos(180) = -1
//			-	cos(270) = 0
//		For example:
//		Check the arrow of alybnh and compare it to the other arrows:
//			-	with vestcal we have an angle near to 0, then the correlation is high
//			-	with salud we have an angle near to 0, then the correlation is high
//			-		with ocio we have an angle near to 90, then the correlation is low
//			-	with educ we have an angle near to 90, then the correlation is low
//				and so on.
//	3)	La longitud de las flechas indica la importancia de los coeficientes
//		para cada variable. Se pueden ver luego de realizar el pca.

local lista = "alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"
correlate `lista'

/*-------------------------------------------------------------------------*
 |
 |            					Problem 3
 |
 *------------------------------------------------------------------------*/
 
use ine.dta, clear 
local lista = "alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"
biplot `lista', std alpha(0) xnegate colopts(mcolor(green) lcolor(green) mlabcolor(green) mlabsize(tiny))rowopts(msize(tiny) mlcolor(blue) mcolor(none) mlabel(comunidad) mlabsize(tiny)) table auto ysize(5) xsize(5)

local lista = "alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"
biplot `lista', std alpha(0) dim(3 1) xnegate colopts(mcolor(green) lcolor(green) mlabcolor(green) mlabsize(tiny))rowopts(msize(tiny) mlcolor(blue) mcolor(none) mlabel(comunidad) mlabsize(tiny)) table auto ysize(5) xsize(5)

 /*-------------------------------------------------------------------------*
 |
 |            					Problem 4
 |
 *------------------------------------------------------------------------*/

//	Here the process is analogous to what we have already done. The only thing 
//	that could be a little bit tricky is the interpretation of principal 
//	components.
 
clear
set more off 
use wb.dta
/*
drop if var2 == "CHN"
drop if var2 == "USA"
*/
//	Do not drop, but as we will see later, these two are outliers. Results from 
//	PCA analysis could be deeply different without them.
//	It is ok or not ok to drop USA and China, it depends on what you want to do. 
//	Is it ok to leave USA (or China) because data is weird ? 
//	Do I care about USA (or China) ?


/*-------------------------------------------------------------------------*
 |
 |            					Problem 4: a)
 |
 *------------------------------------------------------------------------*/

local lista = "var4 var5 var6 var7 var8 var9 var10 var11 var12"

sum `lista'
correlate `lista'
correlate `lista', cov

pca `lista' 

ereturn list
matrix aval = e(Ev) 
matrix list aval

/*-------------------------------------------------------------------------*
 |
 |            					Problem 4: b)
 |
 *------------------------------------------------------------------------*/

local lista = "var4 var5 var6 var7 var8 var9 var10 var11 var12"
pca `lista'

//	Tope inferior a los eigenvalores
local vartot = aval[1,1] + aval[1,2] + aval[1,3] + aval[1,4] + aval[1,5] + ///
aval[1,6] + aval[1,7] + aval[1,8] + aval[1,9]
local meanvar = `vartot'/13
greigen, yline(`meanvar') /*La línea roja va a ser el valor promedio de los autovalores.*/
//	Guido:
//	1)	Me quedo con tres componentes.

//	Búsqueda del codo
greigen, yline(1)
//	Guido:
//	1)	Me quedo con tres componentes. 

//	Umbral de varianza a explicar
local vartot = aval[1,1] + aval[1,2] + aval[1,3] + aval[1,4] + aval[1,5] + aval[1,6] + aval[1,7] + aval[1,8] + aval[1,9]
local p = 9
matrix Prop = J(`p',2,.)
forvalues i = 1/`p'{
					matrix Prop[`i',1] = `i'
					matrix Prop[`i',2] = aval[1,`i']/`vartot'
				    }
svmat Prop
gen acu = sum(Prop2)
graph twoway (bar acu Prop1) (line Prop2 Prop1, lcolor(black))
//	Guido:
//	1)	Me quedo con tres componentes. 

/*-------------------------------------------------------------------------*
 |
 |            					Problem 4: c)
 |
 *------------------------------------------------------------------------*/
 
//	Son las primeras tres filas de la columna Proportion (posterior al uso del 
//	comando pca).

/*-------------------------------------------------------------------------*
 |
 |            					Problem 4: d)
 |
 *------------------------------------------------------------------------*/

//	Para la interpretacion, leer p2c.pdf (subido a la carpeta PS2 (Material) del 
//	campus virtual. No hace falta hacer los scatters para ella, es posible
//	comprobando los valores correspondientes a los primeros tres autovectores
//	(que Stata devuelve al utilizar el comando pca).
 
/*-------------------------------------------------------------------------*
 |
 |            					Problem 4: e)
 |
 *------------------------------------------------------------------------*/
 
local lista = "var4 var5 var6 var7 var8 var9 var10 var11 var12"
pca `lista', com(3)

predict u1 u2 u3

//	Clasificación
scatter u2 u1, mlabel(var1) xline(0) yline(0) 
scatter u3 u2, mlabel(var1) xline(0) yline(0)

/*-------------------------------------------------------------------------*
 |
 |            					Problem 4: f)
 |
 *------------------------------------------------------------------------*/

local lista = "var4 var5 var6 var7 var8 var9 var10 var11 var12"
biplot `lista', std alpha(0.5) xnegate colopts(mcolor(green) lcolor(green) mlabcolor(green) mlabsize(tiny))rowopts(msize(tiny) mlcolor(blue) mcolor(none) mlabel(var1) mlabsize(tiny)) table auto ysize(5) xsize(5)

/*-------------------------------------------------------------------------*
 |
 | 	Que puede decir sob re la posicion de los Estados Unidos y China, y su 
 |	influencia en el analisis, a la luz de los resultados obtenidos?
 |
 *------------------------------------------------------------------------*/

//	Looking at the previous graph, we might feel China and the United States are 
//	breaking our analysis, especially considering how far from the other 
//	countries they seem. Then, we can try doing the same process we have already 
//	done without China (and later without the United States) to check what we 
//	get. We don't need to do this, but here it is:

//	Without China:
clear
set more off
cd "C:\Users\Guido Damonte\OneDrive\Master en Econometría (Universidad Torcuato di Tella)\Topicos en Estadistica Avanzada II (Análisis Estadístico Multivariado)\P2\p2r"
use wb.dta
drop in 19
local lista = "var4 var5 var6 var7 var8 var9 var10 var11 var12"
pca `lista', com(2) 
predict u1 u2 
scatter u2 u1, mlabel(var1) xline(0) yline(0) 
local lista = "var4 var5 var6 var7 var8 var9 var10 var11 var12"
biplot `lista', std alpha(0.5) xnegate colopts(mcolor(green) lcolor(green) mlabcolor(green) mlabsize(tiny))rowopts(msize(tiny) mlcolor(blue) mcolor(none) mlabel(var1) mlabsize(tiny)) table auto ysize(5) xsize(5)

//	Without China or the United States
clear
set more off
cd "C:\Users\Guido Damonte\OneDrive\Master en Econometría (Universidad Torcuato di Tella)\Topicos en Estadistica Avanzada II (Análisis Estadístico Multivariado)\2020\P2"
use wb2.dta
drop in 19 
drop in 74
local lista = "var4 var5 var6 var7 var8 var9 var10 var11 var12"
pca `lista', com(2)
predict u1 u2 
scatter u2 u1, mlabel(var1) xline(0) yline(0) 
biplot `lista', std alpha(0.5) xnegate colopts(mcolor(green) lcolor(green) mlabcolor(green) mlabsize(tiny))rowopts(msize(tiny) mlcolor(blue) mcolor(none) mlabel(var1) mlabsize(tiny)) table auto ysize(5) xsize(5)

/*-------------------------------------------------------------------------*
 |
 |            					Problem 5
 |
 *------------------------------------------------------------------------*/
 
clear
set more off 
cd "C:\Users\Guido Damonte\OneDrive\Master en Econometría (Universidad Torcuato di Tella)\Topicos en Estadistica Avanzada II (Análisis Estadístico Multivariado)\2020\P2"
insheet using hspendusa2009.csv

local lista = "s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12"
sum `lista'

quietly describe
return list
local p = r(k)-1
local n = _N

local lista = "s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12"
correlate `lista'
correlate `lista', cov

local lista = "s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12"
pca `lista'
ereturn list
matrix aval = e(Ev)
matrix list aval

/*-------------------------------------------------------------------------*
 |
 |            					Problem 5)
 |					Selección del número de componentes
 |
 *------------------------------------------------------------------------*/
 
//	Busqueda del codo
greigen, yline(1)

//	Umbral de Varianza a explicar
local vartot = aval[1,1]+aval[1,2]+aval[1,3]+aval[1,4]+aval[1,5]+aval[1,6]+aval[1,7]+aval[1,8]+aval[1,9]
local p=12
matrix Prop = J(`p',2,.)
forvalues i = 1/`p'{
					matrix Prop[`i',1] = `i'
					matrix Prop[`i',2] = aval[1,`i']/`vartot'
				    }
svmat Prop
gen acu = sum(Prop2)
gen varinter = 0.8
graph twoway (bar acu Prop1) (line varinter Prop1) (line Prop2 Prop1)

//	Tope inferior a los eigenvalores
local vartot = aval[1,1]+aval[1,2]+aval[1,3]+aval[1,4]+aval[1,5]+aval[1,6]+aval[1,7]+aval[1,8]+aval[1,9]
local p=12
local meanvar = `vartot'/`p'
greigen, yline(`meanvar')

/*-------------------------------------------------------------------------*
 |
 |            					Problem 5)
 |		Elección de componentes, interpretación, clasificación y biplots.
 |
 *------------------------------------------------------------------------*/

//	Elección de componentes de acuerdo al análisis previo
local lista = "s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12"
pca `lista', com(3)

//	Interpretación de los componentes seleccionados
predict u1 u2 u3
matrix A = r(scoef)
svmat A
correlate u1 u2 u3
//	La interpretacion es similar a la utilizada en el Problem 1). Por ejemplo,
//	el primer componente principal puede interpretarse como una medida global
//	de gasto.

//	Clasificación
scatter u2 u1, mlabel(meta) xline(0) yline(0)
scatter u3 u2, mlabel(meta) xline(0) yline(0)

//	Biplots
local lista = "s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12"
biplot `lista', std alpha(1) xnegate colopts(mcolor(green) lcolor(green) mlabcolor(green) mlabsize(tiny))rowopts(msize(tiny) mlcolor(blue) mcolor(none) mlabel(meta) mlabsize(tiny)) table auto ysize(5) xsize(5)
local lista = "s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12"
biplot `lista', std alpha(0.5) xnegate colopts(mcolor(green) lcolor(green) mlabcolor(green) mlabsize(tiny))rowopts(msize(tiny) mlcolor(blue) mcolor(none) mlabel(meta) mlabsize(tiny)) table auto ysize(5) xsize(5)