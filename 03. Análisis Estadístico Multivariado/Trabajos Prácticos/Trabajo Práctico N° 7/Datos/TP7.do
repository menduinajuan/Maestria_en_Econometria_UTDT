/*-------------------------------------------------------------------------*
 |
 |            				    PS6:AEM, 2021
 |
 *------------------------------------------------------------------------*/

/*
Multivariate discrimination and separation techniques have to do with being able
to distinguish different sets of elements and with being able to assign a new 
element to any of the previously defined sets.
 - The objective of discrimination is linked to describing the differential aspects 
of objects that belong to different groups.
 - The objective of the classification is related to the possibility of ordering 
objects or elements in two or more groups and optimal classification rules.
*/

/*-------------------------------------------------------------------------*
|
|            					   Problem 1 a)
|
*------------------------------------------------------------------------*/

clear
set more off
cd "C:\Users\fiona\Dropbox\Materias MAECO\Análisis Estadístico Multivariado\Practicas\PS7New"
use firmas.dta
rename ebitass ebitda 
 
sum ebitda rotc
sum ebitda rotc if  group == 0	//	Good performance
sum ebitda rotc if  group == 1	//	Bad performance
twoway (scatter ebitda rotc if group == 0, legend(label(1 "Good performing companies"))) ///
(scatter ebitda rotc if group == 1, legend(label(2 "Poor performing companies")))
//	The firms with good performance present high levels of EBITASS, and ROTC, 
//	in relative terms to the bad ones.

/*-------------------------------------------------------------------------*
 |
 |            					   Problem 1 b)
 |
 *------------------------------------------------------------------------*/

//	Test of equality of means stratified in "G" groups

//	H0: equal means
//	H1: different averages
do gmtest.do 	//	MANOVA test, or test of equality of means for G groups
gmtest group ebitda rotc 
// We reject H0


** In a more intuitive way: 
ttest ebitda, by(group)
ttest rotc, by(group)


/*-------------------------------------------------------------------------*
 |
 |            					   Problem 1 c)
 |
 *------------------------------------------------------------------------*/

//	discrim lda performs linear discriminant analysis. The "discrim" commands
//	is also used for other discrimination commands.

//	So, the linear discriminant analysis of ebitda and rotc for groups defined 
//	by the categorical variable "group" is
discrim lda ebitda rotc, group(group) 

//	By default, the prior probabilities are:
//	P(group 0) = number of observations in group 0 / number of observations
//	P(group 1) = number of observations in group 1 / number of observations

//	So, we can also use:
discrim lda ebitda rotc, group(group) priors(.5, .5) 

//	We can specify prior probabilities for each group
discrim lda ebitda rotc, group(group) priors(.1, .9) 
discrim lda ebitda rotc, group(group) priors(0.000001, 0.999999) 

// Group-size-proportional prior probabilities
discrim lda ebitda rotc, group(group) priors(proportional) 

//	Again, to save in memory the estimations with the correct priors
discrim lda ebitda rotc, group(group) 


** Obtain loadings:
estat loadings, unstandardized

mat list r(L_unstd)

/*

	 0 = w0 + w1 * x + w2 * y 
w2 * y = - w0 + w1 * x
     y = -w0/w2 + w1/w2 * x 
	 y = a0 + a1 * x 

y=ebidta, x=rotc
*/

scalar define w0 = r(L_unstd)[3,1]
scalar define w1 = r(L_unstd)[2,1]
scalar define w2 = r(L_unstd)[1,1]

scalar a0 = -w0/w2
scalar a1 = -w1/w2

/*
twoway (scatter ebitda rotc if group == 0, legend(label(1 "Group 0"))) ///
(scatter ebitda rotc if group == 1, legend(label(2 "Group 1"))) ///
(function y = -0.3782*x+0.13264110, range(rotc) legend(label(3 "Line")))
*/

twoway (scatter ebitda rotc if group == 0, legend(label(1 "Group 0"))) ///

