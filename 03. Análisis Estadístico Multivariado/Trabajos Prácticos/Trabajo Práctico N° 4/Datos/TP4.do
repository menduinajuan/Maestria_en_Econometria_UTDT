/*-------------------------------------------------------------------------*
 |
 |            				    PS3:AEM, 2021
 |
 *------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                                                                         
 |            			Problem 1: Inicializando Stata							   
 |																		   
 *------------------------------------------------------------------------*/

clear all
set more off
cd "C:\Users\fiona\Dropbox\Materias MAECO\Análisis Estadístico Multivariado\Clases Practicas\PS4"


use ine.dta


/*-------------------------------------------------------------------------*
 |
 |            					   Problem 1
 |
 *------------------------------------------------------------------------*/
 
//	H0 = Multivariate normality

local lista = "alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"

mvtest normality `lista', stats(all)

//	Guido:
//	1)	mvtest normality performs tests for univariate, bivariate, and 
//		multivariate normality. Here we pick only the multivariate test.
//	2)	Results:

//	    Mardia mSkewness =  84.03333   chi2(286) =  302.066   Prob>chi2 =  0.2459	---->	skewness produces the test based on Mardia’s (1970) measure of multivariate skewness.
//	    Mardia mKurtosis =  130.2492     chi2(1) =    2.558   Prob>chi2 =  0.1097	---->	kurtosis produces the test based on Mardia’s (1970) measure of multivariate kurtosis.
//	    Henze-Zirkler    =  .9871703     chi2(1) =    3.025   Prob>chi2 =  0.0820	---->	hzirkler produces Henze–Zirkler’s (1990) consistent test.
//	    Doornik-Hansen                  chi2(22) =   18.126   Prob>chi2 =  0.6985	---->	dhansen produces the Doornik–Hansen (2008) omnibus test.

//	Of the four multivariate normality tests, non rejects the null hypothesis
//	of multivariate normality.

//	Result: we fail to reject the null hypothesis.

/*----------------------------------------------------------------------------*
 |	Puede concluir que el vector de medias de los datos es distinto del vector 
 |	nulo?
 *----------------------------------------------------------------------------*/

//	H0 = Mean of alybnh, vestcal, vivagelo, mobymant, salud, transp, comu, ocio,, educ, esparc, and otros is zero.
 
local lista = "alybnh vestcal vivagelo mobymant salud transp comu ocio educ esparc otros"
matrix mu_0 = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
mvtest means `lista', equals(mu_0) 
mvtest means `lista', zero 
//	Guido:
//	1)	mvtest means performs one-sample and multiple-sample multivariate tests 
//		on means. These tests assume multivariate normality.
//		Options:
//			-	zero: test that means of varlist are all equal to 0
//			-	equals(M): test that mean vector equals vector M
//		Here we are doing one-sample test, hence:
//			-	zero: performs Hotelling’s test of the hypothesis that the means 
//				of all variables in varlist are 0.
//			-	equals(M): performs Hotelling’s test that the vector of means of 
//				the k variables in varlist equals M. The matrix M must be a kx1 
//				or 1xk vector.

//	Result: we reject the null hypothesis. 

/*-------------------------------------------------------------------------*
 |
 |            					   Problem 2
 |
 *------------------------------------------------------------------------*/
 
//	Stata is continually being improved, meaning that programs and do-files 
//	written for older versions might stop working.
//	The command "version #" sets the command interpreter to internal version 
//	number #. It makes Stata understand old, out-of-date syntaxes.  It makes old
//	programs run correctly in modern Statas.  
 
version 11

clear
set more off

//	The following command, "drawnorm", draws a sample from a multivariate normal 
//	distribution with desired means and covariance matrix. The default is 
//	orthogonal data with mean 0 and variance 1. 
//	The values generated are a function of the current random-number seed or the 
//	number specified with set seed()

set seed 123 
drawnorm x1 x2 x3 x4 x5 x6 x7 x8, means( 2, .45, .23, .54, .12, .63, .66, .32) sds(.67, .89, .56, .90, .56, .34, .76, .13) n(100)

summarize x*	//	This is ok (picking a bigger sample will make the results 
				//	more akin to the real distribution).

save data4.dta, replace

/*-------------------------------------------------------------------------*
 |
 |            					 Problem 2 a)
 |
 *------------------------------------------------------------------------*/

//	We have drawn a sample from a multivariate normal distribution, hence our
//	following results must let us to that conclusion. 

//	Let's produce some histograms. We should expect the bell.
forvalues i = 1(1)8	{
	histogram x`i', name(name_of_x`i', replace) title("") 
}
graph combine name_of_x1 name_of_x2 name_of_x3 name_of_x4 name_of_x5 ///
name_of_x6 name_of_x7 name_of_x8, title("Our Histograms")
 

