rm(list=ls())
# ------------ Pipeline para hacer redes neuronales (varias capa oculta)-------#
##########################################################
require(neuralnet) || install.packages('neuralnet')  #####
require(ggplot2)   || install.packages('ggplot2')    #####
##########################################################

# Revisitamos el ejemplo de clasficar los datos en espiral.
N = 250 ; K = 4 ; D = 2 # Dimensión de los datos.
X <- data.frame() ; y <- data.frame()

set.seed(1)
for (j in (1:K)){
  r <- seq(0.05,1,length.out = N) # rad
  t <- seq((j-1)*4.7,j*4.7, length.out = N) + rnorm(N, sd = 0.3) 
  Xtemp <- data.frame(x =r*sin(t) , y = r*cos(t)) 
  ytemp <- data.frame(matrix(j, N, 1))
  X <- rbind(X, Xtemp)
  y <- rbind(y, ytemp)
}

data <- cbind(X,y)
colnames(data) <- c('X1','X2', 'y')
data$y = as.factor(ifelse(data$y==1|data$y==3,'1','2'))
x11()
plot(data[,1],data[,2], pch = 20, col = data[,3] , 
     main = 'datos en espiral', xlab = 'X1', ylab = 'X2')

head(data,2)

######## Train y validación (para aprender arquitectura razonable): 
require(neuralnet) || install.packages('neuralnet')  #####
library(neuralnet) # Manual: https://cran.r-project.org/web/packages/neuralnet/neuralnet.pdf


set.seed(1); train.id=sample(1000,750) # Train y validación (No hay datos de test, ya que solo nos 
                                       # interesa ilustrar como hacer selección de modelo).

data[,c(1,2)] <- scale(data[,c(1,2)]) # Escalo los features.


#@ Benchmark: RN con 2 capas ocultas y mi propia función de activación (diferenciable):
mi_activ <- function(x){exp(-0.05*x^2)} # Tiene que ser diferenciable.
x11(); plot(mi_activ, from =-3,to=3)

set.seed(321) # (replicabilidad)
nnet.bench = neuralnet(y ~. , 
               data = data[train.id,], # Recomendable tener las variables en la misma escala.
               hidden = c(3,2),        # 2 capa ocultas, de 3 y 2 neuronas.
               rep = 3,                # Re-entrenamientos de la red.
               learningrate = 0.05,    # lambda
               err.fct = 'ce',         # F. Pérdida/Riesgo (ce=cross entropy y sse = suma cuad residuales)
               act.fct = mi_activ,     # Activaciones en capa/s ocultas (sigmoide por defecto).
               linear.output = FALSE,  # Salida lineal para problema de regresión (TRUE por defecto)
               threshold=0.5,  stepmax= 5000 # parámetros para controlar la cantidad de iter.
) 

x11(); plot(nnet.bench)

nnet.bench$result.matrix # Resultados de las 3 estimaciones.
#Notar que las estimaciones de los parámetros pueden cambiar bastante en cada re-iteración del gradiente descendiente.

# Predicciones de cada uno de los modelos: (predecimos con el 3er modelo estimado)
train_pred = predict(nnet.bench, data[ train.id,], rep = 3, all.units = FALSE)
head(train_pred, 3) # "Probabilidades".

y.hat.train = ifelse(train_pred[,1]>train_pred[,2],1,2)
head(y.hat.train, 3) # Predicciones de categorías.

table(y.hat.train, data[train.id,3])

valid_pred  = predict(nnet.bench, data[-train.id,], rep = 3)
head(valid_pred, 3) # idem.

y.hat.valid = ifelse(valid_pred[,1]>valid_pred[,2],1,2)

table(y.hat.valid, data[-train.id,3])

te.valid = 1 - sum(diag(table(y.hat.valid, data[-train.id,3])))/250
te.valid

#####################################################################
#### Validación arquitectura:           #############################
#####################################################################
capa1 = c(5,4);capa2 = c(3,2);lambda = c(0.05,0.1)
grilla = expand.grid(neurcapa1 = capa1, neurcapa2 = capa2,learningrate = lambda)
head(grilla,3) # todas las combinaciones posibles.

te.valid = c()

mi_activ <- function(x){exp(-x^2)} 

set.seed(1)
for(i in 1:dim(grilla)[1]){#* Para mejorar este código, para cada fila de la matriz 'grilla' deberías considerar varias re-estimaciones del modelo (rep > 1).
  nnet.cv = neuralnet(y ~. , 
                       data = data[train.id,], 
                       hidden = c(grilla[i,1],grilla[i,2]), 
                       learningrate = grilla[i,3],  
                       err.fct = 'ce',         
                       act.fct = mi_activ,   # Activación sigmoide por defecto.  
                       linear.output = FALSE,
                       threshold = 0.25) 

  valid_pred  = predict(nnet.cv, data[-train.id,])
  y.hat.valid = ifelse(valid_pred[,1]>valid_pred[,2],1,2)
  
  te.valid[i] = 1 - sum(diag(table(y.hat.valid, data[-train.id,3])))/250
  print(i)
}

cbind(grilla,te.valid) # output.

which(te.valid == min(te.valid))
grilla[5,] # Entre los modelos fiteados, este es la mejor arquitectura.
############################################################################### END.
#cbind(grilla,te.valid) # output.
#neurcapa1 neurcapa2 learningrate te.valid
#1         5         3         0.05    0.208
#2         4         3         0.05    0.132
#3         5         2         0.05    0.152
#4         4         2         0.05    0.196
#5         5         3         0.10    0.128*
#6         4         3         0.10    0.232
#7         5         2         0.10    0.176
#8         4         2         0.10    0.304
## Como puedes ver en este ejercicio, si bien en principio las redes modelan
## regiones de decisión muy complejas en el espacio de features, hacer selección
## de modelo (calibrar la arquitectura de la red) es un trabajo computacionalmente intesivo.