rm(list=ls())
#------------------ Bagging: Caret + Rpart       ---------------------#
require(caret) || install.packages('caret'); library(caret)           #
require(rpart) || install.packages('rpart'); library(rpart)           #
setwd('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 7/Datos')
datos = read.table(file = 'encuesta.txt', sep = ',', dec = '.', header = T)
head(datos, 3) # Ver diccionario de variables en campus.

dim(datos)
sum(complete.cases(datos)) # No hay datos perdidos (fueron imputados con la libreria MissingForest).

### Objetivo:
table(datos$Party)/5568 # 53% Democrats vs 47% Rep.
datos$Party = as.factor(datos$Party)

set.seed(321)
id.train = sample(5568, 4568) 

set.seed(1)
f.bagg  <- train(Party ~ .,      
                      data = datos[id.train,],
                      weights = NULL,        # Modelos robustos a datos atípicos. 
                      method = "treebag",    # Ensamblamos árboles.
                      trControl = trainControl(method = "oob"), 
                      keepX  = T , # Estimación del error por oob
                      metric = 'Accuracy',
                      nbagg = 100, # B (Lo más grande que puedas) 
                      control = rpart.control(minsplit = 800)) # Parámetros de compljidad de los árboles.
print(f.bagg) #Acc = 0.67 -> Error = 33% (approx). 
              # Kappa: https://en.wikipedia.org/wiki/Cohen%27s_kappa

f.bagg$results

1- f.bagg$results[1]

varImp(f.bagg) # Importancia de cada variable en el ensamble.
# Mirar el diccionario de variables.

x11(); dotPlot(varImp(f.bagg)) # Idem pero en una gráfica.

# Predicciones sobre TEST (no cross-validamos la complejidad del modelo) 
pred.bagg = predict(f.bagg, newdata = datos[-id.train,])
head(pred.bagg, 3)

table(pred.bagg, datos$Party[-id.train])/1000
# Tasa de error del 34% approx (benchmark para Forest).
# ---------------------------- End.

# Tarea en casa: Optimiza el hiperparámetro minsplit utilizando OOB.
valores.minsplit = c(500, 600, 700, 900)
hat.te.oob = c()
for(i in 1:4){
f.bagg  <- train(Party ~ .,      
                 data = datos[id.train,],
                 method = "treebag",    
                 trControl = trainControl(method = "oob"), 
                 keepX  = T , 
                 metric = 'Accuracy',
                 nbagg = 100, 
                 control = rpart.control(minsplit = valores.minsplit[i])) 

hat.te.oob[i] = 1- f.bagg$results[1]
print(i)
}

# minsplit* = 600

# Una vez seleccionado el grado adecuado de complejidad de los modelos a ensamblar, 
# reestimamos  el ensamble con los datos de train y estimamos su calidad predictiva
# utilizando los datos de test.

set.seed(1)
f.bagg  <- train(Party ~ .,      
                 data = datos[id.train,],
                 method = "treebag",    
                 trControl = trainControl(method = "oob"), 
                 keepX  = T , 
                 metric = 'Accuracy',
                 nbagg = 100, 
                 control = rpart.control(minsplit = 600)) 
pred.bagg = predict(f.bagg, newdata = datos[-id.train,])
table(pred.bagg, datos$Party[-id.train])/1000 # acc = 33% aprox.
#-------------------------------------------------------------------------end.