//	H0 = Multivariate normality

mvtest normality x*, stats(all)

//	Result: we fail to reject the null hypothesis.

//	H0 = Normality

sktest x*
//	For each variable in varlist, sktest presents a test for normality based on 
//	skewness and another based on kurtosis and then combines the two tests into 
//	an overall test statistic. 
//	These test are separate for each variable.

//	Result: we fail to reject the null hypothesis.

/*-------------------------------------------------------------------------*
 |
 |            					 Problem 2 b)
 |
 *------------------------------------------------------------------------*/

//	H0 = Means of all variables are 0

mat m0 = (0, 0, 0, 0, 0, 0, 0, 0)
mvtest means x*, equals(m0) 

//	Result: we reject the null hypothesis. 

/*-------------------------------------------------------------------------*
 |
 |            					 Problem 2 c)
 |
 *------------------------------------------------------------------------*/

//	H0 = Means of all variables are equal

mvtest means x*, equal
//	Guido:
//	1)	Now the option for this test is just "equal", so we are testing if 
//		variables in varlist have equal means (the default). In particular, 
//		it performs Hotelling’s test of the hypothesis that the means of all 
//		variables in varlist are equal.

//	Result: we reject the null hypothesis. 

/*-------------------------------------------------------------------------*
 |
 |            					 Problem 2 d)
 |
 *------------------------------------------------------------------------*/

// H0: Covariance matrix is spherical 

mvtest covariances x*, spherical 
//	Guido:
//	1)	mvtest covariances performs one-sample and multiple-sample multivariate 
//		tests on covariances. These tests assume multivariate normality. E.g.:
//			-	mvtest covariances v1 v2 v3 v4: that the covariance matrix of 
//				v1, v2, v3, and v4 is diagonal.
//			-	mvtest covariances v1 v2 v3 v4, spherical: Test that the covariance 
//				matrix is spherical.
//			- 	and so on.
//		In this particular case, spherical tests the hypothesis that the 
//		covariance matrix is diagonal with constant diagonal values, that is, 
//		that the variables in varlist are homoskedastic and independent.

//	Remember we draw a sample from a multivariate normal distribution by using 
//	the drawnorm command. We did not specify the covariance matrix (I mean, we
//	did by specifying the standard deviation, but we did not specify the matrix
//	outside its diagonal), then the default is orthogonal data (no serial 			--->	I am not so shure about this.
//	correlation). Hence, for spherical variance, the only thing missing is 
//	constant variance (so that all the elements of the main diagonal are the 
//	same, homoskedasticty). Is this the case ? No, because we did specified 
//	standard deviation. Hence, we should expect to reject the null.

//	Result: we reject the null hypothesis. 

/*-------------------------------------------------------------------------*
 |
 |            					 Problem 2 e)
 |
 *------------------------------------------------------------------------*/

// H0: Covariance matrix is diagonal 
 
mvtest covariances x*, diagonal 
//	Guido:
//	1)	Now we will only tests the hypothesis that the covariance matrix is 
//		diagonal, that is, that the variables in varlist are independent.
 
//	Result: we fail to reject the null hypothesis.

/*-------------------------------------------------------------------------*
 |
 |            					   Problem 3
 |
 *------------------------------------------------------------------------*/

//version 11
clear all
set more off
set seed 1
//	We will create three different populations:

preserve 
	drawnorm x1 x2 x3 x4 x5 x6 x7 x8, means( 3, 1.45, 1.23, 1.54, 1.12, 1.63, 1.66, 1.32) sds(1.67, 1.89, 1.56, 1.90, 1.56, 1.34, 1.76, 1.13)  n(50) seed(010101)
	generate id = 2
	tempfile data2
	save `data2'
restore

preserve 
	drawnorm x1 x2 x3 x4 x5 x6 x7 x8, means( 4, 2.45, 2.23, 2.54, 2.12, 2.63, 2.66, 2.32) sds(2.67, 2.89, 2.56, 2.90, 2.56, 2.34, 2.76, 2.13)  n(10) seed(010101)
	generate id = 3
	tempfile data3
	save `data3'
