rm(list=ls())
# ------------ Pipeline para hacer redes neuronales (1 capa oculta)-------#
##########################################################
require(graphics) || install.packages('graphics')    ##### # Manipular pixeles en R.
require(nnet)     || install.packages('nnet')        ##### # Fitting Modelo red de una capa oculta R.
require(caret)    || install.packages('caret')       ##### # Tunear hiperparámetros con CARET.
########################################################## 
library(graphics); library(nnet); library(caret)

### Cargamos el dataset relativo a las imágenes de los dígitos:
setwd('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 9/Datos')
X=read.table('MNIST.csv', sep=',',header = T) # Features de c/ imágen.
dim(X) # 60.000 img.   785 = 1 + 28x28

X[1,1]   # Label de la primera imagen (se trata de un 5).
X[1,2:4] # Primeras 3 coordenadas de la primera imagen (0 = negro y 255 = blanco)
         # Ver slide 24 para comprender como se debe interpretar este vector de covariables con los que representamos a la imagen.
x11()
plotDigits <- function(images){ # Indicas las filas que querés representar.
  op <- par(no.readonly=TRUE)
  x <- ceiling(sqrt(length(images)))
  par(mfrow=c(x, x), mar=c(.1, .1, .1, .1))
  
  for (i in images){ 
    m <- matrix(data.matrix(X[i,-1]), nrow=28, byrow=TRUE)
    m <- apply(m, 2, rev)
    image(t(m), col=grey.colors(255), axes=FALSE)
    text(0.05, 0.2, col="red", cex=2.5, X[i, 1])
  }
  par(op) #resetea la configuración de la ventana gráfica.
}
plotDigits(1:9) # argumnento son las filas que se corresponden con diferentes imágenes.

y = X[, 1]       # Labels o etiquetas
X = X[,-1] / 255 # valor pixel normalizado en [0,1] (28x28)
#@ Alternativamente puedes utilizar el comando 'scale()'

barplot(table(y), col=rainbow(10, 0.5), main="Distrib digitos en la BD")
###################### Fin de la parte descriptiva.

### Data preproc: Problema de clasificación binaria de los dígitos 3 vs 8.
id = which(y == 3 | y == 8 )
X2 = X[ id , ]          # filtramos las filas de las imagenes q se corresp con 8 y 3
y2 = as.factor(y[ id ]) # Codificamos como un factor en caso de prob de clasific.

dim(X2)

table(y2)
n = 6131 + 5851 # 11982 imágenes para entrenar el modelo.

### TRAIN (60% para selección) y TEST (40% para valoración)
set.seed(123456789)
id.sample = sample(n, 0.6*n)
TRAIN.X = X2[  id.sample , ]; TRAIN.y = y2[   id.sample ]
TEST.X =  X2[ -id.sample , ]; TEST.y  = y2[ - id.sample ]
#@ Importante: Reescalamiento o estandarización de features (en este caso no es necesario porque ya estan en la misma escala).
###################### Fin manipulaci\'on de datos.

#### Modelo: 1 neurona en la capa oculta y 2 neuronas capa salida:
head(class.ind(TRAIN.y), 3) # <--- la # de columnas = # neuronas en capa salida

set.seed(1)
nn = nnet(x = TRAIN.X,            # Features.
          y = class.ind(TRAIN.y), # Respuestas (matriz 2 columnas)
          size = 3,       # Nro de neuronas en la capa oculta. 
          linout = FALSE, # linout = TRUE (en caso de resolver prob de reg.)
          entropy = TRUE, # Función de riesgo empírico a minimizar.
          decay = 0.5,   # Parámetro de regularización "lambda".
          maxit = 1000,    # Número máximo de iteraciones
          MaxNWts = 5000
)

# Cargar 'plotnnet.R':
source('plotnnet.R')
x11()
plot.nnet(nn) 

nn$convergence # 1 si paramos por alcanzar máximo nro de iter, otherwise 0.
nn$value # Min de la fun objetivo (entropía) en el mínimo al que arribó el gradiente descendiente.

summary(nn) # Pesos (par\'ametros estimados)

head(nn$fitted.values) # Output (activación logística -> probabilidades)

pred = predict(nn, TEST.X)
head(pred)

pred.clas = ifelse(pred[,1] > pred[,2], 3, 8)
table(pred.clas, TEST.y)

mean(pred.clas == TEST.y) # Tasa de acierto: 0.97 (aprox).

#### Selección de modelos con CARET (VC):
metodo.validacion <- trainControl(method = "cv", number = 5) # Validación cruzada con 5 folds.

grid_par <- expand.grid(.size = c(2:7),.decay = c(0.05,0.1))
grid_par # Grilla de valores para los hiperparámetros (no olvidar poner el "." en el nombre del hiperparámetro)