** Obtain classification results and probabilities
estat list 
/*
+-----------------------------------------+
|     | Classification   | Probabilities  |
|     |                  |                |
| Obs.|   True  Class.   |      0       1 |
|-----+------------------+----------------|
|   1 |      0       0   | 0.9962  0.0038 |
|   2 |      0       0   | 0.9999  0.0001 |
|   3 |      0       0   | 0.9998  0.0002 |
|   4 |      0       0   | 1.0000  0.0000 |
|   5 |      0       0   | 0.9997  0.0003 |
|-----+------------------+----------------|
|   6 |      0       0   | 0.9999  0.0001 |
|   7 |      0       0   | 0.9950  0.0050 |
|   8 |      0       0   | 1.0000  0.0000 |
|   9 |      0       0   | 0.5373  0.4627 |
|  10 |      0       0   | 0.9788  0.0212 |
|-----+------------------+----------------|
|  11 |      0       0   | 0.9993  0.0007 |
|  12 |      0       0   | 0.9994  0.0006 |
|  13 |      1       1   | 0.0001  0.9999 |
|  14 |      1       1   | 0.0112  0.9888 |
|  15 |      1       1   | 0.0086  0.9914 |
|-----+------------------+----------------|
|  16 |      1       1   | 0.0000  1.0000 |
|  17 |      1       1   | 0.0000  1.0000 |
|  18 |      1       1   | 0.0004  0.9996 |
|  19 |      1       1   | 0.0013  0.9987 |
|  20 |      1       0 * | 0.5727  0.4273 |
|-----+------------------+----------------|
|  21 |      1       1   | 0.0000  1.0000 |
|  22 |      1       1   | 0.0239  0.9761 |
|  23 |      1       1   | 0.0001  0.9999 |
|  24 |      1       1   | 0.0019  0.9981 |
+-----------------------------------------+
* indicates misclassified observations

*/

//	Classification and estimated ex post probabilities (posterior probabilities) 
//	for all observations

//	Now we will examine what are called classification functions with the estat 
//	classfunctions command. Classification functions are applied to the 
//	unstandardized discriminating variables. The classification function that 
//	results in the largest value for an observation indicates the group to 
//	assign the observation. This is not the Fisher's approach to LDA, but the
//	Mahalanobis's approach.

estat classfunctions /*Muestra los coeficientes de ambas funciones discriminantes*/
//	muestra las funciones discriminantes

/*
Classification functions

                 | group                
                 |         0          1 
    -------------+----------------------
          ebitda |  61.23745    2.55117 
            rotc |  21.02689  -1.404444 
           _cons |   -7.7876  -.0033742 
    -------------+----------------------
          Priors |        .5         .5 
*/

//	The prior probabilities, used in constructing the coefficient for the 
//	constant term, are displayed as the last row in the table.

/*-------------------------------------------------------------------------*
 |
 |            					   Problem 1 d)
 |
 *------------------------------------------------------------------------*/

 
** Obtain predicted probabilities P( Population_i | x0 ) 
predict pp_1 pp_2


//	Pedict creates a new variable containing predictions such as group 
//	classifications, probabilities, Mahalanobis squared distances and so on.
//	When you specify multiple variables, the default gives you the probabiltiy
//	of group membership. 
//	"predict pp_1 pp_2, pr" gives the same result
//	Notice, the new variables pp_1 and pp_2 are those we got from the table of
//	the command "estat list"


** Obtain group classification
predict clasif,  classification 

** Obtain mahalanobis distance
predict d, maha

/*-------------------------------------------------------------------------*
 |
 |            					   Problem 1 e)
 |
 *------------------------------------------------------------------------*/
 
// si ebitda == rotc == 0.1 en la función discriminante es mayor que 0; Buena firma*/

local ebit = 0.1
local rotc = 0.1

local new = w0 + w1 * `rotc' + w2 * `ebit' 