restore

drawnorm x1 x2 x3 x4 x5 x6 x7 x8, means( 2, .45, .23, .54, .12, .63, .66, .32) sds(.67, .89, .56, .90, .56, .34, .76, .13)  n(40) seed(010101)
generate id = 1

append using `data2'
append using `data3'

//	Warning: We will test with samples from normal distributions that are 
//	different. But we did not add a new variable (column in our database).

/*-------------------------------------------------------------------------*
 |	Test para verificar la normalidad de la base de datos construida.  
 *------------------------------------------------------------------------*/

//	H0 = Multivariate normality 
 
mvtest normality x*, stats(all)

//	Result: we reject the null hypothesis.

//	H0 = Normality

sktest x*

//	Result: we reject the null hypothesis (for each single variable).

/*-------------------------------------------------------------------------*
 |	Test para el vector de medias distinto del vector nulo.
 *------------------------------------------------------------------------*/

//	H0 = Means of all variables are 0 
 
mat m0 = (0, 0, 0, 0, 0, 0, 0, 0)
mvtest means x*, equals(m0) 

//	Result: we reject the null hypothesis. 

/*-------------------------------------------------------------------------*
 |	Test para igualdad de medias. 
 *------------------------------------------------------------------------*/
 
//	H0 = Means of all variables are equal
 
mvtest means x*, equal 

//	Result: we reject the null hypothesis. 

/*-------------------------------------------------------------------------*
 |	Test para esfericidad de la distribucion de los datos.
 *------------------------------------------------------------------------*/

// H0: Covariance matrix is spherical 
 
mvtest covariances x*, spherical 

 //	Result: we reject the null hypothesis. 

/*-------------------------------------------------------------------------*
 |	Test para diagonalidad de la matriz de varianzas y covarianzas.
 *------------------------------------------------------------------------*/

// H0: Covariance matrix is diagonal  
 
mvtest covariances x*, diagonal 

 //	Result: we reject the null hypothesis. 
 
/*-------------------------------------------------------------------------*
 |
 |            					Problem 3 a)
 |
 *------------------------------------------------------------------------*/ 
 
//	The difference is that with this new sample we reject the null hypothesis for 
//	the test of univariate and multivariate normal distribution. Also, we reject 
//	the null hypothesis for a diagonal covariance matrix.

/*-------------------------------------------------------------------------*
 |
 |            					Problem 3 b)
 |
 *------------------------------------------------------------------------*/ 

/*-------------------------------------------------------------------------*
 |	Subsample i = 1: 
 |	Test para verificar la normalidad de la base de datos construida. 
 *------------------------------------------------------------------------*/

//	H0 = Normality 
 
sktest x* if id == 1

//	Result: we fail to reject the null hypothesis.

//	H0 = Multivariate normality 

mvtest norm x* if id == 1, stats(all) 

//	Result: we fail to reject the null hypothesis.


/*-------------------------------------------------------------------------*
 |	Subsample i = 1: 
 |	Test para el vector de medias distinto del vector nulo.
 *------------------------------------------------------------------------*/ 

//	H0 = Means of all variables are 0  
 
mat m0 = (0, 0, 0, 0, 0, 0, 0, 0)
mvtest means x* if id == 1, equals(m0)

//	Result: we reject the null hypothesis.  

/*-------------------------------------------------------------------------*
 |	Subsample i = 1: 
 |	Test para igualdad de medias. 
 *------------------------------------------------------------------------*/ 

//	H0 = Means of all variables are equal
 
mvtest means x* if id == 1, equal 
 
//	Result: we reject the null hypothesis.  

/*-------------------------------------------------------------------------*
 |	Subsample i = 1: 
 |	Test para esfericidad de la distribucion de los datos.
 *------------------------------------------------------------------------*/ 
 
// H0: Covariance matrix is spherical 
 
mvtest covariances x* if id == 1, spherical 
 
//	Result: we reject the null hypothesis.  

//	If you use a bigger sample size (for i = 1 in this case) and check the
//	covariance matrix, you will see its sphericity.
 
/*-------------------------------------------------------------------------*
 |	Subsample i = 1: 
 |	Test para diagonalidad de la matriz de varianzas y covarianzas.
 *------------------------------------------------------------------------*/ 

// H0: Covariance matrix is diagonal  
  
mvtest covariances x* if id==1, diagonal 

