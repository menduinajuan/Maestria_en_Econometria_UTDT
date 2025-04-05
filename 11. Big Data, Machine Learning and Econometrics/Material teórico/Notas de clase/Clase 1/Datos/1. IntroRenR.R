#-----------------------------------------------------------------------------#
#-------           Creando y Manipulando Datos                          ------#     
#-----------------------------------------------------------------------------#
### Muy importante.
##  Importante.
#   Poco importante.


#--- 1) Manipulando Vectores, Matrices y DataFrames ----#

### Creando vectores
vector = c(1,3,5,7,9,11)
vector

length(vector) # Dimensión del vector.

sum(vector)
max(vector)
min(vector)

## Operando 'punto a punto' con vectores
2*vector + 1

vector^2
log(vector)
exp(vector)

dias = c('lunes', 'martes', 'miercoles', 'jueves', 'viernes')
dias

2*dias + 1 # Que va a ocurrir?


## Algunas funciones útiles:
rep('R',3)        # Repetir elemento una cantidad arbitraria de veces.
seq(0,1, by=0.1)  # Generar secuencias de longitud arbitraria.

### Acceder a los elementos de un vector '[]'
vector
vector[3]
vector[-3]

# Operaciones del álgebra lineal con R
x = c(1,1,1); y = c(2,2,2) 

t(x)%*%y #x'y = número

x%*%t(y) #xy' = matriz

sqrt(t(x)%*%x) # Norma de x.


### Buscando "elementos" adentro de un vector:
set.seed(1)
z = runif(10) # Genero 10 números "aleatorios" en el intervalo [0,1] 
z

which(z>0.1 & z<=0.3)    # Posiciones de los elementos de z que son están en (0.1,0.3).
z[which(z>0.1 & z<=0.3)] # Elementos del vector z que cumplen la condición anterior.


which( (z>0.1 & z<=0.3) | (z>0.9) ) # Puedo combinar condiconales como quiera.


which(z == max(z)) # print(z)

which(z == min(z)) # print(z)

# Concatenando vectores:
x = 1:3
y = 9:11
z = c(y,x,-1)
print(z) # Primero y, después x y luego un '-1'.

### Estructuras matriciales en R
print(vector)

matriz = matrix(vector,ncol=2, nrow = 3)
matriz

matriz = matrix(vector,ncol=2, byrow = TRUE )
matriz


### Dimensiones de una matriz
dim(matriz)

# Operaciones 'punto a punto' con los elementos de una matriz
2*matriz + 1

A = matrix(1:9,ncol=3)
A

A + 1

2*A

log(A) #idem para exp(A), sin(A), etc etc etc
A
A*c(1,0,1)


# Operaciones del álgebra matricial en R

A%*%c(1,0,1) # vector

B = matrix(1:9,ncol=3, byrow = T)
B

A*B # operación punto a punto

A%*%B # AB

C = matrix(runif(9),ncol=3, byrow = T)
C
solve(C) # C^{-1}

# Concatenando matrices
rbind(A,B) # 6x3

cbind(A,B) # 3x6

# Darle nombres (renombrar) las columnas y/o las filas:
colnames(A) <- c('y','x1','x2')
rownames(A) <- c('id1','id2','id3')
print(A)


### Acceder a los elementos de una matriz '[filas,columnas]'
print(A)
A[1,2]     # el elemento de la posición 1,1.
A[1:2,2:3] # los elementos de las posición 1 a 2, 2 a 3.

print(A)
which(A==5 | A>7, arr.ind = T) # | = 'o' en cambio & = 'y'

## Aplicar funciones sobre filas o columnas ('apply'):
print(A)
apply(A,1,sum) # Devuelve la suma por filas de A

apply(A,2,min) # Devuelve los mínimos por columnas de A

### Data frames (formato habitual de los datos que levantamos con R)
datos = read.table('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 1/Datos/bikes.csv',
                   sep=',', header=T, dec='.', na.strings = "NA")


class(datos)

str(datos) # Las columnas de esta matriz pueden contener variables de distinto tipo.

head(datos,2) # Visualizar las primeras filas del data set.


