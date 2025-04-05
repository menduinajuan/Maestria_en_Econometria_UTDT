# -------- Pipeline Redes profundas para Series Temporales en R ------------#
rm(list=ls()); dev.off()
########################################################################
require(neuralnet) || install.packages('neuralnet');library(neuralnet)##
########################################################################
#@1: Explotarción y analisis Descriptivo mínimo y data pre-proc: 
setwd('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 9/Datos')
load('MER_2016_2018.RData')

head(MERVAL,3)

dim(MERVAL)

#### Diccionario: l = low, h = high, o = open, c = close y r = riesgo país.
#   ************  m = mean y s = sd (respecto de los últimos 3 días hábiles)
#                 c1 = c. día anterior, c2 = c. dos días atrás, c3 = c. tres días atrás
#                 y = log(c_{t+1}/c_{t}) (logreturns) 
x11()
plot(MERVAL$dia,MERVAL$y, type='b', lty=2, ylab = 'Retornos',xlab = 'Tiempo')

### Rezagamos la variable de respuesta para tomarla como un feature:
MERVAL$y_t_1                      = rep(NA,dim(MERVAL)[1])
MERVAL$y_t_1[2:dim(MERVAL)[1]]    = MERVAL$y[1:(dim(MERVAL)[1]-1)]
head(MERVAL,3) # Tendremos que omitir la observación del primer día hábil del 2016

MERVAL = na.omit(MERVAL)
head(MERVAL,3) # Ok

#### Recodificamos para fitear un modelo que predice las direcciones en las que evoluciona el MERVAL:
MERVAL$y        = as.factor(ifelse(MERVAL$y>0, 1,0))
head(MERVAL,3)

table(MERVAL$y)
#Dividimos en "train", "validación" (hold out set) y "test":
id.train  = which(MERVAL$dia<'2017-09-01') # 1 año y 9 meses train (datos desde Enero de 2016).
id.valid  = which(MERVAL$dia>='2017-09-01' & MERVAL$dia<'2018-01-01') #4 meses de Hold-Out set.
id.test   = which(MERVAL$dia>='2018-01-01') # 1 año de test.

#@ Reescalamiento de features
X  = scale(MERVAL[,c(2:14,16)]); # No incluyo fecha y ni variable target.
merval = data.frame(X, y = MERVAL$y) #y.up = MERVAL$y.up,y.dw = MERVAL$y.dw)
head(merval); # str(merval)

#@2: Modelo de benchmark y selección de modelo (arquitectura):
nam <- names(merval)
form <- as.formula(paste("y ~ ", paste(nam[!nam %in% c("y")], collapse = " + ")))
form # Fórmula del modelo.

set.seed(1)
retornos = neuralnet(formula = form, 
                       data =  merval[id.train,], # 1 año y 9 meses. 
                       hidden = c(4,2),        # Dos capas ocultas, con 4 y 2 neuronas resp.
                       rep = 1,                # Re-entrenamientos de la red.
                       learningrate = 0.1,     # lambda
                       err.fct = 'ce',         # F. Pérdida/Riesgo (ce=cross entropy y sse = suma cuad residuales)
                       act.fct = 'logistic',   # Función de activación.
                       linear.output = FALSE,  # No hay activación lineal antes de la capa de salida (pq es un problema de clasificación)
                       threshold = 0.05        # tolerancia (umbral para el gradiente)
                     )

#retornos$err.fct # Función de riesgo / Pérdida: L(y,hat(y))
#retornos$act.fct # Función de activación de cada neurona.
plot(retornos)

# Pasamos las filas del data set por la red con pesos entrenados:
train_pred = predict(retornos, newdata = merval[id.train,])
valid_pred = predict(retornos, newdata = merval[id.valid,])
test_pred  = predict(retornos, newdata = merval[id.test,] )

head(train_pred, 3) # "Probabilidades" estimadas de subir y bajar al día siguiente.

# Recodificamos las predicciones comparando columnas:
train_pred = ifelse(train_pred[,1] > train_pred[,2],0,1) # Treshold de 0.5
valid_pred = ifelse(valid_pred[,1]>valid_pred[,2],0,1)
test_pred  = ifelse(test_pred[,1] > test_pred[,2],0,1)

# Performance (Tasa de Error) en la muestra de de TRAIN:
table(train_pred, merval$y[id.train])
1-sum(diag(table(train_pred, merval$y[id.train])))/sum(table(train_pred, merval$y[id.train]))
# ... en la muestra Hold - Out:
table(valid_pred, merval$y[id.valid])
1-sum(diag(table(valid_pred, merval$y[id.valid])))/sum(table(valid_pred, merval$y[id.valid]))
# ... en la muestra de TEST:
table(test_pred, merval$y[id.test]) 
1-sum(diag(table(test_pred, merval$y[id.test])))/sum(table(test_pred, merval$y[id.test]))


#############################################################################################
#### Fitting de parámetros sensibles de la red: (similar a lo que hicimos en ejemplo 2) #####
#############################################################################################
capa1 = c(12,8);capa2 = c(4,2);lambda = c(0.1,0.5)          
grilla = expand.grid(capa1,capa2,lambda, te.valid = 0)
colnames(grilla) <- c('NeuronasCapa1','NeuronasCapa2','Lambda', 'TasaErrorEstimada')
head(grilla,3) # todas las combinaciones posibles.

set.seed(1)
for(i in 1:dim(grilla)[1]){
  retornos = neuralnet(formula = form, 
                       data =  merval[id.train,], 
                       hidden = c(grilla[i,1],grilla[i,2]), # <- Vamos modificando la arquitectura.
                       rep = 1,   
                       learningrate = grilla[i,3],   # <- al tiempo que consideramos distintas 'learning rates'
                       err.fct = 'ce', 
                       act.fct = 'logistic', linear.output = FALSE,
                       threshold = 0.1, stepmax = 1e+07)
valid_pred  = predict(retornos, newdata =  merval[id.valid,] )
valid_pred  = ifelse(valid_pred[,1] > valid_pred[,2],0,1)
grilla[i,4] = 1-sum(diag(table(valid_pred, merval$y[id.valid])))/sum(table(valid_pred, merval$y[id.valid]))
print(i)
}

print(grilla)
# Una vez que determines la mejor arquitectura de la red, puedes hacer el ejercicio 
# cuantitativo de utilizar el mejor modelo de red para tradear a lo largo del 2018.
# Es esperable que tus resultados sean apenas mejores que los que obtendrías tirando
# la moneda. ¿Porqué no puedo predecir con la red las direcciones en que cambia el MERVAL?.
##------------------------------------------------------------------------------------- End.