//	Result: we reject the null hypothesis.  //--->	We shouldn't get this.

forvalues i = 1(1)3	{
		display ""
		display as result "-------------------------------Tests for i = `i'--------------------------------"
		display ""
		display "{it:-------------Skewness/Kurtosis joint test for univariate normality------------}"
		qui sktest x* if id == `i'
		matrix Utest = r(Utest)
		forvalues j = 1(1)8 {
			display as text "H0 = x`j' is normal"
			if Utest[`j',4] > 0.05 {
				display as text "We fail to reject the null hypothesis"
			}
			else {
				display as error "We reject the null hypothesis, p-value = " Utest[`j',4] 	//--->	We shouldn't get this. 
				
			}
		}
		display as result "{it:------------------------Test for multivariate normality-----------------------}"
		qui mvtest norm x* if id == `i' 
		display as text "H0 = Multivariate normality"
		if r(p_dh) > 0.05 {
			display as text "We fail to reject the null hypothesis"							
		}
		else {
			display as error "We reject the null hypothesis, p-value = " r(p_dh)			//--->	We shouldn't get this.
		}
		display as result "{it:-----------------------Test: Means of all variables are 0---------------------}"
		qui matrix m0 = (0, 0, 0, 0, 0, 0, 0, 0)
		qui mvtest means x* if id == `i', equals(m0)
		display as text "H0: Means of all variables are 0"
		if r(p_F) > 0.05 {
			display as error "We fail to reject the null hypothesis, p-value = " r(p_F)		//--->	We shouldn't get this.
		}
		else {
			display "We reject the null hypothesis."
		}
		display as result "{it:---------------------Test: Means of all variables are equal-------------------}"
		qui mvtest means x* if id == `i', equal 
		display as text "H0: Means of all variables are equal"
		if r(p_F) > 0.05 {
			display as error "We fail to reject the null hypothesis, p-value = " r(p_F)		//--->	We shouldn't get this.
		}
		else {
			display "We reject the null hypothesis."
		}
		display as result "{it:----------------------Test: Covariance matrix is spherical--------------------}"
		qui mvtest covariances x* if id == `i', spherical 
		display as text "H0: Covariance matrix is spherical"
		if r(p_chi2) > 0.05 {
			display as error "We fail to reject the null hypothesis, p-value = " r(p_chi2)	//--->	We shouldn't get this.
		}
		else {
			display "We reject the null hypothesis."
		}
		display as result "{it:----------------------Test: Covariance matrix is diagonal---------------------}"
		qui mvtest covariances x* if id == `i', diagonal 
		display as text "H0: Covariance matrix is diagonal"
		if r(p_chi2) > 0.05 {
			display "We fail to reject the null hypothesis, p-value = " r(p_chi2)	
		}
		else {
			display as error "We reject the null hypothesis."								//--->	We shouldn't get this.
		}
}
//	Result: The aggregate population does not present a multivariate normal 
//	distribution but the subgroups do remain normal.

//	Notice that the sample 3 fails more than 1 and 2.
//	Why ? Maybe the reason is that the sample size of 3 is smaller.

/*-------------------------------------------------------------------------*
 |	Solution for subgroups: I could use a bigger sample size. 
 *------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |	Solution for the aggregate: Use variables in logs. 
 *------------------------------------------------------------------------*/
 
//	Using the logarithm of one or more variables may improve the results by
//	transforming the distribution to a more normally shaped bell curve. 
//	In other words, the log transformation reduces or removes the skewness of 
//	our original data. 
 
gen var1 = log(x1)
gen var2 = log(x2)
gen var3 = log(x3)
gen var4 = log(x4)
gen var5 = log(x5)
gen var6 = log(x6)
gen var7 = log(x7)
gen var8 = log(x8)

mvtest norm var*, stats(all)
//	Result: we fail to reject the null hypothesis with the Mardia mKurtosis 
//	(this did not happened before).

sktest var*
//	Result: we reject the null except for log(x8) (as before).

mat m0 = (0, 0, 0, 0, 0, 0, 0, 0)
mvtest means var*, equals(m0) 
//	Result: we reject the null hypothesis (as before).

mvtest means var*, equal 
//	Result: we reject the null hypothesis (as before).

mvtest covariances var*, spherical 
//	Result: we reject the null hypothesis (as before).
 
mvtest covariances var*, diagonal 
//	Result: we reject the null hypothesis (as before). 

/*-------------------------------------------------------------------------*
 |	Solution for the aggregate: Construct a new multivariate normal random 
 |	variable, using as parameters the sum of the (sample) means weighted 
 |	by the sample size of the 3 random variables as a mean and the sum of the 
 |	between and within variation as covariance. 
 *------------------------------------------------------------------------*/

drop var*
 
//	Mean 
matrix means = ( 2, .45, .23, .54, .12, .63, .66, .32 \ 3, 1.45, 1.23, 1.54, 1.12, 1.63, 1.66, 1.32 \ 4, 2.45, 2.23, 2.54, 2.12, 2.63, 2.66, 2.32 )
matrix list means

matrix weights = ( 0.4 \ 0.5 \ 0.1 )
matrix list weights

matrix means_t = means'
matrix list means_t

matrix aggregated_mean = means_t * weights 
matrix list aggregated_mean 

matrix group_mean_1 = ( 2, .45, .23, .54, .12, .63, .66, .32 )
matrix group_mean_2 = ( 3, 1.45, 1.23, 1.54, 1.12, 1.63, 1.66, 1.32 )
matrix group_mean_3 = ( 4, 2.45, 2.23, 2.54, 2.12, 2.63, 2.66, 2.32 )

//	Covariance
forvalues i=1(1)3 {
	mkmat x* if id == `i', matrix(X)
	
	local F = rowsof(X)
	matrix uno = J(`F',1,1)                        
	
	matrix mean_dif = group_mean_`i'' - aggregated_mean		
	matrix var_b_`i' = mean_dif*mean_dif' 			//	between group variation
	
	matrix I = I(`F')                   
	matrix P = (I - (1/`F')*uno*uno')
	matrix X_tr = X'
	matrix S_`i' = (1/(`F'-1))*X_tr*P*X 			//	covariance matrix
}
//	Guido:
//	1)	S_1, S_2 and S_3 could be got from:
//		corr x* if id == 1, cov
//		corr x* if id == 2, cov
//		corr x* if id == 3, cov
	
