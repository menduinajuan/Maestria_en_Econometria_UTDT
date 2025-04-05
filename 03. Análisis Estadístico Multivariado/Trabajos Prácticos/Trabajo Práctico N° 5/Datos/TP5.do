/*-------------------------------------------------------------------------*
 |
 |            				    PS4:AEM, 2021
 |
 *------------------------------------------------------------------------*/

//	Factor analysis, in the sense of exploratory factor analysis, is a 
//	statistical technique for data reduction. It reduces the number of variables 
//	in an analysis by describing linear combinations of the variables that 
//	contain most of the information and that, we hope, admit meaningful 
//	interpretations.

//	Psi = 0 => m principal components = estimating m factors
 
/*-------------------------------------------------------------------------*
 |                                                                         
 |            			Problem 1: Inicializando Stata							   
 |																		   
 *------------------------------------------------------------------------*/

clear all
set more off
cd "C:\Users\fiona\Dropbox\Materias MAECO\Análisis Estadístico Multivariado\Practicas\PS5new"
use ind.dta

/*-------------------------------------------------------------------------*
 |
 |            					   Problem 1 a)
 |
 *------------------------------------------------------------------------*/
 
//	H0 = Multivariate normality

mvtest norm x*
mvtest norm x*, stats(sk ku) 
// We reject multivariate normality in the data

// 	We filter negative values and transform the variables to logarithmics to 
//	perform the test again and corroborate results.

preserve

forvalues j=1/17{
	gen lx`j' = log(x`j')
}

mvtest norm lx*
mvtest norm lx*, stats(sk ku) 

restore

//	Rejection of multivariate normality again

//	This implies we cannot use the maximum-likelihood factor method as it 
//	assumes multivariate normal observations (if you need it, just write ",ml"
//	after factor x* (check the code below). We must use the principal-factor
//	method, Stata uses it by default.

//	What's the difference?
//	Some think that principal-factor is better able to recover weak factors, but
//	maximum likelihood works better for big samples (it is asymptotically 
//	efficient. For more discussion, you should just Google or take a look at
//	some papers. 

/*-------------------------------------------------------------------------*
 |
 |            					   Problem 1 b)
 |
 *------------------------------------------------------------------------*/
 
//	Next, we will obtain our factors using the default and uncorrelated form, 
//	assuming uncorrelated common factors. That is: Phi = I
// LL' = D
factor x*

//	Note: in factor analysis, we standardize the variables (the argument is the 
//	same that we used for component analysis).
 
/* Factor retained only the first ten factors because the eigenvalues 
associated with the remaining factors are negative. According to the default 
criterion, a factor must have an eigenvalue greater than zero to be retained. 
	
Notice that the cumulative proportions of the eigenvalues exceeded 1 in our 
factor analysis because of the negative eigenvalues. By default, the proportion 
and cumulative proportion columns are computed using the sum of all eigenvalues 
as the divisor.

The altdivisor option allows you to display the proportions and cumulative 
proportions by using the trace of the correlation matrix as the divisor.
There is not a consensus on which divisor is most appropriate.

Uniqueness is the percentage of variance for the variable that is not 
explained by the common factors. The quantity “1 - uniqueness” is called 
communality. Uniqueness could be pure measurement error, or it could represent 
something that is measured reliably in that particular variable, but not by any 
of the others. The greater the uniqueness, the more likely that it is more than 
just measurement error. Values more than 0.6 are usually considered high, some 
variables in this problem are even higher. If the uniqueness is high, then the
variable is not well explained by the factors.	*/

ereturn list

matrix uniqueness = e(Psi)'
matrix Psi = diag(uniqueness)
matrix list Psi					//	Remember Psi is diagonal by assumption

matrix Lambda = e(L)			//	Factor loadings			
matrix list Lambda

//	We can check that the assumption for identification for principal factor
// 	method is that Lambda'*Lambda = Diagonal
matrix LambdaTLambda = Lambda'*Lambda
matrix list LambdaTLambda

//	We are also using a decomposition of the covariance matrix (Sigma) where we
//	impose Phi = I
matrix Phi = e(Phi)
matrix list Phi

//	Then, the coviriance matrix of X can be estimated by:
matrix covariance_X = Lambda*Phi*Lambda' + Psi
matrix list covariance_X	//	It should be similar to the one below if the 
							//	decomposition of the covariance matrix of X 
							//	(the number of factors we have in our model) is
							//	correct. In fact, that is what we check for 
							//	different decompositions (different number of 
							//	factors) in the test below. 
correlate x*

//	Determinacion del numero de factores:
ssc install ftest

