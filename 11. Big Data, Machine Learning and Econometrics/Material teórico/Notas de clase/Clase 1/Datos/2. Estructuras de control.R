#-----------------------------------------------------------------------------#
#-------  Estructuras de control y Funciones                       -----------#
#-----------------------------------------------------------------------------#
### Muy importante.
##  Importante.
#   Poco importante.


### Loop "for": # Super utilizado en el curso!!!!!
for(i in 1:5){ print(i) }

for(i in 1:2){ 
  for(j in 1:3){ # Un loop for adentro de otro for
    print(i+j) }
              }

# Ejemplo 1: TCL
realiz.med.muestral = c()
for(i in 1:1000){
  datos                  = rexp(20, rate = 0.1) # E(X) = 10
  realiz.med.muestral[i] = mean(datos) 
}

hist(realiz.med.muestral, main='TCL')

# Ejemplo 2: Crear un vector con Fib = \{1,1,2,3,5,8...\}        ##
Fibonacci = c() # Creamos un vector 'vacío' de dimensión arbitraria.         ##
Fibonacci[1] = 1; # Asignamos al primer elemento del vector el valor 1.      ##
Fibonacci[2] = 1; # Asignamos al segundo elemento del vector el valor 1.     ##
for(i in 3:48){Fibonacci[i]= Fibonacci[i-1]+Fibonacci[i-2]}                  ##
# Para i desde 3 hasta 48, el elemento que ocupa la posición i es igual      ##
# a  la suma de los DOS elementos inmediatamente anteriores en dicho vector. ##
print(Fibonacci)                                                             ##
###############################################################################

#@ En ML vamos a utilizar con relativa frecuencia este loop
#@ para recorrer vectores con (hiper)parámetros para "estimar"
#@ el error predictivo de un modelo asociado a cada uno de esos valores.



###############################################################################
# EJERCICIO EN CLASE: lee el fichero de datos en R datos.RData               ##
setwd('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 1/Datos')##
load('datos.RData')                                                          ##
dim(datos)                                                                   ##
                                                                             ##
                                                                             ##
pairs(datos)                                                                 ##
                                                                             ##
reg = lm(datos[,1] ~ datos[,2], data = datos)                                ##
summary(reg)                                                                 ##    
                                                                             ##
reg$coefficients # ¿que información extraemos del modelo?                    ##
# Ejercicio: Utiliza el bucle for para que R se encargue de correr           ##
# regresiones lineales simples, y guardá en un vector las pendientes de cada ## 
# modelo. ¿Qué modelo tiene mayor pendiente? (utiliza el comando which())   ##     

pendientes <- numeric(ncol(datos) - 1)

for (i in 2:ncol(datos)) {
  model <- lm(datos[, 1] ~ datos[, i], data = datos)
  pendientes[i - 1] <- model$coefficients[2]
}

print(pendientes)

indice_max_pendiente <- which.max(pendientes)
modelo_max_pendiente <- colnames(datos)[indice_max_pendiente + 1]
cat("El modelo con mayor pendiente es el correspondiente a la variable:", modelo_max_pendiente)

###############################################################################

# Loop "while":
i = 1
while(i<=5){print(i); 
            i = i+1}


### Condicional "if{} else {}"
p = 3; q = 2
if(p<q){ print('p es menor que q')} else {print('p es mayor o igual que q')}

# En algunos casos, puede resultar de utilidad combinar ciclos con condicionales:
for(i in 1:10){
  if(i<5){print("i es menor que 5")} else if(i==5){ print("i es = 5") 
  } else {print("i es mayor que 5")}
  
}

## Condicional ifelse (sobre vectores o matrices)
x = c(-1,2,8,21,-2,11,9,-1,7)
print(x)
x = ifelse (x < 0 | x > 10,0,x) 
print(x)

M = matrix(c(-1,2,8,21,-2,11,9,-1,7),ncol=3)
print(M)
ifelse (M < 0 | M > 10,0,M) 
##----------------------------- END: Estructuras de control.



### ------ Creando mis propias funciones en R:

mifuncion = function(x){
  return(x^2 - 3*x + 1)
}

mifuncion

mifuncion(1); 
mifuncion(x=c(1:4)) # La puedo evaluar en un conjunto de argumentos.
plot(mifuncion, from=-1, to =5)

mifuncion2 = function(x,a,b,c){
  return(a*x^2 - b*x + c)
}

x = seq(-1,5, by = 0.5)
points(x,mifuncion2(x,a=0.5,b=1,c=2), type='l', col = 'red')
########### END.


#############################################################
##############    Miscelanea                  ###############
#############################################################

### Missing data:
datos = data.frame(x1 = c(1:5), x2 = c(5:3,NA,1))

datos
which(is.na(datos)==T, arr.ind = T)

datos2 = na.omit(datos) 
datos2


### Transformando data.frames en matrices:
class(datos2)

datos2 = as.matrix(datos2)
class(datos2)

## bucle for 'anidado'
#@ En algún momento podríamos llegar a necesitar utilizar un for adentro de 
#@ otro for (cuando cross--validemos más de un parámetro). Veamos un ejemplo:
M = matrix(0,ncol=3,nrow=3)
for(i in 1:3){
  for(j in 1:3){  M[i,j]= i+j }    }
print(M)


### Grillas:
#@ Para evitar tener que utilizar dos (o más) 'for', en algunas ocasiones
#@ podemos crear 'grillas' con valores para ciertos parámetros sensibles.
param1 = c(1,2,3)
param2 = c(9,8)

grilla = expand.grid(param1, param2)

grilla
#-------------------------------------------------------------------------- END.


### En caso de tener un poco de tiempo:  
# (1) Separa los datos de demanda de bicicletas de forma aleatoria en dos partes (TRAIN y VALIDACIÓN)

# (2) Con los datos de TRAIN fitea un modelo de regresión lineal para predecir la variable
#     cnt (cantidad de bicicletas públicas demandadas) en función de 'temp', 'hum', 'windspeed' y la variable dummy 'holiday'      
#     Analiza los parámetros estimados del modelo.

# (3) Utiliza el comando predict() para computar las predicciones del modelo lineal sobre los datos
#     del conjunto de VALIDACION y estima el ECM de tu modelo con los datos de este conjunto.