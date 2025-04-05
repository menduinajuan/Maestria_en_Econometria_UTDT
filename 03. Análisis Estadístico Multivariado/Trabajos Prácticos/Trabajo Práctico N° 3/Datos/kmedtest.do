/************************************************************************
TEST F PARA LA SELECCIÓN DEL NUMERO DE GRUPOS.
ALGORITMO DE LAS K MEDIAS

COMPARA G "grupos" CONTRA G+1 "grupos"
*****************************************************************************/


capture program drop kmedtest

program define kmedtest

             syntax varlist(max=30), k(real)
             
               local p: word count `varlist'  /*p : Nro. de variables*/  
               local N = _N
               tokenize `varlist'
               
               tempvar pre
               tempvar pre1
               
			   cluster kmeans `varlist', k(`k')  generate(`pre') start(firstk)
               
               /*SCDG*/
               forvalues i=1/`k' {
								  quietly count if `pre'==`i'
								  local n`i' = r(N)
								  local a`i' = 0
                                  forvalues j=1/`p' { 
                                                     quietly sum ``j'' if `pre'==`i'
                                                     if r(Var)!=. {
                                                                   local aux = r(Var)
                                                                  }
                                                     if r(Var)==. {
                                                                   local aux = 0
                                                                  }
                                                     local a`i' = `aux'+ `a`i''
                                                     }
                                  local b`i' = `n`i''*`a`i''
                                 }
               
               local G = 0
               forvalues i=1/`k' {
                                  local G = `b`i''+`G'
                                 }

             
               local h = `k'+1
               cluster kmeans `varlist', k(`h')  generate(`pre1') start(firstk)
               
               /*SCDG*/
               forvalues i=1/`h' {
				  quietly count if `pre1'==`i'
                  local n`i' = r(N)
                  local a`i' = 0 
                  forvalues j=1/`p' { 
                                     quietly sum ``j'' if `pre1'==`i'
                                     if r(Var)!=. {
                                                   local aux = r(Var)
                                                  }
                                     if r(Var)==. {
                                                   local aux = 0
                                                  }
                                     local a`i' = `aux'+ `a`i''
                                    }
                                  local b`i' = `n`i''*`a`i''
                                 }
  
               local G1 = 0
               forvalues i=1/`h' {
                                  local G1 = `b`i''+`G1'
                                 }

          /************TEST*************/
          local est = ((`G'-`G1')/(`G'/(`N'-`k'-1)))
          local pv = Ftail(`p', `p'*(`N'-`k'-1), `est')
          di in yellow "**********TEST************"
          di in green  "Estadistico = `est'       "
          di in green  "P-value = `pv'            "
          di in yellow "**************************"

end