//	Now that we have estimated the model, we can do the likelihood ratio test to
//	get the number of factors
//	H0: Sigma = LL'+psi
//	H1: Sigma >< LL'+psi
do ftest
ftest x*, f(1) alpha(0.05)
ftest x*, f(2) alpha(0.05)
ftest x*, f(3) alpha(0.05)
ftest x*, f(4) alpha(0.05)
ftest x*, f(5) alpha(0.05)
ftest x*, f(6) alpha(0.05) 	//	p-value
ftest x*, f(7) alpha(0.05) 	//	AIC
ftest x*, f(8) alpha(0.05)
ftest x*, f(9) alpha(0.05) 
ftest x*, f(10) alpha(0.05)
//	The P-values are increasing, we take the first one that does not reject the
//	null or use the criterion of the lowest AIC. Our number of factors would be 
//	6 or 7.

//	Now, if we take a look, the covariance matrix of X computed with our 
//	estimations of Lambda and Phi with 6 factors should be more similar to the
//	sample covariance of X than with, let's say, 1 factor (or whatever).

quietly factor x*, factor(6)	//	quietly is to ask Stata not to show this
								//	outcome
matrix uniqueness = e(Psi)'
matrix Psi = diag(uniqueness)
matrix Lambda = e(L)
matrix Phi = e(Phi)
matrix covariance_X_6factors = Lambda*Phi*Lambda' + Psi
matrix list covariance_X_6factors
quietly factor x*, factor(1)	//	quietly is to ask Stata not to show this
								//	outcome
matrix uniqueness = e(Psi)'
matrix Psi = diag(uniqueness)
matrix Lambda = e(L)
matrix Phi = e(Phi)
matrix covariance_X_1factor = Lambda*Phi*Lambda' + Psi
matrix list covariance_X_1factor
correlate x*

/*-------------------------------------------------------------------------*
 |
 |            					   Problem 1 c)
 |
 *------------------------------------------------------------------------*/

//	Now, let's specifiy the maximum number of factors to be ratained
factor x*, factors(6) m
//	By considering fewer factors, the uniqueness values are larger (there is 
//	more variation of each variable not explained by factors). But, overall,
//	we are explaining the data better (which can be seen in the fact that our
//	covariance matrix estimated with 6 factors is more akin to the sample 
//	covariance of X than any other model).
 
rotate	/*rota las cargas de los factores*/
** rotate= Orthogonal (default); oblique; etc 
 
/*-------------------------------------------------------------------------*
 |
 |            					   Problem 1 d)
 |
 *------------------------------------------------------------------------*/

ereturn list

matrix uniqueness = e(Psi)'   				//	Uniqueness
matrix list uniqueness			
//	Remember that in our slides, the Psi matrix is a diagonal matrix with the   
//	uniqueness (but Stata presents Psi as an horizontal vector).

matrix Lambda = e(L)						//	Factor loadings
matrix list Lambda

matrix ones = J(rowsof(uniqueness), 1, 1)  	//	(row, col, value)
matrix commonality = ones - uniqueness		//	Commonality = Vector de 1s - uniqueness
matrix list commonality

//	This commonality can also been extracted from the sum of the squared factor 
//	loadings for all factors for a given variable:
matrix Lambda = e(L)    		//	Factor loadings
matrix LambdaLambda_tr = L*L'	
matrix list LambdaLambda_tr		//	Sum of squared loads = Commonality, located 
								//	on the diagonal

/*-------------------------------------------------------------------------*
 |                                                                         
 |            			Problem 2: Inicializando Stata							   
 |																		   
 *------------------------------------------------------------------------*/

clear all
set more off
cd "C:\Users\fiona\Dropbox\Materias MAECO\Análisis Estadístico Multivariado\Practicas\PS5new"
use ipc2dig.dta

/*-------------------------------------------------------------------------*
 |
 |            					   Problem 2 a)
 |
 *------------------------------------------------------------------------*/

//	H0 = Multivariate normality
mvtest norm div*
mvtest norm div*, stats(sk ku) 
// We reject multivariate normality in the data

//	Number of factors to use
do ftest
ftest div*, f(1) alpha(0.05)
ftest div*, f(2) alpha(0.05)
ftest div*, f(3) alpha(0.05)
ftest div*, f(4) alpha(0.05)	//	p-value
ftest div*, f(5) alpha(0.05)
ftest div*, f(6) alpha(0.05)
ftest div*, f(7) alpha(0.05)	//	AIC
ftest div*, f(8) alpha(0.05)
ftest div*, f(9) alpha(0.05)
ftest div*, f(10) alpha(0.05)
ftest div*, f(11) alpha(0.05)
ftest div*, f(12) alpha(0.05)

//	Analysis according to previous determination
factor div*, fac(4)
rotate

