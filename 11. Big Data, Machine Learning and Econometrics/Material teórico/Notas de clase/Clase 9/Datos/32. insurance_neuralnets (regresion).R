rm(list=ls())
# --------------- Pipeline: Regresión con redes profundas --------------------# 
##########################################################
require(neuralnet) || install.packages('neuralnet')  #####
##########################################################
library(neuralnet) # Manual: https://cran.r-project.org/web/packages/neuralnet/neuralnet.pdf

setwd('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 9/Datos')
datos = read.table(file='insurance.csv',header = T, sep=',', dec='.')

#@ Diccionario de variables:
# age: edad del beneficiario de la póliza.
# sex: género declarado por el asegurado.
# bmi: índice de masa corporal al contratar la póliza.
# children: número de hijos cubiertos en la póliza.
# smoker: fumador o no.
# region: residencia del beneficiario (1: northeast, 2: southeast, 3:southwest, y 4:northwest).
# charges: costo de los tratamientos médicos de cada asegurados.
# insuranceclaim: costos reclamados o no (1 y 0 respectivamente).

summary(datos)
# Objetivo: modelar el costo esperado de cada beneficiario.
# Omitimos "insuranceclaim". 

######## Pre-proceso con los datos: 
set.seed(123456789); samp=sample(1338,1000)
# Modelo auxiliar para recuperar la info de las variables categóricas 
preproc.factorial = lm(charges ~ sex + smoker + region , 
                       data = datos, subset = samp) # (solo uso datos de TRAIN)
summary(preproc.factorial) 

x_comb = predict(preproc.factorial, newdata = datos) 
# x_comb captura los efectos (lineales) de las covariables: sex, smoker y region.

#@ @ @ ES MUY IMPORTANTE QUE ESCALES LAS VARIABLES ANTES DE FITEAR!!!!!
datos2 = scale(cbind(datos[ ,-c(2,5,6,8) ],x_comb))
head(datos2)

# Repartimos la data en TRAIN (1m) y Validación (338)
Train =datos2[ samp,]; dim(Train)
Valid =datos2[-samp,]; dim(Valid)
#---------------------------------------- Final del preproceso de datos.

###################################################
#############   Redes Neuronales profundas     ####
###################################################
#@ Benchmark: RN con 3 neurona en la capa oculta:
set.seed(1) # (replicabilidad)
neu.char = neuralnet(charges ~. , 
               data = Train,           #@IMP: Las variables estan escaladas (ver línea 36)
               hidden = c(3),          # 1 capa oculta, con 3 neuronas.
               rep = 1,                # Re-entrenamientos de la red (recomendable valores > 1).
               learningrate = 0.1,     # lambda
               algorithm = "rprop+",   # (algoritmo para comptr gradiente). 
               err.fct = 'sse',        # F. Pérdida/Riesgo (ce=cross entropy y sse = suma cuad residuales)
               act.fct = 'logistic',   # Activaciones en capa/s ocultas.
               linear.output = TRUE   # Salida lineal (problema de reg)
)

X11()
plot(neu.char)

# Pasamos las filas del data set por la red con pesos entrenados:
train_pred = predict(neu.char, newdata =  Train) # output reescalado
valid_pred  = predict(neu.char, newdata = Valid)     # output reescalado

mean.cha = mean(datos$charges); sd.cha   = sd(datos$charges)

train_pred  = train_pred*sd.cha + mean.cha # Des-escalamos las predicciones en train y valid.
valid_pred  = valid_pred*sd.cha + mean.cha
head(valid_pred)

plot(valid_pred, Valid[,4]*sd.cha + mean.cha, type = 'p', pch = 20,
     xlab = 'Predicciones Net', ylab = 'hat.Y en Validación')

# Error standard de SVM en muestra de validación: 4713.
sqrt( sum( (valid_pred - (Valid[,4]*sd.cha + mean.cha))^2  ) / 338 )
# 4416 (y aún podemos intentar optimizar la arquitectura de la red)

#####################################################################
#### Selección de modelo (arquitectura):           ##################
#####################################################################
capa1 = c(8,6);capa2 = c(4,2);lambda = c(0.1,0.5)
grilla = expand.grid(capa1,capa2,lambda)
head(grilla,3) # todas las combinaciones posibles.

scr.valid = c(); set.seed(1)
for(i in 1:dim(grilla)[1]){
  neu.char = neuralnet(charges ~. ,
                       data = Train,
                       hidden = c(grilla[i,1],grilla[i,2]), # Recorremos la grilla.
                       rep = 1, # idealmente más grande. 
                       learningrate = grilla[i,3],  # Recorremos la grilla.
                       algorithm = 'rprop+', 
                       err.fct = 'sse', 
                       act.fct = 'logistic', 
                       linear.output = TRUE,
                       threshold = 0.1)

  # Pasamos las filas del data set por la red con pesos entrenados:
  valid_pred  = compute(neu.char, Valid)$net.result  # output reescalado
  valid_pred  = valid_pred*sd.cha + mean.cha
  scr.valid[i] = sqrt( sum( (valid_pred - (Valid[,4]*sd.cha + mean.cha))^2  ) / 338 )
  print(i)
}

min(scr.valid) # 200 usd de error promedio menos en relación al benchmark.

which(scr.valid == min(scr.valid))
grilla[8,] # Estructura de red de (6,2) y learning rate de 0.5.
#-------------------------------------------------------------------------- END.