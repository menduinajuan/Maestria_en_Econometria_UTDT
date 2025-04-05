# --------  Pipeline Regresión logística y regularización (glmnet)  -----------#
rm(list=ls()); dev.off()
require(glmnet) || install.packages('glmnet'); 
library(glmnet) # Modelos lineales (generalizados) y regularización Ridge, Lasso y ENets.

setwd('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 3, 4 y 5/Datos')
datos = read.table('winequality-white.csv',sep=';',header=T,dec='.',na.strings = "")

##### Preproceso de datos ######################################################
#1) Modelo sensible a datos atípicos (identifica estos datos antes de comenzar a modelar).
summary(datos$density)     # Yo te muestro como hacer este análisis con una sola variable (queda a cargo tuyo hacer este trabajo con cada feature)

x11(); par(mfrow = c(1,2))
boxplot(datos$density)
plot(datos$density,datos$quality, pch = 20 ) 

#id.out = which(datos$density> 1)  # Deberías quitar estas instancias (filas/observaciones) del data set. 
#id.out                            # o eventualmente darles 'menos pesos' al aprender los parámetros. 


#3) IMPORTANTE: glmnet solo adminte datos en formato matriz (y no data frames) 
#               por tanto para trabajar con factores (por ejemplo el feature 'brand') debes 
#               codificarlos adecuadamente (hacer one-hot con cada feature categorico).
#Ref: https://web.stanford.edu/~hastie/glmnet/glmnet_alpha.html#lin
modmat <- model.matrix( ~ .-1, datos);  # <- R hace esto por vos en una sóla linea de código!
head(modmat,2) # (ver últimas 3 columnas, que se corresponden con la covariable 'brand'). 
is.matrix(modmat); dim(modmat) 

# 4) Separamos en Train (selección y estimación de modelo) y test (estimo ECM del modelo seleccionado)
set.seed(1)
id.train <- sample(dim(datos)[1], 3500) ############################## Fin preproc.

######################################################################################
#### RIDGE (alpha = 0)             ###################################################
######################################################################################
grid.l = seq(exp(-3),exp(3), length.out = 100)
set.seed(1) # La librería glmnet implementa VC internamente.
cv.out = cv.glmnet(x = modmat[id.train,-11], # Datos de train (sin la columna 'quality')
                   y = modmat[id.train,11],  # Columna 'quality' en datos de train 
                   lambda = grid.l, # Definimos más arriba.
                   alpha = 0,       # Ridge. 
                   nfolds = 5)      # Número de folds (los crea R con los datos de train)
cv.out

dev.off(); x11()           
plot(cv.out)        # No regularizar!

cv.out$lambda.min # lambda* (Primera linea vertical desde la izquierda. <- Modelo con menor ECM (estimado por VC))
cv.out$lambda.1se # Segunda linea vertical desde la izquierda. <- Modelo más parsimónico con un ECM (estimado por VC) a menos de 1sd del modelo anterior 



bestlam = cv.out$lambda.min # cv.out$lambda.min
bestlam

ridge.reg = glmnet(x = modmat[id.train,-11] , 
                         y = modmat[id.train, 11], 
                         family = 'gaussian',  
                         alpha = 0 , 
                         lambda = bestlam)


pred.ridge.best <- predict(ridge.reg, s = bestlam , newx = modmat[-id.train,-11])
ecm.ridge = sum( (pred.ridge.best - modmat[-id.train,11])^2 )/1398 
ecm.ridge # Sobre la muestra TEST (muy parecido a mco ya que no hay regularización).

######################################################################################
#### LASSO (alpha = 1)             ###################################################
######################################################################################

######################################################################################
#### ENETS (alpha in (0,1)          ###################################################
######################################################################################
# Aquí tendrás que aprender también el valor de alpha por VC.
alpha = seq(0,1, by =0.1)
alpha

resultados = cbind(alpha, lambda.star=rep(NA,11), ecm.valid=rep(NA,11))
head(resultados,3) # EN esta matriz coloco los resultados del ejercicio.

# separamos datos de train en train y valid:
set.seed(1)
id.tain.valid = sample(3500,2500)
train2  = id.train[ id.tain.valid]
valid2  = id.train[-id.tain.valid]

for(i in 1:length(alpha)){

  cv.enet = cv.glmnet(x = modmat[train2,-11], y = modmat[train2,11], lambda = grid.l,
                     alpha = alpha[i], # Considero distintos valores de "alpha"  
                     nfolds = 5)
  
  bestlam = cv.enet$lambda.min # cv.out$lambda.min
  resultados[i,2] <- bestlam
  
  enet.reg = glmnet(x = modmat[train2,-11] , 
                     y = modmat[train2, 11], 
                     family = 'gaussian',  
                     alpha = alpha[i] , 
                     lambda = bestlam)
  
  
  pred.enet.best <- predict(enet.reg, s = bestlam , newx = modmat[valid2,-11])
  
  resultados[i,3] = sum( (pred.enet.best - modmat[valid2,11])^2 )/1000 # ECM estimado sobre validación
print(i)
}

resultados # No parece tener mucho sentido hacer regularización (pocos features)

which(resultados[,3]==min(resultados[,3]))
resultados[3,]

enet.reg = glmnet(x = modmat[id.train,-11] , 
                  y = modmat[id.train, 11], 
                  family = 'gaussian',  
                  alpha = 0.2209249 , 
                  lambda = 0.04978707)


pred.enet.best <- predict(enet.reg, s = bestlam , newx = modmat[-id.train,-11])

sum( (pred.enet.best - modmat[-id.train,11])^2 )/1398 
# Muy parecido a Ridge.
#-------------------------------------------------------------------------- END.