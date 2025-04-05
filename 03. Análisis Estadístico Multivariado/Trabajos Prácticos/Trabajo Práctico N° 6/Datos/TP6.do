/*---------------------------------------------------------------------------*
 |
 |            				    PS5:AEM, 2021
 |
 *---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*
 |                                                                         
 |            					Problem 1						   
 |																		   
 *---------------------------------------------------------------------------*/

 //	When fitting models, it is possible to increase the likelihood by adding 
//	parameters, but doing so may result in overfitting. Both BIC and AIC attempt 
//	to resolve this problem by introducing a penalty term for the number of 
//	parameters in the model; the penalty term is larger in BIC than in AIC.
//	The AIC tries to select the model that most adequately describes an unknown,
//	high dimensional reality. This means that reality is never in the set of 
//	candidate models that are being considered. On the contrary, BIC tries to 
//	find the TRUE model among the set of candidates. I find it quite odd the 
//	assumption that reality is instantiated in one of the models that the 
//	researchers built along the way. This is a real issue for BIC. 
//	Nevertheless, there are a lot of researchers who say BIC is better than AIC, 
//	using model recovery simulations as an argument. 
//	My recommendation is to use both AIC and BIC. Most of the times they will 
//	agree on the preferred model, when they don't, just report it. 
version 11
clear
set more off
use eurosec.dta

//	Now that we have estimated the model, we can do the likelihood ratio test to
//	get the number of factors:
//	H0: Sigma = LL'+psi
//	H1: Sigma >< LL'+psi
//	This time, we will also pay attention to the BIC criterion (Schwarz 
//	criterion), that is what the PS is asking us to do.
do ftest.do
ftest s*, f(1) c(0.05)
ftest s*, f(2) c(0.05)
ftest s*, f(3) c(0.05)
ftest s*, f(4) c(0.05)
ftest s*, f(5) c(0.05)	// Smallest AIC & BIC. Note: it is not the first to reject the null
ftest s*, f(6) c(0.05)
ftest s*, f(7) c(0.05)
ftest s*, f(8) c(0.05)
ftest s*, f(9) c(0.05)
//	ftest s*, f(10) c(0.05)	--->	this will not work, factors must be < number 
//									of variables. And in fact, we are using  
//									factor analysis to reduce the number of 
//									variables into fewer number of factors.

//	Still, we need to check for data normality (to pick an estimation method)
//	H0 = Multivariate normality
mvtest normality s*, stats(all)
//	Mardia Skewness rejects the null, but Mardia Kurtosis does not. 
//	Doornik-Hansen rejects the null, but Henze-Zirkler does not.
//	Type I error could be violated by skewness and kurtosis in the case of 
//	small samples.

//	Remember that the statistics computed by Stata are not necesarily the same
//	that those in the theoric slides. If we compute them exactly as we find 
//	them in slides, then we do not reject in both cases.
//	I will leave here the test already coded in the mvnorm.ado file
do mvnorm.do
mvnorm s*, confianza(0.05)		//	We do not reject the null 

//	It's up to us to decide. Should this data be MVN ? 
//	In case you have two variables only, you can try doing a 3d plot in R, 
//	Matlab or any other and check visually (this is not applicable in this
//	case).
//	Also, you can try doing a Q-Q plot (not available in Stata) in R or any 
//	other. 

//factor s* 
//factor s*, factors(5)

// factor s*, ml 

//	We will use maximum likelihood method
factor s*, ml factors(5)
//	Notice Stata comment: “Note: test formally not valid because a Heywood case 
//	was encountered”. The approximations used in computing the chi2 value and 
//	degrees of freedom are mathematically justified on the assumption that an 
//	interior solution to the factor maximum likelihood was found.
//	Aqui ocurre por tener pocos datos para proveer estimadores estables. 

//	In addition to the “standard” output, when you use the ml option, Stata 
//	reports a likelihood-ratio test of the number of factors in the model 
//	against the saturated model. This test is only approximately chi2 and we 
//	have also the test with a correction. 


//	The default solution is poor from the perspective of a "simple structure", 
//	namely, that variables should have high loadings on few factors (one) and
//	factors should ideally have only low and high values.
//	For example, look at the following plot of factor 1 and 2:
loadingplot, aspect(1) yline(0) xline(0)

//	Same analysis with all combinations of factors
loadingplot, factors(4) 

