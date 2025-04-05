################# kNN en R: https://cran.r-project.org/web/packages/FNN/FNN.pdf
# install.packages('FNN');
library(FNN)
###############################################################################

##### 1) Simulando los datos de entrenamiento:
f <- function(X){sin(2*X) + sqrt(X)}
X = seq(0,4*pi,length.out = 100)
set.seed(123) # Fijamos la semilla para que todos tengamos el mismo data set.
Y =  f(X) + rnorm(100)

par(mar=c(4,4,1,1))
plot(X,f(X), type = 'l',ylab='Y',
     ylim = c(-3,6),bty='n', lwd = 3, lty = 1)
points(X,Y, pch = 20)

################################################################################
head(knn.index(X, k = 2), 3)  # Para cada x del data set de train sus 2 vecinos cercanos. 
head(knn.dist(X, k = 2 ), 3 ) # las respectivas distancias.


## Regresión con k--vecinos:
kNN.reg = knn.reg(train = X , test = NULL, y = Y, k = 10)

head(kNN.reg$pred, 3)# Predicciones (valores de Y predichos para las primeras 3 obs).

head(kNN.reg$residuals, 3)# Distancia entre predicciones y valores observados.

sum(kNN.reg$residuals^2) # Suma de cuadrados residuales

1- sum(kNN.reg$residuals^2) / sum( (Y-mean(Y))^2 ) # R^2 = 1-SCR/SCT

kNN.reg # PRESS = suma de cuadrados residuales.


points(X, kNN.reg$pred, type='l', col = 'red', lwd = 2, lty = 2)


kNN.reg = knn.reg(train = X , test = NULL, y = Y, k = 50)
kNN.reg # PRESS = Suma de cuadrados
points(X, kNN.reg$pred, type='l', col = 'blue', lwd = 2, lty = 2)

kNN.reg = knn.reg(train = X , test = NULL, y = Y, k = 1)
points(X, kNN.reg$pred, type='l', col = 'green', lwd = 2, lty = 2)
##### Conclusión: 
                  # k pequeño: Modelo se ajusta demasiado a los datos.
                  # k grande: Modelo tiende a la media de las y's observadas.
                  # Para valores intermedios de k el modelo parece fitear bien.
################ End regresión.