datos$cnt # accedo a la columna cuyo nombre es "cnt"

attach(datos) # attach de los nombres de las variables en memoria.
cnt # como hice un attach de datos, al llamar a "cnt" R entiende datos$cnt      

summary(datos) # Algunas estadísticas básicas de lo que hay en cada columna.

table(weathersit, holiday) # Tabla de frecuencias para variables categóricas.

table(holiday, cut(cnt,breaks=c(1000,2500,5000,10000),dig.lab = 4)) # Tabla de frecuencias para variables mixtas.
# Fin: vectores, matrices y data frames.

#----- 2) Estadística descriptiva + simulaciones + herramientas gráficas básicas ----#

### Sampleando de modelos estadísticos concretos
rm(list = ls()) # Borramos todo lo que R tenga en memoria
set.seed(1)
runif(1) # help(runif) o ?runif  <- Ayuda para comprender mejor el comando y sus argumentos.

rnorm(5,mean=0,sd=1)
rexp(5, rate = 2)
rpois(5, lambda = 3)
rbeta(5, shape1 = 1, shape2=2)

## Análisis estadístico descriptivo:
# set.seed(1)
x = rnorm(100,mean=0,sd=1)
head(x, 3)                # Observamos primeras filas de un vector / matriz.

mean(x)
var(x)
quantile(x, c(0.1,0.5,0.75))

summary(x)
hist(x)


hist(x, main='Histograma', 
     xlab = 'Mis datos', 
     ylab = 'Frecuencia Relativa',
     col = 'blue',
     probability = TRUE,
     breaks = c(-6,-4,-3,-2,-1,0,1,2,3,4,6))

boxplot(x, col='red', xlab='eje-X', ylab = 'eje-Y')

### Exportar gráficas fuera de R:
#png('exportandomigrafico.png', width = 800, height = 450)
par(mfrow=c(1,2)) # juntar gráficas en una misma ventana:
hist(x) 
boxplot(x)
# dev.off() # Reseteamos la ventana gráfica activa. 


### Scatterplot matrix (análisis gráfico conjunto de varias variables numéricas)
datos = read.table("G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 1/Datos/bikes.csv",
                   sep=',', header=T, dec='.', na.strings = "NA")
pairs(datos[,c(11:13,16)], pch = 20, col = 'gray')
#---------------------------------------------------- END.

# Ejercicio en clase: Simula 100 realizaciones de: 
#         Y = -1 + 0.5X + eps,  
# donde X ~ U(3,5) y eps ~ N(0,1). Grafica los datos con el comando 'plot(X,Y)'

rm(list = ls())
set.seed(1)
n <- 100
X <- runif(n, min = 3, max = 5)
eps <- rnorm(n, mean = 0, sd = 1)
Y <- -1 + 0.5 * X + eps
plot(X, Y, main = "Gráfico de Y vs X", xlab = "X", ylab = "Y", pch = 19, col = "blue")

# Regresión lineal: Con los datos simulados, estima el modelo propuesto en la linea 214.

mod.lin = lm(Y~X)
summary(mod.lin)
mod.lin$residuals
mod.lin$coefficients
attributes(mod.lin)

#------- Miscelanea -------------------------------------------------------#
###   Descargar y leer paquetes

# Paquetes de R: https://cran.r-project.org/web/packages/available_packages_by_name.html
install.packages('psych') # Instalamos el paquete desde la consola (1 vez)
library(psych)
# Una versión refinada de 'pairs' con temperatura, humedad, windspeed y cnt.
dev.off()
datos = read.table("G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 1/Datos/bikes.csv",
                   sep=',', header=T, dec='.', na.strings = "NA")
pairs.panels(datos[,c(11:13,16)], cex = 3,  # variables a analizar: atemp hum windspeed cnt
             method = "pearson",    # Método para computar la correlación
             hist.col = "#00AFBB",
             smooth = TRUE, # Fitea un modelo no paramétrico de regresión entre pares de var
             density = TRUE,  # Estima densidades para cada una de las variables
             ellipses = FALSE # Ilustra la correlación entre las variables utilizando elipses 
)
### END