/******************************************************************
TEST de DETERMINACION del NUMERO de FACTORES
Tener presente que stata realiza el analisis de factores sobre los
datos estandarizados (media= 0; st dev= 1)
********************************************************************/


capture program drop ftest

program define ftest

          syntax varlist(max=26) , f(real) alpha(real)
          
          local p: word count `varlist'   /*p : N de variables*/
          local N = _N
          local m = `f'

          quietly factor `varlist', ml factor(`f')
          matrix Co = e(C)
          matrix e2 = e(Psi)'    /*uniquenness*/
          mat L = e(L)          /*cargas*/
          mat LL_tr = L*L'         /*  p*p   */

         /*Varianzas especificas*/
         mat uu =diag(e2)     /*matriz p*p    */
         mat Vo = LL_tr + uu
		 
         /*test*/
         /*Estadistico:*/
         local ln0 = ln(det(Vo))
         local ln1 = ln(det(Co))
         local num = ((`N'-1)-((2*`p'+4*`m'+5)/6))
         local est = `num'*(`ln0' - `ln1')
		 local aic = `N'*(`ln0' - `ln1')-((`p'-`m')^(2)-`p'-`m')
         /*valor critico*/
         local gl = (((`p'-`m')^(2))-(`p'+`m'))/2
         local v_c = invchi2((`gl'), (1-`alpha'))
         /*p-value*/
         local pv = chi2tail((`gl'), `est')  
		 
         display in green "---------TEST-------------------"
         display in yellow "Estadistico = `est'"
         display in yellow "Valor critico = `v_c'"
         display in yellow "P-value = `pv'"
		 display in yellow "AIC = `aic'"
         display in green "--------------------------------"


end