rm(list=ls()); dev.off()
# ------------- Pipeline: Métodos "automáticos" de selección de Modelos -------------#
setwd('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 3, 4 y 5/Datos')
datos = read.table('winequality-white.csv',sep=';',
                   header=T,dec='.',na.strings = "")
set.seed(1)
id.train <- sample(4898, 3000)
#@Para concentrarnos en las técnicas de selección, no usamos modelos aditivos.

##### 1) Selección manual de modelos (VIF) #####################################
require(car) || install.packages('car'); library(car)

reg.lin = lm(quality ~ ., data = datos, subset = id.train)
vf = vif(reg.lin)  # El coeficiente VIF (slide 26) te dice cuanto de redudante es cada feature (Mientras más grande el VIF, más redundante es el feature)
print(vf)  # Siguiendo la regla habitual descartamos: density, residual.sugar, alcohol.

reg.lin.vif = lm(quality ~ fixed.acidity + volatile.acidity + citric.acid + 
                   chlorides+ free.sulfur.dioxide+total.sulfur.dioxide+
                   pH+sulphates,data = datos,   subset = id.train)

pred <- predict(reg.lin.vif, newdata = datos[-id.train,-12])
sum( (pred - datos[-id.train,12])^2 )/ 1898 # 0.670 Benchmark 


##### 2) Selección automática de modelos  #####################################
require(leaps) || install.packages('leaps'); library(leaps)

# Necesitamos separar train en 2: Train + validación. 
# Con train construímos la secuencia {M_0,M_1,...,M_11} 
# y con validación seleccionamos el mejor modelo dentro de esta secuencia.

set.seed(1)
id.train2 = sample(id.train, size = 2000 ) # sub-sampling dentro de id.train.
id.val    = id.train[which(!(id.train%in%id.train2)==T)] # which(!(id.train%in%id.train2)==T) indica que elementos de id.train no están en id.train2

# 2.1) Exhaustivo (factible si p es relativamente pequeño, aquí p = 11)
regfit.full = regsubsets(quality ~ . ,
                         data = datos[id.train2,], # Uso solo id.train2!
                         method = 'exhaustive',    # Método de exploración de modelos.
                         force.in=NULL,            # Si quiero forzar a que una covariable aparezca.
                         force.out=NULL,           # Si quiero forzar a que una covariable NO aparezca.
                         intercept=TRUE,           # flag para el intercepto (TRUE por defecto).
                         nvmax = 11,               # Cantidad máxima de covariables a considerar en el modelo (utilizar cuando p >> 30)
                         nbest = 1)                # Cuantos modelos guardar para cada modelo en la secuencia {M_0,...,M_11}.

summary(regfit.full) # Lo que llamamos {M_0,...,M_11} en algoritmo de slide 28.


# Si tenés pocos datos (ver slide 43) podés elegir el mejor modelo con:
cbind(p = 1:11,
      summary(regfit.full)$adjr2,      # R cuadrados ajustados (computados con los datos de train2).
      summary(regfit.full)$cp,         # Para cada mejor modelo su Mallows.
      summary(regfit.full)$bic)        # Para cada mejor modelo su BIC.
      

which( summary(regfit.full)$adjr2 == max(summary(regfit.full)$adjr2) )
coef(regfit.full,8)              # Parámetros asociados al mejor modelo (criterio in-sample R2-ajustado).
summary(regfit.full)$adjr2[8]    # Valor del R2-aj de dicho modelo.

x11()
plot(1:11, summary(regfit.full)$adjr2,xlab="# variables",
     ylab="R2 ajustadp",type="b",pch=20)
points(8 , summary(regfit.full)$adjr2[8] , col =" red " , cex =2 , pch =20)

################################################################################
### Seleccionando de {M_1,...,M_11} con conjunto de validación:                #
################################################################################
ecm.val = c() # Acá guardo los ecm sobre validación.

X.val = model.matrix(quality ~., data = datos[id.val,])  # X en validación.
y.val = datos[id.val,12]                                 # y en validación.

# Analizar el output de: coef(regfit.full, id=2)
for(i in 1:11){
  coefi=coef(regfit.full, id=i)         # recupero parámetros estimados de cada modelo en {M_1,M_2,...}
  y.hat = X.val[, names(coefi)]%*%coefi # y.hat = X%*%hat.beta (predicciones sobre el conjunto de validación para {M_1,M_2,...}) 
  ecm.val[i] = sum( (y.hat - y.val)^2 )/ 1000  # Calculo el rss sobre validación.
}

x11()
plot(1:11,ecm.val, type ='b', ylab = 'ECM sobre validación', xlab='Cantidad de features en el modelo')

cbind(p = 1:11, ecm.val)
which(ecm.val == min(ecm.val))

coef(regfit.full, id=3) # Mejor modelo (features y sus respectivos parámetros) sobre la muestra de validación.


# Reestimamos el modelo con todos los datos de train+validación:
reg.lin.ex = lm(quality ~ volatile.acidity+residual.sugar+alcohol,  
                data = datos, subset = id.train) 
summary(reg.lin.ex) #plot(reg.lin.ex)

pred.test = predict(reg.lin.ex,newdata = datos[-id.train,-12])
sum( (datos[-id.train,12] - pred.test)^2 ) / 1898
# 0.573 vs 0.670 (benchmark VIF). Un 15% mas bajo que con VIF.

# Si en vez de utilizar "validation set approach" querés implementar K-fold CV 
# podés referirte al ejemplo en: @ISL-V2 pp~270 (ver código en R con ejemplo).

# 2.2) Forward & Backward     
# Forward: Usamos este método en particular cuando "p > n" y necesitamos 
# eliminar variables para poder fitear un modelo de regresión.
regfit.fwd = regsubsets(quality ~ . ,       
                        data = datos[id.train2,], 
                        method = 'forward',      # Simplemente le aviso a R que voy a hacer 'Forward' (slide 29)
                        nvmax = 11, nbest = 1)       
summary(regfit.fwd)  # Secuencia {M_1,...,M_11}. 

# El mecanismo de selección del mejor modelo en  {M_0,...,M_11} 
# es el mismo que con exhaustivo (replicar corre por tu cuenta).

# Backward:
regfit.bkw = regsubsets(quality ~ . ,    
                        data = datos[id.train,], 
                        method = 'backward',    # Simplemente le aviso a R que voy a hacer 'Backward' (slide 29)
                        nvmax = 11, nbest = 1)

summary(regfit.bkw)  # Secuencia {M_1,...,M_11}.

# El mecanismo de selección del mejor modelo en  {M_1,...,M_11} 
# es el mismo que con exhaustivo (replicar corre por tu cuenta).

# ------------------------------------------------------------------------- END.
#### Comentario final:                                                        ##
####    - Puedes utilizar este método en combinación con modelos aditivos.    ## <- ver slide 33
####       Con el comando bs() o poly() creas los features de tu modelo aditivo#
####       (agregas las respectivas columnas a tu data set), y regsubset se    #
####       encarga de quitar los features que resultan poco útilies.           #
####    - Con "p" MUY grande correr forward y backward y comparar resultados. ##
################################################################################