//	We would like to see more variables close to one axis and other variables
//	close to the other axis. 
//	Turning the plot should make this possible and offer a much “simpler” 
//	structure. This is what the rotate command accomplishes. The purpose of 
//	rotation is to make factor loadings easier to interpret.
//	So, we will rotate factors to maximize the variance
rotate, orthogonal varimax 	//	The default (rotate gives the same result)
//	The uniqueness—the variance of the specific factors—is not affected, 
//	because we are changing only the coordinates in common factor space.
//	The default rotation method is varimax, probably the most popular method.
//	It rotates the axes to maximize the sum of the variance of the squared 
//	loadings in the columns (the varimax criterion). The variance in a column 
//	is large if it comprises small and large (in the absolute sense) values 
//	(that is what we want). 
//	A column of loadings with a high variance tends to contain a series of large 
//	values and a series of low values, achieving the simplicity aim of factor
//	analytic interpretation.

//	In rotating the axes, rows with large initial loadings (that is, with high 
//	communalities) have more influence than rows with only small values.
//	The other types of rotation simply maximize other concepts of simplicity.
//	For instance, the quartimax rotation aims at rowwise simplicity—preferably, 
//	the loadings within variables fall into a grouping of a few large ones and a
//	few small ones, using again the variance in squared loadings as the 
//	criterion to be maximized.
//loadingplot, aspect(1) yline(0) xline(0)
//loadingplot, factors(4) 

matrix uniqueness = e(Psi)'
matrix list uniqueness
matrix Psi = diag(uniqueness)
matrix list Psi

matrix ones = J(rowsof(uniqueness), 1, 1)  	//	(row, col, value)
matrix commonality = ones - uniqueness		//	Commonality = Vector de 1s - uniqueness
matrix list commonality

//	Now we will estimate the factors. We will do it first as we did that class
//	just with the command predict. And then we will do it by hand, with the 
//	purpuse of getting what is the operation we are actually doing. Now, if we 
//	want to compare the results "by hand" and with the "predict" command, then
//	you will also need to rotate the matrix by hand. 

/*---------------------------------------------------------------------------*                                                                        					   
 |							Using "predict" command																	   
 *---------------------------------------------------------------------------*/

 //	The following is what we used last class.
 //	Remember that Stata by default produces factors scored by the regression 
 //	method. That is, the second method Alejandra showed in slides.
 
predict f1 f2 f3 f4 f5, norotated	

/*---------------------------------------------------------------------------*                                                                        					   
 |									By hand																	   
 *---------------------------------------------------------------------------*/
 
//	We will just follow the slides 
 
matrix Sigma = e(C)		//	Matrix of correlations (the same you get by corr div*)
matrix list Sigma 
mat inv_Sigma = inv(Co) //	Inverse correlation matrix: equal to that of covariance matrix if the data is standardized
mat inv_Psi = inv(Psi) 	//	It has in the diagonal the same values than the vector "uniqueness" we got before
mat I = I(5)

//	Now, we standardize the variables, remember that when using the command 
//	"factor" Stata standardizes the variables by default.
forval i = 1/9 {
	*summarize s`i'
	*gen zvar`i' = (s`i' - r(mean))/r(sd)
	egen zvar`i' = std(s`i')
}
//

