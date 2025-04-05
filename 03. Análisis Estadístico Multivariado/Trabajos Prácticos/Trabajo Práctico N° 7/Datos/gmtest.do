/*****************************************************************
TEST DE IGUALDAD DE MEDIAS
Muestra de tamaño "n"
variable "p" dimensional
estratificada en "G" grupos
La primera variable indica el grupo
********************************************************************/


capture program drop gmtest

program define gmtest

              syntax varlist(max=30)
               
               local a: word count `varlist'   
               local p = `a'-1            /*p : Núm. de variables*/
               local N = _N
               tokenize `varlist'
               
               
               tempvar id
               
               sort `1'              
               egen `id' = group(`1')   /*1 a G*/
               quietly sum `id'
               local G = r(max)         /*Núm. de grupos*/
                                 
               forvalues i=2/`a' {
                                 local j = `i'-1
                                 tempvar var_`j'
                                 gen `var_`j'' = ``i''
                                 }
								 
               /*Vector de medias; uno por grupo*/
               forvalues i= 1/`G' {
                                   mat media`i' = J(`p',1,.)
                                   }
              
               forvalues h=1/`G' {
                                  forvalues i= 1/`p'{
											         quietly sum `var_`i'' if `id'==`h'
											         matrix media`h' [`i', 1] = r(mean)
                                                    }
                                  }
 
               

               /*Suma de diferencias de cada observación respecto al vector de medias de cada grupo por grupo*/     
               sort `id'
               forvalues k=1/`G' {
                                  mat A`k' = J(`p', `p', 0)
                                  preserve
                                  quietly keep if `id'==`k'
                                  quietly count
                                  local n = r(N) /*Núm. de obs del grupo*/
                                  quietly drop `id'
                                  forvalues i=1/`n' { 
                                                     keep __*    /*se queda con las temporales*/ 
                                                     mkmat __* in `i', mat(x`i')
                                                     mat aa = ((x`i')'-media`k')*((x`i')'-media`k')'
                                                     mat A`k' = aa+A`k'
                                                     }
                                  restore
                                  }


              /*Suma de las diferencias en cada grupo*/
              mat B = J(`p', `p', 0)
              forvalues k= 1/`G' {
                                   mat B = B+A`k'
                                   }

            

			  /*Matriz de Var-Cov*/
              preserve
              drop `id'
              quietly matrix accum aux = __*, deviation nocons
              mat S = aux/(_N-1)
              mat S_inv =inv(S)
              restore

          mat Sw = (B/(`N'-1))
           
		  /*Contraste*/
		  local m = (`N'-1)-(`p'+`G')/2
          local stat = `m'*ln((det(S)/det(Sw)))
          local gl = `p'*(`G'-1)                
          local pv = chi2tail((`gl'), `stat')
          di in yellow "----------TEST---------------"
          di in green  "Estadistico = `stat'"
          di in green "P-value = `pv'"
          di in yellow "-----------------------------"
          



end