//	You could get uniqueness, commonality and so on as we did before. We will
//	need this for d).

matrix uniqueness = e(Psi)'   	//	Uniqueness.      
mat Psi = diag(uniqueness) 		//	Remember that in our slides, the Psi matrix   
								//	is a diagonal matrix with the uniqueness  
								//	(but Stata presents Psi as an horizontal 
								//	vector). Here I'm just getting Psi as seen 
								//	in slides. 
matrix list Psi
matrix Sigma = e(C) 			//	Matrix of correlations (the same you get by 
								//	corr div*)

/*-------------------------------------------------------------------------*
 |
 |            					   Problem 2 b)
 |
 *------------------------------------------------------------------------*/
 
 //	For factor analysis, the command predict as we use next creates new 
 //	variables containing predictions of factors scored by the regression method 
 //	(default). 	
 //	With the option norotated, we use unrotated results, even when rotated 
 //	results are available (even if you have previously issued a rotate command).
 //	The default is to use rotated factors if they are available and unrotated 
 //	factors otherwise.
 
predict f1 f2 f3 f4, norotate	//	estimates the factors for each observation with the unrotated loads
mkmat f1 f2 f3 f4, mat(F) 	
matrix list F
  
 /*-------------------------------------------------------------------------*
 |
 |            					   Problem 2 c)
 |
 *------------------------------------------------------------------------*/
//  x = mu + L * f + u 
//  u = X - mu - L * F' 
 
 
//	Center the data
matrix mean_x = e(means)'	//	Means of div* variables
matrix list mean_x
mat one = J(_N,1,1)
matrix list one
mat D = one*mean_x' 		//	Each column is a vector of the mean of a variable
matrix list D
mkmat div*, mat(X) 			//	Store the variables in a matrix 
matlist X
mat X_centered = X-D 		//	Observations centered by the mean of each variable
matrix list X_centered

//	We will also need the estimations for the loadings (the matrix L we 
//	generated in Problem 1) and for the factors (which we already obtained)
matrix L = e(L)    //	Loadings     

//	Estimation for the residuals 
matrix res = X_centered' - L*F' 
matrix res = res'
matrix list res 

//	Take the matrix and store its columns as new variables
svmat res
 
//	Test for multivariate normality
//	H0 = Multivariate normality 
mvtest norm res*, stats(sk ku) 
//	We reject the null hypothesis of normality 

//	Test for diagonality of the variance and covariance matrix
// 	H0: Covariance matrix is diagonal (determinant is 1)  
mvtest covariances res*, diagonal 
//	We reject the null hypothesis
//	As the matrix of covariances is not diagonal, we should increase the number 
//	of factors until the estimated residuals verify that hypothesis.

//	Test by hand with the test seen in slides of theory 
corr res*   
matrix R = r(C) 			//	Capture residual correlation 
matrix def diag_R = I(r(N))	//	Identity matrix
matrix list diag_R
//	Test
local est = -(`N'-1-((2*26+5)/6))*ln(det(R))
local v_c = invchi2((26*25)/2, 0.95)
local p_v = chi2tail((26*25)/2, `est')
display in yellow "Estadistico = `est'"
display in yellow "Valor critico = `v_c'"
display in yellow "P-value = `p_v'"
mat det_R = det(R)
mat det_diag = det(diag_R)
scalar co_det = det_diag[1,1]/det_R[1,1]
local est = -(51)*ln(co_det)
local v_c = invchi2((26*25)/2, 0.95)
local p_v = chi2tail((26*25)/2, `est')
display in yellow "Estadistico = `est'"
display in yellow "Valor critico = `v_c'"
display in yellow "P-value = `p_v'" //	Reject the null with determinant = 1 

 /*-------------------------------------------------------------------------*
 |
 |            					   Problem 2 d)
 |
 *------------------------------------------------------------------------*/

//	We will use the following statistics:
//	1)	Squared correlation coefficient
//	2)	Coefficient of determination (R squared)	

//	1)	Squared correlation coefficient between the variable and the factors for
//		each of the 26 variables.
//		Note: The variables are standardized, so the variance is one (that is why
//		I am dividing by one instead of using s_i).
forvalues i=1/26 {
                 local rho2_`i' = 1-((el(uniqueness, `i',1)^(2))/1)	
                 display "rho2_`i' = `rho2_`i''"
}
//	Remember: el(matrix, row, collumn) is to extract an element from a matrix.
//	Here, we are using to extract the uniqueness (which is saved in e2)

//	2)	Coefficient of determination (R squared)	
local R2 = 1-((det(Psi)^(1/26))/(det(Sigma)^(1/26)))
display "R2 = `R2'"
//	The bigger the better. In this case, the fit is great.