matrix var_b = 0.4*var_b_1 + 0.5*var_b_2 + 0.1*var_b_3 	//	Weighted between-group variation
matrix var_w = 0.4*S_1 + 0.5*S_2 + 0.1*S_3 				//	Weighted within-group variation 

matrix covariance_matrix = var_b + var_w
matrix list covariance_matrix

drop x*

/*------------------------------------------------------------------------------------------*
 |	drawnorm x1 x2 x3 x4 x5 x6 x7 x8, means(aggregated_mean) cov(covariance_matrix) n(100)
 |	
 |	Unexpected problem (this is not usual at all): 
 |	If you try to use drawnorm above you may find the following error:
 |	cov(covariance_matrix) is not symmetric
 |	This will happen to you depending on the seed you choose. Although the 
 |	covariance matrix looks symmetric, it is not. This is an issue of precision. 
 |	The elementwise differences are down around 10^(-15) or something. 
 |	To circumvent such a problem, we will enforce symmetry inside Mata.
 |	Who's Mata ?
 |	Mata is a programming language that acts behind the scenes when you are 
 |	using Stata. To get access type "mata", to close access type "end".
 *------------------------------------------------------------------------------------------*/

mata
	covariance_matrix = st_matrix("covariance_matrix")			//stata -> mata
	issymmetric(covariance_matrix) 	//	0, nonsymmetric
	covariance_matrix = makesymmetric(covariance_matrix)
	issymmetric(covariance_matrix)	//	1, we won.
	st_matrix("covariance_matrix_corrected", covariance_matrix)	//mata -> stata
end

matrix list covariance_matrix_corrected

drawnorm x1 x2 x3 x4 x5 x6 x7 x8, means(aggregated_mean) cov(covariance_matrix_corrected) n(100)

mvtest norm x*, stats(all)
//	Result: we fail to reject the null hypothesis with any test.

sktest x*
//	Result: we fail to reject the null hypothesis everywhere.

mat m0 = (0, 0, 0, 0, 0, 0, 0, 0)
mvtest means x*, equals(m0) 
//	Result: we reject the null hypothesis (as before).

mvtest means x*, equal 
//	Result: we reject the null hypothesis (as before).

mvtest covariances x*, spherical 
//	Result: we reject the null hypothesis (as before).
 
mvtest covariances x*, diagonal 
//	Result: we reject the null hypothesis (as before).