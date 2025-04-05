#-----     Regresión polinómica vs Splines vs Natural splines en R ------#
# En este ejercicio no vamos a cross-validar ningún hiperparámetro, sólo te
# como se fitean los modelos que discutimos en clase.

library(MASS)
data("mcycle") # Ripley (2002): "Modern Applied Statistics with S-PLUS". Springer.
attach(mcycle)


par(mar= c(4,4,1,1))
plot(mcycle, pch = 20, col = rgb(red = 0, green = 0, blue = 0, alpha = 0.7))

head(mcycle,5) # Primeras 5 filas del data set.
dim(mcycle)

### 1) Regresión con bases de polinomios:
# La función poly(datos, grado, raw = T) contruye la matriz de diseño.
head(poly(times,3,raw=TRUE), 5) # Te muestro solo las primeras 5 filas.
                                  #times: la covariable que quiero transformar
                                    #3: el grado del polinomio q quiero a las covariables (tiempo, tiempo al cuadrado, tiempo al cubo)
                                      #raw=TRUE: si quiero q la base sean ortonomalizads o no
          
poly9 = lm(accel ~ poly(times,9,raw=TRUE), data = mcycle ) # crea la matriz de diseño

summary(poly9)

points(times, poly9$fitted.values, type='l', lwd = 4, lty = 2, col = rgb(red = 0, green = 0, blue = 1, alpha = 0.4))
# Podrías separar los datos en train y validación y aprender el grado polinomial.


# Regression lineal "local" (como en las slides):
pred1 <- predict(lm(accel ~ times, 
                    data = mcycle[mcycle$times <=15,]))
pred2 <- predict(lm(accel ~ times, 
                    data = mcycle[mcycle$times > 15 & mcycle$times <= 22,]))
pred3 <- predict(lm(accel ~ times, 
                    data = mcycle[mcycle$times > 22 & mcycle$times <= 35,]))
pred4 <- predict(lm(accel ~ times, 
                    data = mcycle[mcycle$times > 35 & mcycle$times <= 50,]))
pred5 <- predict(lm(accel ~ times, 
                    data = mcycle[mcycle$times > 50,]))
points(mcycle[mcycle$times <=15,1] , pred1, type='l', col = rgb(red = 1, green = 0, blue = 0, alpha = 0.4) , lwd = 4, lty = 2)
points(mcycle[mcycle$times > 15 & mcycle$times <= 22,1] , pred2, type='l', col = rgb(red = 1, green = 0, blue = 0, alpha = 0.4) , lwd = 4, lty = 2)
points(mcycle[mcycle$times > 22 & mcycle$times <= 35,1] , pred3, type='l', col = rgb(red = 1, green = 0, blue = 0, alpha = 0.4) , lwd = 4, lty = 2)
points(mcycle[mcycle$times > 35 & mcycle$times <= 50,1] , pred4, type='l', col = rgb(red = 1, green = 0, blue = 0, alpha = 0.4) , lwd = 4, lty = 2)
points(mcycle[mcycle$times > 50,1]                      , pred5, type='l', col = rgb(red = 1, green = 0, blue = 0, alpha = 0.4) , lwd = 4, lty = 2)

# No puedo escribir el modelo como un modelo aditivo, y me gustaría que mi función de regresión sea continua (y/o diferenciable).

### 2) Piecewise regression: ##no lo vimos en clase
I((times-15)*(times>=15)) # phi_2(x) = (x - 15)_+ (nu = 15, como en la slide 19)

piec.reg = lm(accel ~ times + I((times-15)*(times>=15)) + I((times-22)*(times>=22)) +
                              I((times-35)*(times>=35)) + I((times-50)*(times>=50)) , data = mcycle) 

summary(piec.reg)

points(times, piec.reg$fitted.values, type='l', col = rgb(red = 0, green = 1, blue = 0, alpha = 0.4) , lwd = 4, lty = 2)

### 3) Splines
#install.packages('splines')
library(splines)
nodos = c(15,22,35,50) # 
head(bs(times, knots = nodos ,degree = 3)) # Con digree controlo la cantidad de derivadas continuas de la función de regresión.

head(bs(times, df = 7 ,degree = 3)) # con df colocamos df - 3 nodos utilizando los cuantiles de empiricos de la coordenada.
                                    # En este caso cuantiles 20, 40, 60 y 80 (df - degree = 4 = cantidad de nodos)

spline = lm(accel ~ bs(times, knots = nodos ,degree = 3), data = mcycle)

par(mar= c(4,4,1,1))
plot(mcycle, pch = 20, col = rgb(red = 0, green = 0, blue = 0, alpha = 0.7))
points(times,spline$fitted.values, type='l', col='brown' , lwd = 4, lty = 2 ,main = '')

### 4) Natural splines: Metemos algunas restricciones en el modelo para que
###                     en "los bordes" éste se comporte de forma lineal.
head(ns(times, knots = nodos))

nat.splines <- lm(accel ~ ns(times, knots = nodos), data = mcycle)

summary(nat.splines) # Parámetros del modelo.

points(times,nat.splines$fitted.values, type='l', 
       col='orange' , lwd = 4, lty = 2 ,main = '') # La función de estimada de regresión se comporta de forma lineal en los bordes.
############################################ END.

# Apéndice
# Una gráfica con un poco más de estilo :)
library(ggplot2)
ggplot(mcycle, aes(x=times, y=accel)) +
  geom_point(alpha=0.55, color="black") + 
  stat_smooth(method = "lm", 
              formula = y~poly(x,9), 
              lty = 1, col = "blue") + 
  stat_smooth(method = "lm", 
              formula = y~bs(x,knots = nodos), 
              lty = 1, col = "brown") + 
  stat_smooth(method = "lm", 
              formula = y~ns(x,knots = nodos), 
              lty = 1, col = "orange")  +
theme_minimal()