local new = 15.09192*`ebit' + 5.768501*`rotc' -2.001812
display `new'	//	>0, then it is a good performance firm

twoway (scatter ebitda rotc if group == 0, legend(label(1 "Group 0"))) ///
(scatter ebitda rotc if group == 1, legend(label(2 "Group 1"))) ///
(function y = -0.3782*x+0.13264110, range(rotc) legend(label(3 "Line"))), yline(0.1) xline(0.1) 


/*-------------------------------------------------------------------------*
 |
 |            					   Problem 2
 |
 *------------------------------------------------------------------------*/

clear
set more off

use muestra_engh.dta

/*-------------------------------------------------------------------------*
 |
 |            					   Problem 2 a)
 |
 *------------------------------------------------------------------------*/

//	Test of equality of means stratified in "Groups

do gmtest.do 
gmtest region cap*
//	H0: equality of means H1: different means
//	H0 rejection of equality of means

sum cap* if region==1
sum cap* if region==4
sum cap* if region==6

table region, stat(mean cap*)

/*-------------------------------------------------------------------------*
 |
 |            					   Problem 2 b)
 |
 *------------------------------------------------------------------------*/

//	First I do the discriminant analysis using the function and then I compare 
//	with that of Mahalanobis

//	Discriminante
//	We have: 3 groups.
//         9 variables.
//         ==> r = min (G-1, p) = 2: Projection Directions

sort region
egen id = group(region)


//	Covariance matrix
matrix accum aux = cap1 cap2 cap3 cap4 cap5 cap6 cap7 cap8 cap9, deviation nocons
mat S = aux/(_N-1)
mat list S

// Inverse 
mat S_inv =inv(S)
mat list S_inv

// Number of variables
local p: word count cap1 cap2 cap3 cap4 cap5 cap6 cap7 cap8 cap9 
di `p'

//	The following vectors have the mean for each group 

forvalues i=1/3 {
				mat media`i' = J(`p',1,.)
				}
					
forvalues h=1/3 {
                 forvalues i= 1/`p'{
                                    quietly sum cap`i' if id==`h' 
                                    matrix media`h' [`i', 1] = r(mean)
                                   }
                 mat l media`h'
                }
//

//	Let's find the parameters of each discriminant function using the means 
//	vectors and precision matrix * /		

forvalues i= 1/3 {
                  mat alpha`i' = (media`i')'*S_inv 
                  mat l alpha`i'
                 }
				  
forvalues i= 1/3 {
                  mat c`i' = alpha`i'*media`i' // Constant (discriminant function)
                  mat l c`i'
                 }
				 

/*-------------------------------------------------------------------------*
 |
 |            					   Problem 2 c)
 |
 *------------------------------------------------------------------------*/
				 			 
forvalues i= 1/3{
                 local c = el(c`i',1,1) 
                 forvalues j= 1/9{
                                  local a`j' = el(alpha`i', 1, `j')
                                 }
//	Build the discriminant function for each i						 
                 gen p`i' = (`a1'*cap1+`a2'*cap2+`a3'*cap3+`a4'*cap4+`a5'*cap5+`a6'*cap6+`a7'*cap7+`a8'*cap8+`a9'*cap9)-`c'/2
                }
//				
//	Classify in that group with the highest value in the discriminant function
gen predict = .
replace predict = 1 if (p1>p2 & p2>p3) | (p1>p3 & p3>p2)
replace predict = 2 if (p2>p1 & p1>p3) | (p2>p3 & p3>p1)
replace predict = 3 if (p3>p1 & p1>p2) | (p3>p2 & p2>p1)

/*-------------------------------------------------------------------------*
 |
 |            					   Problem 2 d)
 |
 *------------------------------------------------------------------------*/

//	Discriminant analysis using the Mahalanobis distances with respect to the 
//	mean of each group.
 
//	Mahalanobis
gen D1 = .
gen D2 = .
gen D3 = .
count //	Counts the number of observations
local N =r(N)
forvalues j = 1/`N' {
     
	 //	distances for each group, use their respective means function
     forvalues i = 1/3 {
                mkmat cap* in `j', mat(x) 					//	creates a vector of the observation "j"
                mat aux =(x'-media`i')'*S_inv*(x'-media`i') //	This matrix is a scalar that represents the Mahalanobis distance with respect to the mean `i'
                local a = el(aux,1,1) 						
                quietly replace D`i' = `a' if _n==`j' 		//	Save the previous location local 
                       }
                }
//
//	We have 3 variables that summarize the Mahalanobis distance with respect to 
//	each of the mean corresponding to each of the 3 subpopulations			
			