set.seed(1)
nn.caret <- train(TRAIN.X, make.names(TRAIN.y),
                  method = "nnet", # Modelo a utilizar.
                  metric = "Accuracy",  # Métrica.
                  trControl= metodo.validacion, # M\'etodo de validaci\'on (CV).
                  tuneGrid = grid_par, # Grilla con valores de los param.
                  MaxNWts = 5000 # The maximum allowable number of weights.
)

nn.caret # Summary del modelo (parametros y performance estimados por VC)
#size  decay  Accuracy   Kappa  # https://en.wikipedia.org/wiki/Cohen%27s_kappa  
#1     0.05   0.9627204  0.9254206
#1     0.10   0.9657813  0.9315399
#5     0.05   0.9803869  0.9607517 # Mejor Modelo (tasa error 2%)
#5     0.10   0.9757953  0.9515697
#Accuracy was used to select the optimal model using the largest value.
#The final values used for the model were size = 5 and decay = 0.05.
#.----------------------------------------------------------------- End.

###################################################################
############# Apéndice: Problemas de clasificación multiclase. ####
###################################################################
####### Problema multiclase (todos los datos)
### Divido el conjunto en TRAIN (60%) y TEST (40%)
set.seed(123456789)
id.sample = sample(60000, 0.6*60000)

TRAIN.X = X[  id.sample , ]; TRAIN.y = y[   id.sample ]
TEST.X =  X[ -id.sample , ]; TEST.y  = y[ - id.sample ]
table(TRAIN.y)

set.seed(123456789)
nn = nnet(x = TRAIN.X, y = class.ind(TRAIN.y), # Matriz con diez columnas, cada una es una neurona en la capa de salida.
          size = 10,      # Nro de neuronas en la capa oculta. 
          MaxNWts = 8000, # Número máximo de parámetros en la red (> 10*784 + 10)
          linout = FALSE, 
          entropy = TRUE, 
          decay = 0.05,   
          maxit = 100      # Deberías considerar un tamaño mayor!
)


# plot.nnet(nn) # Toma más tiempo visualizar el modelo que fitearlo.
                # Hay 10 neuronas en la capa intermedia y 10 neuronas en la capa 
                # de salida (soft-max).


pred = predict(nn, TEST.X, type = 'class' )
head(pred)
table(pred, TEST.y)

mean(pred == TEST.y) # Accuracy: 0.9012 (aprox)

# Necesitamos una arquitectura m\'as compleja para capturar
# los diferentes patrones en las im\'agenes.
# Deberíamos intentar fitear un modelo de red con mas neuronas en
# la capa oculta (pero sin pasarnos de rosca para evitar overfitting)

####################################### Estimación por VC de "size" y "decay"
####################################### Líneas de código para investigar en casa.


# install.packages('doParallel')
# library(doParallel)

# no_cores <- detectCores() 
# cl <- makeCluster(no_cores- 1) 
# cl

# registerDoParallel(cl)

# Set up de algunos parámetros que vamos a setear por VC
metodo.validacion <- trainControl(method = "cv", number = 2) # number = 5

grid_par <- expand.grid(.size = c(12, 15),
                       .decay = c(0.1,0.75))
grid_par

set.seed(123456789)
nn.caret <- train(TRAIN.X, make.names(TRAIN.y),
             method = "nnet", # Que tipo de modelo voy a utilizar.
             metric = "Accuracy",  # Con que metrica voy a juzgar el modelo.
             trControl= metodo.validacion, # M\'etodo de validaci\'on.
             tuneGrid = grid_par, # Grilla con valores de los param.
             MaxNWts = 12000 # 
)

nn.caret # Summary del modelo (parametros y performance estimados por VC)
         # a continuación mis resultados:

# Resampling: Cross-Validated (2 fold) 
# Summary of sample sizes: 18000, 18000 
# Resampling results across tuning parameters:
  
#  size  decay  Accuracy   Kappa    
#  12    0.10   0.8968611  0.8853648
#  12    0.75   0.9045833  0.8939486
#  15    0.10   0.8941944  0.8824014
#  15    0.75   0.9278333  0.9197917

pred = predict(nn.caret, TEST.X)
table(pred, TEST.y)

#                    TEST.y
#pred    0    1    2    3    4    5    6    7    8    9
#X0   2279    0   26   18    2   19   17    6    9    8
#X1       1 2635   16   18    7    9    1    8   19    8
#X2       13   16 2201   41   21    6   17   20   35    3
#X3        1   14   18 2257    1   69    2   22   14   23
#X4        7    1    8    4 2155   12   19   24   10   55
#X5       22    9    6   50    9 1945   28    5   50   23
#X6       17    3   18   10   27   30 2253    1   14    0
#X7        0   15   38   34   20    4    2 2354    3   44
#X8       17   34   21   25    6   26   12    4 2133   13
#X9        3    5    4   24   85   23    0   54   24 2258

sum(diag(table(pred, TEST.y)))/length(TEST.y) # Accuracy: 0.93652 (aprox)
# stopCluster(cl)
############################################################ END.