//	A) For the orthogonal case, assuming factors are random variables
mkmat zvar*, mat(X)
matrix F1 = [L'*inv_Sigma]*X'
matlist F1			
//	F1 is the same that we estimated with the predict command

//	B) Re-expressing in order to replace the correlation matrix by parameters
matrix F2 = [inv(I+L'*inv_Psi*L)*L'*inv_Psi]*X'
matlist F2
//	F2 is the same that we estimated with the predict command

/*---------------------------------------------------------------------------*
 |                                                                         
 |            					Problem 2					   
 |																		   
 *---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*
|                			  Using ind.dta                                                         				   																	   
*----------------------------------------------------------------------------*/
 
clear
set more off

use ind.dta

do ftest

ftest x*, f(1) c(0.05)
ftest x*, f(2) c(0.05)
ftest x*, f(3) c(0.05)
ftest x*, f(4) c(0.05) // BIC
ftest x*, f(5) c(0.05)
ftest x*, f(6) c(0.05) // Test + AIC 
ftest x*, f(7) c(0.05)
ftest x*, f(8) c(0.05)
ftest x*, f(9) c(0.05)
ftest x*, f(10) c(0.05)
ftest x*, f(11) c(0.05)

factor x*, factors(4)
rotate 

matrix uniqueness = e(Psi)'
matrix list uniqueness
matrix Psi = diag(uniqueness)
matrix list Psi

matrix ones = J(rowsof(uniqueness), 1, 1)  	//	(row, col, value)
matrix commonality = ones - uniqueness		//	Commonality = Vector de 1s - uniqueness
matrix list commonality

predict f1-f4
loadingplot 

/*---------------------------------------------------------------------------*
|                			  Using ipc2dig.dta                                                         				   																	   
*----------------------------------------------------------------------------*/

clear
set more off
use ipc2dig.dta 

do ftest
ftest div*, f(1) c(0.05)
ftest div*, f(2) c(0.05)
ftest div*, f(3) c(0.05)
ftest div*, f(4) c(0.05) //	BIC + Test
ftest div*, f(5) c(0.05) //	AIC
ftest div*, f(6) c(0.05)
ftest div*, f(7) c(0.05)
ftest div*, f(8) c(0.05)
ftest div*, f(9) c(0.05)
ftest div*, f(10) c(0.05)
ftest div*, f(11) c(0.05)
ftest div*, f(12) c(0.05)
ftest div*, f(13) c(0.05)
ftest div*, f(14) c(0.05)
ftest div*, f(15) c(0.05)
ftest div*, f(16) c(0.05)
ftest div*, f(17) c(0.05)
ftest div*, f(18) c(0.05)
ftest div*, f(19) c(0.05)

factor div*, factors(4)
rotate 

matrix C = e(C) //	Correlation matrix
matrix list C

matrix uniqueness = e(Psi)'
matrix list uniqueness
matrix Psi = diag(uniqueness)
matrix list Psi

matrix ones = J(rowsof(uniqueness), 1, 1)  	//	(row, col, value)
matrix commonality = ones - uniqueness		//	Commonality = Vector de 1s - uniqueness
matrix list commonality

/*---------------------------------------------------------------------------*
 |                                                                         
 |            					Problem 3						   
 |																		   
 *---------------------------------------------------------------------------*/
 
clear
set more off
use sachs.dta, clear

do mvnorm.ado 
do ftest.do
local lista= "gdp95 lnd100km pop100km lnd100cr pop100cr dens95c dens95i airdist ciffob95 landarea open6590 urbpop95 pop95"

mvnorm `lista', confianza(0.05)
ftest `lista', f(1) c(0.05)
ftest `lista', f(2) c(0.05)
ftest `lista', f(3) c(0.05)
ftest `lista', f(4) c(0.05)
ftest `lista', f(5) c(0.05)
ftest `lista', f(6) c(0.05) //	AIC (to change a bit, we pick this)
ftest `lista', f(7) c(0.05)
ftest `lista', f(8) c(0.05)

factor `lista', factors(6)
rotate 

matrix C = e(C) //	Correlation matrix
matrix list C

matrix uniqueness = e(Psi)'
matrix list uniqueness
matrix Psi = diag(uniqueness)
matrix list Psi

matrix ones = J(rowsof(uniqueness), 1, 1)  	//	(row, col, value)
matrix commonality = ones - uniqueness		//	Commonality = Vector de 1s - uniqueness
matrix list commonality

/*---------------------------------------------------------------------------*
 |                                                                         
 |            					Problem 4						   
 |																		   
 *---------------------------------------------------------------------------*/

clear
set more off

use heritage.dta

do mvnorm.do 
do ftest.do

mvnorm propertyrights-financialfreedom, confianza(0.05) /*Rechazamos normalidad multivariada*/
mvtest norm propertyrights-financialfreedom, stats(sk ku) /*Se rechaza normalidad multivariada para ambos tests*/

ftest propertyrights-financialfreedom, f(1) c(0.05)
ftest propertyrights-financialfreedom, f(2) c(0.05)
ftest propertyrights-financialfreedom, f(3) c(0.05) //	BIC 
ftest propertyrights-financialfreedom, f(4) c(0.05)
ftest propertyrights-financialfreedom, f(5) c(0.05) 
ftest propertyrights-financialfreedom, f(6) c(0.05) 
ftest propertyrights-financialfreedom, f(7) c(0.05)
ftest propertyrights-financialfreedom, f(8) c(0.05)

factor propertyrights-financialfreedom, factors(3)
rotate

matrix C = e(C) //	Correlation matrix
matrix list C

matrix uniqueness = e(Psi)'
matrix list uniqueness
matrix Psi = diag(uniqueness)
matrix list Psi

matrix ones = J(rowsof(uniqueness), 1, 1)  	//	(row, col, value)
matrix commonality = ones - uniqueness		//	Commonality = Vector de 1s - uniqueness
matrix list commonality

loadingplot, factors(3)

predict f1-f3