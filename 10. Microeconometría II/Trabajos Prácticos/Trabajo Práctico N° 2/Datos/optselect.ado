* Stata function that calculates the optimal cutoff points for the propensity score 
* (to calculate Optimal Subpopulation Average Treatment Effect, OSATE) based on the propensity scored distribution, 
* as proposed by Crump, R.K., V.J. Hotz, G.W. Imbens and O.A. Mitnik (2008) "Dealing with limited overlap in 
* estimation of average treatment effects", Biometrika, Vol. 96, Number 1, 187-199, March 2009.

* See help file for details.

* First on-line version: December 3, 2008
* This version: November 12, 2010 (fixed small errors in a grid search loop)

program optselect, rclass
	version 9.2
	syntax varlist(max=1) [in] [if]

	* Marks sample to use
	marksample touse

	* Calls mata function
	mata: optselect_mat("`varlist'","`touse'")
	local bound = bound[1,1]

	* Messages and display results
	di as txt " "
	if maxiter[1,1] == 1 {
		di as txt "Optimal bound could not be calculated (max # of iterations attained)"
		di as result "Bound set to 0.10"
	}
	if maxsup[1,1] == 1 {
		di as txt "Optimally is not necessary to trim the propensity score distribution"
	}
	di as txt " "	
	if maxiter[1,1] ==0 di as result "Optimal bound = `bound'"
	
	* Return results
	return scalar bound = bound[1,1]
	return scalar maxiter = maxiter[1,1]
	return scalar maxsup = maxsup[1,1]
end


* Mata function 
version 9.2
mata:
void optselect_mat(string psvar, string scalar touse)
{
	/// Reads pscore
	pscore=J(0,0,0)
	st_view(pscore,.,psvar,touse)

	ipscore=1:/pscore
	mscore=1:-pscore
	imscore=1:/mscore
	g=ipscore:*imscore

	// Initial values for a_low avoids extremely high values of gamma_low function
	// and initial value of a_high makes sure is withing observed range of pscore
	a_low=0.0001
	b_low=1-a_low
	gamma_high=4
	a_high=min((0.5-sqrt(0.25-1/(2*gamma_high)),max(pscore)))
	b_high=1-a_high
	gamma_high=mean(select(g,((pscore:>=a_high):&(pscore:<=b_high))))
	
	// Check if condition for optimally trimming the propensity score distribution holds
	// if it does not, then stops and reports 0 as optimal lower bound and 1 as optimal upper bound
	// (and sets "maxsup"=1)
	if (max(g)<= 2*mean(g)) { // If this condition is satisfied, it is not necessary to calculate optimal
	                          // bound (optimal lower and upper bounds are 0 and 1)
	    maxsup=1 // Indicator function "maxsup" is one when optimal PS support is maximum (0 to 1)
	    bound=0
	    maxiter=0
	    st_matrix("bound",bound)
	    st_matrix("maxsup",maxsup)
	    st_matrix("maxiter",maxiter)
	    return // Ends this run of the function
	}
	
	// If the function continues here is because optimal bound needs to be calculated
	maxsup=0
	
	// Find the optimal bound
	checkk=0
	icount=0
	while (checkk==0) {
	    icount=icount+1
	    difa=abs(a_high-a_low)
	
	    gamma_low=mean(select(g,((pscore:>=a_low):&(pscore:<=b_low))))
	    a_low=0.5-sqrt(0.25-1/(2*gamma_low))
	    b_low=0.5+sqrt(0.25-1/(2*gamma_low))
	
	    a_high=0.5-sqrt(0.25-1/(2*gamma_high))
	    b_high=0.5+sqrt(0.25-1/(2*gamma_high))
	    gamma_high=mean(select(g,((pscore:>=a_high):&(pscore:<=b_high))))
	
	    // When a_low and a_high stop converging performs a grid seach between the values
	    // of a_low and a_high to find a different starting point of the parameter that is
	    // not moving 
	    if (difa==abs(a_high-a_low) & icount>1) {
	        var_grid=J(0,1,0)
	        a_grid=J(0,1,0)
	        
	        for (grid=a_low;grid<=a_high;grid=grid+(difa/100)) {
	            q_grid=rows(select(g,((pscore:>=grid):&(pscore:<=(1-grid)))))/rows(pscore)
	            gamma_grid=mean(select(g,((pscore:>=grid):&(pscore:<=(1-grid)))))
	            var_grid=(var_grid\(gamma_grid/q_grid))
	            a_grid=(a_grid\grid)
	        }
	        a_low=min(select(a_grid,(var_grid:==min(var_grid))))
	        b_low=1-a_low
	        a_high=max(select(a_grid,(var_grid:==min(var_grid))))
	        b_high=1-a_high
	        gamma_low=mean(select(g,((pscore:>=a_low):&(pscore:<=b_low))))
	        gamma_high=mean(select(g,((pscore:>=a_high):&(pscore:<=b_high))))
	    }
	    
	    q_low=rows(select(g,((pscore:>=a_low):&(pscore:<=b_low))))/rows(pscore)
	    q_high=rows(select(g,((pscore:>=a_high):&(pscore:<=b_high))))/rows(pscore)
	    var_low=gamma_low/q_low
	    var_high=gamma_high/q_high
	    
	    // Stops when a_high and a_low are close enough OR imply exactly the same variance
	    // OR a maximum number of iterations is attained 
	    checkk=(abs(a_high-a_low)<0.001)+(var_high==var_low)+(icount>100)
	}
	
	bound=a_low
	maxiter = icount>100 // Indicator for max # of iterations attained 
	if (icount>100) bound=0.1
	
	// Returns results to Stata
	st_matrix("bound",bound)
	st_matrix("maxsup",maxsup)
	st_matrix("maxiter",maxiter)
}
end