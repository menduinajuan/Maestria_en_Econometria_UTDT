# ------------------ Dscriminantes lineal y cuadrático ------------------------#
rm(list = ls()); dev.off()

# https://archive.ics.uci.edu/ml/datasets/banknote+authentication#
setwd('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 3, 4 y 5/Datos')
banknotes = read.table('data_banknote_authentication.txt', 
                       header = F, sep=',')

colnames(banknotes) = c('varWa','skeWa','curWa','entro','y')
head(banknotes,3)
dim(banknotes)
# Data Set Information:Data were extracted from images that were taken from genuine 
# and forged banknote-like specimens. For digitization, an industrial camera usually 
# used for print inspection was used. The final images have 400x 400 pixels. Due to 
# the object lens and distance to the investigated object gray-scale pictures with a 
# resolution of about 660 dpi were gained. Wavelet Transform tool were used to extract 
# features from images.

#1. variance of Wavelet Transformed image (continuous) # Feature 1
#2. skewness of Wavelet Transformed image (continuous) # Feature 2
#3. curtosis of Wavelet Transformed image (continuous) # Feature 3
#4. entropy of image (continuous)                      # Feature 4
#5. class (integer)                                    # Variable de respuesta.

x11()
pairs(banknotes[,1:4], col = (banknotes[,5]+1), pch = 20)
# Ptos rojos corresponden a billetes falsos. 

require(scatterplot3d) || install.packages('scatterplot3d'); library(scatterplot3d)
# Datos aprox normales.
x11()
scatterplot3d(banknotes[,c(1,2,3)], pch = 20, color = (banknotes[,5]+1),lwd=0.01, box=FALSE)

table(banknotes[,5])  # Data set balanceado.
sum(is.na(banknotes)) # No hay faltantes (ni atípicos como se ve en el gráfico anterior).

#### TRAIN ids: (validación para seleccionar modelo LDA vs QDA)
set.seed(1) ; id.train = sample(1372,1000) 

#############################################################
##### Discriminante lineal                  #################
#############################################################
library(MASS)
linear.disc = lda(y ~ varWa + skeWa + curWa + entro,
                  data = banknotes,
                  subset = id.train, 
                  # prior = c(0.5,0.5), # Podés elegir estos (hiper)parámetros de manera ad-hoc o estimarlos de la muestra.
                  method = 'mve',       # Método robusto de aprendizaje de mu y sigma (otras opciones: mle, moment, t) 
                  CV = FALSE)           # Solo funciona con los métodos "mle" y "moment"

linear.disc
# Output: 1) Priors pi_0 y pi_1 (estimadas con train).
#         2) Medias: mu_0, mu_1
#         3) El vector de parámetros "w" (ver slide 28 en las diapos, aquí hay 4 parámetros)


# Predicciones (basadas en las funciones discriminantes)
linear.disc.pred = predict(linear.disc, newdata = banknotes[-id.train,1:4])

head(linear.disc.pred$posterior,3) # Probabilidad a posteriori estimada.

head(linear.disc.pred$class,3) # Estimación de la clase/categoría a la que pertenece cada billete.

head(linear.disc.pred$x,3) # Valor de la función discriminante


# Matriz de confusión: (test)
matriz.confusion = table(linear.disc.pred$class, banknotes[-id.train,5])
matriz.confusion 

sum(diag(matriz.confusion))/sum(matriz.confusion)*100
(1-sum(diag(matriz.confusion))/sum(matriz.confusion))*100
# 4.28% (tasa de error sobre conjunto de validación)

#############################################################
##### Discriminante Cuadrático              #################
#############################################################
cuad.disc = qda(y ~ varWa + skeWa + curWa + entro,
                  data = banknotes,
                  subset = id.train, 
                  # prior = c(0.5,0.5),
                  method = 'mve', # método robusto de estimación de mu y sigma (otras opciones: mle, moment, t) 
                  CV = FALSE) # Solo funciona con los métodos "mle" y "moment"

cuad.disc
# Output: Prior probabilities y medias.

cuad.disc.pred = predict(cuad.disc, newdata = banknotes[-id.train,1:4])

# Matriz de confusión: (test)
matriz.confusion = table(cuad.disc.pred$class, banknotes[-id.train,5])
matriz.confusion

sum(diag(matriz.confusion))/sum(matriz.confusion)*100

(1-sum(diag(matriz.confusion))/sum(matriz.confusion))*100
# 2.14% (me quedo con el discriminante cuadrático)
#-------------------------------------------------------------------------- End.

##### Apéndice:
# Extensiones: Con el paquete "klaR" se pueden implementar las versiones
# regularizadas de estos modelos. Incluso se pueden fitear múltiples modelos
# tomando co-variables de apares para poder "visualizar" el clasificador:
require(klaR) || install.packages('klaR'); library(klaR)
banknotes$y = as.factor(banknotes$y)
x11()
partimat(y ~ varWa + skeWa + curWa + entro,
         data = banknotes,
         subset = id.train,
         method="rda") # "R"egularized discriminant Analysis (penaliza la norma de las matrices de covarianza)
# Obviamente que cuando interactúan las 4 covariables al mismo tiempo,
# el modelo resuelve mejor (menor tasa de error) el problema de clasificación.
########################### Fin de modelos discriminantes (lineal y cuadrático).


##---- Discriminante lineal de Fisher (no asumimos normalidad) ------------#####
# install.packages('vcvComp')
library(vcvComp)
mu_0 <- colMeans(banknotes[id.train[banknotes[id.train,5]==0],1:4])
mu_1 <- colMeans(banknotes[id.train[banknotes[id.train,5]==1],1:4])

B=cov.B(banknotes[id.train,1:4], banknotes[id.train,5])
W=cov.W(banknotes[id.train,1:4], banknotes[id.train,5]) 
invW.B <- eigen(solve(W)%*% B)

round(invW.B$values,2)
eta.hat = Re(invW.B$vectors[,1]) # vector de proyección estimado (eta.hat)
eta.hat


Z = as.matrix(banknotes[,1:4]-0.5*matrix(rep(mu_0+mu_1,1373),ncol = 4, byrow=T))%*%eta.hat # Train y test

par(mfrow = c(2,1))
hist(Z[which(banknotes$y==1)], col = 'red',  xlab = 'Z', xlim = c(-5,8), main = 'Score Z en Falsos')
hist(Z[which(banknotes$y==0)], col = 'blue', xlab = 'Z', xlim = c(-5,8) , main = 'Score Z en Originales')

table(sign(-Z), banknotes$y)
# -------------------------------------------------------------------------- End.