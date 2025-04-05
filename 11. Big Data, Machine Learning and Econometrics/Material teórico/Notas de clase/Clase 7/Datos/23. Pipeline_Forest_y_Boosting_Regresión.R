rm(list = ls()); dev.off()
# --- Pipeline para implementar R.Forest y Boosting en R ----------------------#
require(randomForest) || install.packages('randomForest');library(randomForest)#
library(randomForest)

#@ 1: Leyendo datos y poniendo contexto al problema.
### Datos de precio de vivienda en california (predicción precio de viviendas):
#setwd('...')
# load('calif.RData') # <- Leer los datos directamente desde tu compu si la línea 11 toma demasiado tiempo.

calif = read.table("http://www.stat.cmu.edu/~cshalizi/350/hw/06/cadata.dat", header=TRUE)

str(calif) # dim(calif) # 20640 instancias, 9 variables:
#$ MedianHouseValue: num  valor medio de las casas en la zona.   <--- Target "Y" ('numeric' en la memoria de R)
#$ MedianIncome    : num  ingreso medio de los hab. de la zona.
#$ MedianHouseAge  : num  valor medio de la edad promedio de las contr. en la zona.
#$ TotalRooms      : num  Numero total de cuartos.
#$ TotalBedrooms   : num  Numero total de baños.
#$ Population      : num  Poblacion en la zona.
#$ Households      : num  Nro de vecinos en la comunidad. 
#$ Latitude        : num  Coordenada Latitud.
#$ Longitude       : num  Coordenada Longitud.

#@ 2: Preprocesamiento de datos y análisis descriptivo mínimo.
set.seed(1)      
id.train=sample(20640,10000)

### Precios meadino en funcion de las coord. de latitud-longitud
x11()
price.deciles = quantile(calif$MedianHouseValue,0:10/10)
cut.prices = cut(calif$MedianHouseValue,price.deciles,include.lowest=TRUE)
plot(calif$Longitude,calif$Latitude,col=grey(10:2/11)[cut.prices],pch=20,
     xlab="Longitud",ylab="Latitud",main='Precios de la vivienda en California')
### Claramente el precio no es una función "lineal" de los features latitud-longitud.


#@ 3: Fitting de un primer modelo Forest de 'Benchmark'
?randomForest
forest.bench = randomForest(log(MedianHouseValue)~., 
                          data=calif[id.train, ], 
                          mtry=round(ncol(calif)/3), # (Slide 29) *** Si "mtry = cantidad de features dispoibles" entonces RF es en realidad Bagging***
                          nodesize = 5,              # (Slide 29)
                          ntree=500,    # B 
                          importance=T) # (Slide 20)
forest.bench 

# Análisis de la importancia de cada feature:
x11()
barplot(sort(forest.bench$importance[,1], decreasing = TRUE),
        main = "Contribución % a la reducción del MSE", col = "lightblue",
        horiz = TRUE, las = 1, cex.names = .6, xlim = c(0, .25))
#forest.bench$importance # <- Ver slide 20 para entender los detalles de como se computa esta cantidad.

x11();# Prediciones vs valores observados (TRAIN, estimaciones OOB):
plot(log(calif$MedianHouseValue[id.train]),forest.bench$predicted,xlab="Y",
     ylab=expression(hat(Y)),main="Pred vs. Observados",pch='.')
abline(0,1,lwd=2,col=2) # El modelo parece bastante bueno!

# OPTIMIZACIÓN DE HIPERPARÁMETROS: 
seq(1,100, by = 5)
valores.m = c(2,3,4,6,8)       # <- Posibles valores para "m".
valores.maxnode = c(5,10,15,20,30) # <- Posibles valores para el parámetro de complejidad del modelo.
matriz.resultados = expand.grid(m = valores.m, maxnode = valores.maxnode, ecm.oob = 0)
head(matriz.resultados, 2) # <- De aquí voy a tomar los hiperparámetros y a colocar el ecm estimado por oob.

for(i in 1:dim(matriz.resultados)[1] ){ # Equivale a VC (más facil de implementar)
  optim.forest = randomForest(log(MedianHouseValue)~.,
                              data=calif[id.train, ], 
                              ntree=500,                         # En la práctica utiliza un valor de B >> 0. 
                              mtry = matriz.resultados[i,1],     # <- Posibles valores de 'm'
                              maxnodes = matriz.resultados[i,2]) # <- Posibles valores de 'complexity parameter'
  matriz.resultados[i,3] <-  sum( (log(calif$MedianHouseValue[id.train]) - optim.forest$predicted)^2 ) / 10640 # m?trica es el ECM estimado por OOB
  print(i)
} 

### Resultados:
matriz.resultados # m* = 6 y complexity* = 30

set.seed(1)
forest.best = randomForest(log(MedianHouseValue)~.,
                          data=calif[id.train, ], 
                          mtry=6,        # m* 
                          maxnodes = 30, # complexity* 
                          ntree=500)     

pred.for.test = predict(forest.best,newdata=calif[-id.train, ]) # Predicciones test.
MSE.for = sum((pred.for.test - log(calif$MedianHouseValue[-id.train]))^2)/10000
MSE.for   #### 0.1148 (benchmark para contrastar contra 'gbm').
## -------------------------------------Fin RF.

################################################################################
require(gbm) || install.packages('gbm') ; library(gbm)        ##################
################################################################################
set.seed(1)
bos.gbm = gbm(log(MedianHouseValue)~.,
              data=calif[id.train, ], 
              distribution="gaussian",  # Regresión (Y continua). En clasificación: distribution="bernulli"
              n.trees=5000,             # Tamaño de la secuencia (M en slide 44)
              shrinkage=.1,             # Parámetro lambda en slide 44.
              train.fraction=0.8,       # Parámetro 'delta' en slide 44.
              bag.fraction=0.7,         # Parámetro 'eta' en slide 44.
              interaction.depth=3,      # Parámetro de complejidad de cada modelo en la secuencia (utilizar modelos simples)
              cv.folds=5,               # Si cv.folds > 0 estima también por VC (train frac) el error del modelo (puede ponerse bastante lento el entrenamiento)  
              keep.data=T,
              verbose=T)

x11() # Análisis del ensamblaje vía Boosting
gbm.perf(bos.gbm,method="cv")
title(main="ECM estimado por VC, en Validación y en Training")
legend(500,0.3,c("Error 5CV","Error Validación","Error en Train"),
       col=c('green','red','black'),pch='-') # Hay que truncar el ensamble para evitar overfitting!


M.star = gbm.perf(bos.gbm,method="cv"); 
M.star # Truncamos el ensamble.

summary(bos.gbm,n.trees=M.star) # <- Importancia de cada variable respecto del modelo seleccionado.

m.prec.gmb = predict(bos.gbm,n.trees=M.star)
x11()
plot(log(calif$MedianHouseValue[id.train]),m.prec.gmb,xlab="Y",
     ylab=expression(hat(Y)),main="Predicciones vs. Valores observados",pch='.')
abline(0,1,lwd=2,col=2)

### Resultados sobre test:
pred.gbm.test=predict(bos.gbm,newdata=calif[-id.train,],n.trees=M.star)
MSE.gbm = sum((pred.gbm.test - log(calif$MedianHouseValue[-id.train]))^2)/10000
MSE.gbm    # 0.058 vs 0.1148 (Random Forest).
###############################################################################