//	Predictions

gen predict1 = .
replace predict1 = 1 if (D1<D2 & D2<D3) | (D1<D3 & D3<D2)
replace predict1 = 2 if (D2<D1 & D1<D3) | (D2<D3 & D3<D1)
replace predict1 = 3 if (D3<D1 & D1<D2) | (D3<D2 & D2<D1)

//	Build the prediction according to the relative distances. Each observation 
//	will belong to the group to which it is closest to its mean

//	Both methodologies used are equivalent

table predict predict1

/*-------------------------------------------------------------------------*
 |
 |            					   Problem 2 e)
 |
 *------------------------------------------------------------------------*/

mat TABLE = J(3,3,.)
forvalues i = 1/3 {
                   forvalues j = 1/3 {
                                      count if id==`i' & predict1==`j'  	//	i: observed; j: prediction
                                      local a_`i'_`j' = r(N) 				//	count the number of predictions in each group that were assigned correctly
                                      mat TABLE [`i', `j'] = `a_`i'_`j'' 	//	save the number in each element of the table
                                     }
                  }

mat l TABLE
local pred_ok = el(TABLE, 1,1) + el(TABLE, 2,2) + el(TABLE, 3,3) //	Elements of the diagonal are the correct predictions
di "Correct = `pred_ok'"


local N =_N
local pred_wr = `N' - `pred_ok' //	Elements that were not classified correctly
di "Incorrect = `pred_wr'"

//	Both tables match
discrim lda cap*, group(id) 

stop

/*-------------------------------------------------------------------------*
 |
 |            					   Problem 2 f)
 |
 *------------------------------------------------------------------------*/

//	Assuming matrix of variances and unequal covariances, they are estimated for 
//	each group.

forvalues i = 1/3 {
                   count if id==`i'
                   local n=r(N)
                   matrix accum aux = cap1 cap2 cap3 cap4 cap5 cap6 cap7 cap8 cap9 if id==`i', deviation nocons
                   mat S`i' = aux/(`n' - 1)
                   mat S`i'_inv =inv(S`i') // precision matrix for each subgroup
                  }
//	Fixed the argument of the inv function
				  
forvalues i= 1/3 {
                  local c`i' = (1/2)*ln(det(S`i')) // let's compute the constant
                  di `c`i''
                 }

//	Distances of mahalanobis + (1/2) ln (det (S`i ')), the second term is the 
//	corrected constant
gen D_1 = .
gen D_2 = .
gen D_3 = .
count
local N = r(N)

//	Removed wrong line in loop j

forvalues j = 1/`N' {
                     forvalues i = 1/3 {
                                        mkmat cap* in `j', mat(x)
                                        mat aux =(x'-media`i')'*S`i'_inv*(x'-media`i')	//	Mahalanobis distance 
                                        local a = (1/2)*el(aux,1,1)
                                        quietly replace D_`i' = (`a'+`c`i'') if _n==`j'
                                       }
                    }

*Predicciones
gen predict_1 = .
replace predict_1 = 1 if (D_1<D_2 & D_2<D_3) | (D_1<D_3 & D_3<D_2)
replace predict_1 = 2 if (D_2<D_1 & D_1<D_3) | (D_2<D_3 & D_3<D_1)
replace predict_1 = 3 if (D_3<D_1 & D_1<D_2) | (D_3<D_2 & D_2<D_1)


mat TABLEc = J(3,3,.)
forvalues i = 1/3 {
                   forvalues j = 1/3 {
                                      count if id==`i' & predict_1==`j' //	i: observed; j: prediction
                                      local ac_`i'_`j' = r(N)
                                      mat TABLEc [`i', `j'] = `ac_`i'_`j''
                                     }
                  }

mat l TABLEc

//	Tables match

local pred_ok = el(TABLEc, 1,1)+el(TABLEc, 2,2)+el(TABLEc, 3,3)
di "Correct = `pred_ok'"
local N =_N
local pred_wr = `N'-`pred_ok'
di "Incorrect = `pred_wr'"

//	This is worse, there are more incorrect classifications.
discrim qda cap*, group(id)