clear all
set more off

*local disco="C:/"
local disco="G:/Mi unidad"
cd "`disco'/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/3. Análisis Estadístico Multivariado/Trabajos Prácticos/Trabajo Práctico N° 0/Datos"


*##############################################################################*
								* EJERCICIO 1 *
*##############################################################################*


use "Hogar_t403_0", clear
describe

*INCISO (a)*

rename CODUSU codusu
describe codusu
isid codusu

*INCISO (b)*

codebook codusu
unique codusu
display as text "En total, fueron relevados " as result r(unique) as text " hogares"

*INCISO (c)*

keep codusu nro_hogar ano4 trimestre region aglomerado pondera IX_Tot itf ipcf
save "Hogar_t403_1", replace

*INCISO (d)*

tabulate aglomerado
label list aglomerado
summarize itf [w=pondera] if (aglomerado==8)
display as text "El monto promedio de ingreso total familiar de los hogares correspondientes al aglomerado Gran Resistencia que componen la muestra es " as result r(mean)

decode aglomerado, generate(aglomerado_str)
summarize itf [w=pondera] if (aglomerado_str=="Gran Resistencia")
display as text "El monto promedio de ingreso total familiar de los hogares correspondientes al aglomerado Gran Resistencia que componen la muestra es " as result r(mean)


*##############################################################################*
								* EJERCICIO 2 *
*##############################################################################*


use "Hogar_t403_1", clear

mkmat IX_Tot itf ipcf if _n<=600, matrix(X)
matrix list X

*INCISO (a)*

matrix define Xt=X'
matrix list Xt

matrix define XtX=Xt*X
matrix list XtX

matrix define XXt=X*X'
matrix list XXt

matrix define XtXinv=inv(XtX)
mat list XtXinv

*INCISO (b)*

matrix define B=[1,2,3\4,5,6\7,8,9]
matrix list B

matrix define LHS=(XtX+B)'
matrix list LHS

matrix define RHS=(XtX)'+B'
matrix list RHS

matrix define dif=LHS-RHS
matrix list dif

*INCISO (c)*

matrix define tr=trace(XtX)
matrix list tr
display as text "La traza de la matriz X´X es " as result tr[1,1]

matrix define det=det(XtX)
matrix list det
display as text "El determinante de la matriz X´X es " as result det[1,1]

*INCISO (d)*

scalar phi=1/1000
matrix define phi_XtX=phi*XtX

matrix define LHS=det(phi_XtX)
matrix list LHS

matrix define RHS=phi^(colsof(X))*det 
matrix list RHS

matrix dif=LHS-RHS
matrix list dif


*##############################################################################*
								* EJERCICIO 3 *
*##############################################################################*


*INCISO (a)*

matrix define A=(23,21,34\65,67,32\13,12,32)
matrix list A

matrix define B=(23,2\22,15\3,7)
matrix list B

matrix define C=(1,3\2,13)
matrix list C

matrix define D=(34,25,2\3,14,32)
matrix list D

matrix define LHS=inv(A+B*C*D)
matrix list LHS

matrix define RHS=inv(A)-inv(A)*B*inv(D*inv(A)*B+inv(C))*D*inv(A)
matrix list RHS

matrix define dif=LHS-RHS
matrix list dif

*INCISO (b)*

matrix define A11=A[1..2,1..2] 
matrix list A11

matrix define LHS=inv(A11+C)
matrix list LHS

matrix define RHS=inv(C)*inv(inv(A11)+inv(C))*inv(A11)
matrix list RHS

matrix define dif=LHS-RHS
matrix list dif


*##############################################################################*
								* EJERCICIO 4 *
*##############################################################################*


matrix define B=(1,1,2,3,2,5,5,2\1,2,1,2,1,3,3,6\1,2,3,2,3,1,5,10\2,4,4,57,5,7,9,1\2,5,5,5,5,4,4,2\3,6,5,5,5,6,5,6\1,7,4,5,6,7,7,8\3,8,5,6,3,1,1,8)
matrix list B

*Determinante de la matriz B*

matrix define B11=B[1..4,1..4]
matrix list B11
matrix define B12=B[1..4,5..8]
matrix list B12
matrix define B21=B[5..8,1..4]
matrix list B21
matrix define B22=B[5..8,5..8]
matrix list B22  

matrix define detBp=det(B22)*det(B11-B12*inv(B22)*B21)
matrix list detBp
matrix define detB=det(B)
matrix list detB
matrix define dif=detBp-detB
matrix list dif

*Inversa de la matriz B*

matrix define B11inv=inv(B11-B12*inv(B22)*B21)
matrix list B11inv
matrix define B12inv=-inv(B11-B12*inv(B22)*B21)*B12*inv(B22)
matrix list B12inv
matrix define B21inv=-inv(B22)*B21*inv(B11-B12*inv(B22)*B21)
matrix list B21inv
matrix define B22inv=inv(B22)+inv(B22)*B21*inv(B11-B12*inv(B22)*B21)*B12*inv(B22)
matrix list B22inv

matrix define Bpinv=(B11inv,B12inv\B21inv,B22inv)
matrix list Bpinv
matrix define Binv=inv(B)
matrix list Binv
matrix define dif=Bpinv-Binv
matrix list dif