/*==============================================================================
 Analisis Estadistico Multivariado - UTDT 
 Problem Set 0

 Fiona Franco Churruarín 
===============================================================================*/

* Settings

cap log close 
clear all 
set more off, permanently 

cd "C:\Users\fiona\Dropbox\Materias MAECO\Análisis Estadístico Multivariado\Clases Practicas\PS0"

*log using "./logs/PS_0_Solucion.smcl"

* correr con ctrl+d 

*-------------------------------------------------------------------------------
**# Ejercicio 1
*-------------------------------------------------------------------------------

* 1) a) ------------------------------------------------------------------------

* Abrimos la base 
use "./data/Hogar_t403_0.dta", clear

* Primera inspeccion
describe 
summarize

* ---> La variable que identifica viviendas es CODUSU
rename CODUSU codusu 

isid codusu 


* 1) b) ------------------------------------------------------------------------

* Queremos contar viviendas
codebook codusu


* 1) c) ------------------------------------------------------------------------

* Queremos averiguar el monto promedio de ingreso total familiar 
* de los hogares correspondientes al aglomerado Gran Resistencia

preserve 
	keep codusu nro_hogar ano4 trimestre region pondera IX_Tot itf ipcf  
	save ./data/Hogar_t403_1.dta, replace
restore


* 1) d) ------------------------------------------------------------------------

* Queremos encontrar el valor medio del ingreso total familiar en Gran Resistencia


* Forma 1 - Usando toda la base de la encuesta
*---------------------------------------------

tab aglomerado
des aglomerado

* Usando valor de las categorias
label list aglomerado

summarize itf if aglomerado == 8 
summarize itf if aglomerado == 8 [fw=pondera]
summarize itf if aglomerado == 8 [fw=pondera], detail

codebook  itf if aglomerado == 8


* Usando texto
decode aglomerado, generate(aglomerado_str)

summarize itf if aglomerado_str == "Gran Resistencia"
codebook  itf if aglomerado_str == "Gran Resistencia"


* Forma 2 - Que pasaria si tuviesemos Hogar_t403_1.dta y un otro archivo con aglomerados?
*----------------------------------------------------------------------------------------

** Creamos archivo con aglomerados para hacer de cuenta que estamos en esa situacion
preserve 
	keep codusu  nro_hogar aglomerado
	save ./data/Hogar_t403_2.dta, replace
restore

*** Abrimos la base pequeña
clear
use "./data/Hogar_t403_1.dta"
 
*** Unimos los aglomerados
merge 1:1 codusu nro_hogar using ./data/Hogar_t403_2.dta

*** Calculamos
summ itf if aglomerado==8



*-------------------------------------------------------------------------------
**# Ejercicio 2
*-------------------------------------------------------------------------------

* En versiones viejas de Stata se necesita este comando
set matsize 600 

* 2) a) ------------------------------------------------------------------------

* Creamos la matrix X
mkmat IX_Tot itf ipcf if _n <= 600, matrix(X)
mat list X

* _n es el indicador de filas

* Calculamos X' 
matrix Xt = X'
mat list Xt

* Calculamos X'X
matrix XtX = Xt * X
mat list XtX

* Calculamos XX' 
matrix XXt = X*X'

* Calculamos (X'X)^{-1} 
matrix XtXinv = inv(XtX)
mat list XtXinv


* 2) b) ------------------------------------------------------------------------
 
matrix B = [ 1,2,3 \ 4,5,6 \ 7,8,9 ]
mat list B

matrix LHS = (XtX + B)'
matrix list LHS

matrix RHS = (XtX)' + B'
mat list RHS

matrix LHS==RHS


* 2) c) ------------------------------------------------------------------------
 
* Computamos la traza 
scalar Tr = trace(XtX)
display Tr
 
scalar Det = det(XtX)
display Det

* 2) d) ------------------------------------------------------------------------

* Definimos el escalar gamma
scalar phi = 1/1000

* Multiplicamos gamma * X'X
matrix phi_XtX = phi * XtX

scalar LHS = det(phi_XtX)
display LHS

scalar RHS = phi^(colsof(X)) * Det 
display RHS 



*-------------------------------------------------------------------------------
**# Ejercicio 3
*-------------------------------------------------------------------------------

* 3) a) ------------------------------------------------------------------------


/* 
Queremos ver que
 		(A + BCD)^(-1) = A^(-1) - A^(-1)B(DA^(-1)B + C^(-1))^(-1)DA^(-1)
*/
 
* Definimos A
matrix A = ( 23,21,34 \ 65,67,32 \ 13,12,32 )
matrix list A

* Definimos B
matrix B = ( 23,2 \ 22,15 \ 3,7 )
matrix list B

* Definimos C
matrix C = ( 1,3 \ 2,13 )
matrix list C

* Definimos D
matrix D = ( 34,25,2 \ 3,14,32 )
matrix list D

* Lado izquierdo y derecho 
matrix LHS = inv(A + B*C*D)
matrix RHS = inv(A)-inv(A)*B*inv(D*inv(A)*B+inv(C))*D*inv(A)

mat list LHS
mat list RHS


* 3) b) ------------------------------------------------------------------------

/* 
Queremos ver que
		(A_11 + C)^(-1) = C^(-1)(A_11^(-1) + C^(-1))^(-1)A_11^(-1)
*/

* Generamos la sub-matriz A_{11} con filas 1 a 2 y columnas 1 a 2
matrix A11 = A[1..2,1..2] 
matrix list A11

* Lado izquierdo y derecho 
matrix LHS = inv(A11 + C)
matrix RHS = inv(C)*inv(inv(A11)+inv(C))*inv(A11)

matrix list LHS
matrix list RHS



*-------------------------------------------------------------------------------
**# Ejercicio 4
*-------------------------------------------------------------------------------

* Importamos la matriz que esta en un excel
import excel ./data/Mat4.xlsx, firstrow clear

*firstrow: la primera fila del array tiene nombres 

* Chequeamos 
list, sep(10)
browse

* Armamos una matriz
mkmat v1-v8, mat(B)
*mkmat v1 v2 v3 v4 v5 v6 v7 v8, mat(B)
*mkmat v*, mat(B)
mat list B 


* Determinante
*-------------

** Calculamos las particiones
matrix B11 = B[1..4,1..4]
matrix B12 = B[1..4,5..8]
matrix B21 = B[5..8,1..4]
matrix B22 = B[5..8,5..8]

matrix list B11
matrix list B12
matrix list B21
matrix list B22  

** Calculamos el determinante con la formula particionada (identidad de Schur)
matrix DetBp = det(B22)*det(B11 - B12*inv(B22)*B21)
matrix list DetBp

** Verificamos el determinante
scalar DetB = det(B)
display DetB


* Inversa
*--------

* Inversa de B11
matrix B11inv = inv(B11 - B12*inv(B22)*B21)
matrix list B11inv

* Inversa de B12
matrix B12inv = -inv(B11 - B12*inv(B22)*B21)*B12*inv(B22)
matrix list B12inv

* Inversa de B21
matrix B21inv = -inv(B22)*B21*inv(B11 - B12*inv(B22)*B21)
matrix list B21inv

* Inversa de B22
matrix B22inv = inv(B22) + inv(B22)*B21*inv(B11 - B12*inv(B22)*B21)*B12*inv(B22)
matrix list B22inv

* Inversa de B particionada
matrix Bpinv= ( B11inv, B12inv  \ B21inv, B22inv )
matrix list Bpinv

** Verificamos la inversa 
matrix Binv = inv(B)
matrix list Binv