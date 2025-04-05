# ------------- Pipeline: Deep Learnign con Keras ----------------#
rm(list=ls()); dev.off()
#install.packages('ISLR2'); library(ISLR2)

#  @ Seguí las líneas debajo para instalar keras en tu compu.
#  (@VER https://web.stanford.edu/~hastie/ISLR2/keras-instructions.html @)

# En caso de que hubieras intentado instalar los paquetes de manera incorrecta en el pasado:
tryCatch(
  remove.packages(c("keras", "tensorflow", "reticulate")),
  error = function(e) "Some or all packages not previously installed, that's ok!"
)


# Primero instalamos "keras" y "conda"
install.packages("keras")
reticulate::install_miniconda()
keras::install_keras(method = "conda", python_version = "3.10")


library(keras)
reticulate::use_condaenv(condaenv = "r-tensorflow")

######################################################################### END.

#####  Preparando los datos:
setwd('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 9/Datos')
X <- read.table(file = 'fashion-mnist.csv',sep =',', header = T)
dim(X)

head(X,1) # Ver labels en las slides (# 56). Similar al data set con dígitos.

################################################################################
plotFashion <- function(images){ 
  op <- par(no.readonly=TRUE)
  x <- ceiling(sqrt(length(images)))
  par(mfrow=c(x, x), mar=c(.1, .1, .1, .1))
  
  for (i in images){ 
    m <- matrix(data.matrix(X[i,-1]), nrow=28, byrow=TRUE)
    m <- apply(m, 2, rev)
    image(t(m), col=grey.colors(255), axes=FALSE)
    text(0.05, 0.2, col="red", cex=2.5, X[i, 1])
  }
  par(op)
}
################################################################################

x11(); plotFashion(1:9)

y = X[, 1]       # Labels o etiquetas
X = X[,-1] / 255 # valor pixel normalizado en [0,1] (28x28) <- Es importante escalar los features para acelerar la convergencia del algoritmo con el que aprendemos los parámetros del modelo.

set.seed(1)
train.id = sample(30000,30000) # 30 mil imágenes en train y 30 mil en test.

x_train = as.matrix(X[ train.id, ]); dim(x_train)
train_labels = y[train.id]

x_test  = as.matrix(X[-train.id, ])
test_labels = y[-train.id]

# Para pre-procesar las imágenes y aplicar filtros kernas  
# necesita las imagenes en formato 'fila-columna' (como lo describimos en teoría): 
x_train <- x_train %>% array_reshape(c(30000, 28, 28, 1)); dim(x_train) # 30000    28    28     1
dim(x_train) # array de 30 mil imágenes de 28x28x1 (blanco y negro).
# si las imágenes fueran en color, tendriamos 30mil arrays de 28x28x3 (RGB) 

x_test <- x_test %>% array_reshape(c(30000, 28, 28, 1)) #idem al caso anterior.

# Especificando el modelo (arquitectura de la red convolucional profunda):
model <- keras_model_sequential()
model %>%
  layer_conv_2d(filters = 32, kernel_size = c(3,3), activation = 'relu', 
                   input_shape = c(28, 28, 1), name = 'CapaConvolucion') %>% # CAPA de convolución + ReLu.
  layer_max_pooling_2d(pool_size = c(2,2), name = 'CapaPooling') %>% # CAPA de pooling.
  layer_flatten(name = 'CapaFlat') %>% # CAPA de 'vectorización' (aplastamiento).
  layer_dense(units = 128, activation = 'relu', name = 'CapaOculta1') %>% # Capa oculta de neuronas (activacion relu).
  layer_dropout(rate = 0.5) %>% # Tasa de dropout = 50% (regularización, en algún sentido es parecido a hacer "lasso").                 
  layer_dense(units = 10, activation = 'softmax', name = 'CapaSalida') # Capa de salida (activacion softmax, ver apéndice).

summary(model)



# "Compilamos" el modelo: 
model %>% compile(
  loss = 'sparse_categorical_crossentropy',
  optimizer = 'adam', 
  metrics = c('accuracy')
)

# Fiteamos el modelo: 
history <- model %>% fit(x_train, train_labels, epochs = 10) # Con epochs controlamos la cantidad de recursiones.

# x11(); plot(history)

# Evaluamos el modelo sobre el conjunto de test: 
score <- model %>% evaluate(x_test, test_labels)


cat('Test loss:', score[1], "\n") # Valor de la cross--entropy (función de riesgo empírico) en el conjunto de test.

cat('Test accuracy:', score[2], "\n") # Acierto del 90% sobre test.

predictions <- model %>% predict(x_test)

dim(predictions) # Contiene las salidas de la red profunda.

head(round(predictions,3),3);

head(rowSums(predictions),5) # Activación softmax en la capa de salida (ver slide 56, apéndice).

which.max(predictions[1, ])
head(apply(predictions, 1, which.max), 3) # <- indica a que categoría se corresponde la probabilidad estimada más alta.

class_pred <- model %>% predict(x_test) %>% k_argmax() # Asigna a la clase más probable.
class_pred[1:4] # 0 = T-Shirt, 1 = Touser... etc

class_names = c('T-shirt/top','Trouser','Pullover',
                'Dress','Coat','Sandal','Shirt',
                'Sneaker','Bag','Ankle boot')

x11() # Tomamos las primeras 25 observaciones de Test
options(repr.plot.width=7, repr.plot.height=7) 
par(mfcol=c(5,5))
par(mar=c(0, 0, 1.5, 0), xaxs='i', yaxs='i')
for (i in 1:25) { 
  img <- x_test[i, , ,1]
  img <- t(apply(img, 2, rev)) 
  # subtract 1 as labels go from 0 to 9
  predicted_label <- which.max(predictions[i, ]) - 1
  true_label <- test_labels[i]
  if (predicted_label == true_label) {
    color <- '#008800' 
  } else {
    color <- '#bb0000'
  }
  image(1:28, 1:28, img, col = gray((0:255)/255), xaxt = 'n', yaxt = 'n',
        main = paste0(class_names[predicted_label + 1], " (",
                      class_names[true_label + 1], ")"),
        col.main = color)
}
#----------------------------------------------------- End.