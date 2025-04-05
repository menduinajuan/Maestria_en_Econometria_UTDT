rm(list=ls())
#------------------      Boosting Machines (Clasificación)   ------------#

##########################################################
require(xgboost) || install.packages('xgboost')     #####
##########################################################
library(xgboost)
setwd('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 7/Datos')
load('colisiones.Rdata')

dim(colisiones)

head(colisiones, 2)

table(colisiones$VAR_OBJETIVO) # columna 1: Y = 0 (sin colisión declarada último año, Y = 1, una o más colisiones)
table(colisiones$VAR_OBJETIVO)/dim(colisiones)[1]*100 

table(colisiones$FREC_COLISION_ANYO_0) # Quitar columna 19 del data set antes de empezar a modelar.
colisiones = colisiones[,-19]

###1] Ingeniería de atributos:
colisiones$pp = colisiones$POTENCIA /  colisiones$PESO
# .... (cada alumne debería continuar esta tarea por su cuenta).

set.seed(1)
id.train=sample(dim(colisiones)[1],round(dim(colisiones)[1]*0.5))

# xgboost trabaja con matrices de datos sparse.
xgb_train = xgb.DMatrix(data = data.matrix(colisiones[ id.train,-1]), label = data.matrix(colisiones[ id.train,1]))
xgb_test  = xgb.DMatrix(data = data.matrix(colisiones[-id.train,-1]), label = data.matrix(colisiones[-id.train,1]))

watchlist <- list(train=xgb_train, test=xgb_test)

set.seed(1) 
benchmark <- xgb.train(data = xgb_train,
                     watchlist=watchlist,        # Estimamos la devianza sobre train y test.
                     nrounds = 1000,             # Parámetro M
                     early_stopping_rounds = 50, # El algoritmo corta si después de 50 iteraciones no hay mejora sobre el conjunto de test.
                     print_every_n = 50,
                     param = list(
                       max.depth = 3,    # Complejidad de cada modelo.  
                       eta = 0.05,        # Lambda en slide 44.
                       subsample = 0.75), # eta en slides 44.
                     # Para más opciones explorar la ayuda de esta función.
                     nthread = 8,     # Número de núcleos. 
                     objective = "binary:logistic" # Función de pérdida (Deviance, ver apéndice en slides).
 )

benchmark # Hay que cross--validar los parámetros.

importance_matrix <- xgb.importance(model = benchmark)
head(importance_matrix, 3)

x11()
xgb.plot.importance(importance_matrix = importance_matrix)

pred <- predict(benchmark, newdata = xgb_test)
head(pred, 3) # utilizamos la función g(x)=e^x/(1+e^x) que transforma el output del ensamble en 'probabilidades'

y.test = ifelse(pred >0.3,1,0)
head(y.test, 3)

table(y.test, colisiones$VAR_OBJETIVO[-id.train])/171214*100
# Tasa de error del 35% (aprox).

# Queda pendiente: (1) Optimizar hiperparámetros y (2) Tunear correctamente "nu".

# Apéndice (sobre 1)
########################################################
#2: Selección de modelos con Boosting (xgboost):     ###
########################################################
param <- expand.grid(
              max_depth = c(2,4,6),
              eta = c(0.05, 0.1)
# Otros hyperparámetros: https://xgboost.readthedocs.io/en/latest/parameter.html
)
print(param) # En la práctica deberías explorar grillas más extensas.

auc = M.star = c()
for(i in 1:6){
xgboost.cv <- xgb.cv(data = xgb_train,
              objective = "binary:logistic",
              eval_metric = "auc",
              nthread=8,
              nrounds = 500,
              nfold = 5,
              early_stopping_rounds = 50, 
              verbose = F,
              params = list(
              max.depth = param[i,1],     
              eta = param[i,2],         
              subsample = 0.5)   
)

auc[i] = max(xgboost.cv$evaluation_log[, test_auc_mean])
M.star[i] = which.max(xgboost.cv$evaluation_log[, test_auc_mean])

print(i)
}

# Resultados:    
cbind(param,auc,M.star)
which.max(auc)

set.seed(1) 
optim.boost <- xgb.train(data = xgb_train,
                       nrounds = 1000,
                       nthread = 8,
                       watchlist=watchlist,
                       objective = "binary:logistic",
                       params = list(
                       max.depth = 4,  
                       eta = 0.05,
                       subsample = 0.5)
                       ) 

pred <- predict(optim.boost, xgb_test)
head(pred, 3)

y.test = ifelse(pred >0.33,1,0)
head(y.test, 3)
table(y.test, colisiones$VAR_OBJETIVO[-id.train])/171214*100
# Tasa de error del 31% (aprox).


# Quedan por explorar otras acciones como: 
# - Ingeniería de atributos.
# - Optimización de hiper-parámetros sobre una grilla más grande.
# ------------------------------------------------------------------------- END.