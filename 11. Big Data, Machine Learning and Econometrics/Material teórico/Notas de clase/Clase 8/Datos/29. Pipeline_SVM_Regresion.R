# -------- Pipeline para implementar svm's en R -------------------------------#
rm(list=ls()); dev.off()
###########################################################
require(e1071) || install.packages('e1071');library(e1071)#
###########################################################

setwd('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 8/Datos')
datos = read.table(file='insurance.csv',header = T, sep=',', dec='.')
head(datos,2)
# age: edad beneficiario de la póliza.
# sex: género declarado por el asegurado.
# bmi: índice de masa corporal .
# children: número de hijos cubiertos en la póliza.
# smoker: si quien contrata la póliza es fumador o no.
# region: lugar de residencia (1: northeast, 2: southeast, 3:southwest, y 4:northwest).
# charges: costos médicos de cada uno de los asegurados.
# insuranceclaim: Reclama gastos (1: SI y 0: NO).

# Nota: Omitimos insuranceclaim ('data leakage')

library(corrplot)
M<-cor(datos[ ,-c(2,5,6,8) ])
head(round(M,2))
x11()
corrplot(M, method="circle")

#@1: Data pre-proc: 
set.seed(1); train.id=sample(1338,1000) # Pocos datos.

# Alternativa al one-hot-encoding con los features categóricos:
mod.aux = lm(charges ~ sex + smoker + region , 
                       data = datos, 
                       subset = train.id) # <- Regresión lineal para darle un peso a cada variable (solo uso train). 
x_comb = predict(mod.aux, newdata = datos) # No hay 'data leakage' en la construcción de x_comb.
head(x_comb,3)

datos = cbind(datos[ ,-c(2,5,6,8) ],x_comb) # Reorganizo los datos (quito sex, smoker, y region y agrego x_comb)

head(datos,3); # Todos los features son continuos.

#@2: Selección de modelo (kernel gaussiano = regresión no lineal).
set.seed(1)
tune.out <- tune.svm(charges ~ ., 
                     data = datos[train.id, ],# Solo datos de train.   
                     type = 'eps-regression', # Por defecto cuando 'y' es numérica.
                     cross = 5, 
                     kernel = "radial",     # <- Regresión NO lineal con kernel gaussiano.
                     cost = c(2:5)^2 ,      # Posibles valores de 'C' (Slide 35)
                     gamma = c(0.1,1,5,10), # Posibles valores de 'sigma' (Slide 35)
                     # epsilon = 0.1, # epsilon (Slide 34): podrías también CValidar este hiperparámetro en el modelo.
                     scale = TRUE)

x11()
plot(tune.out)

summary(tune.out)

tune.out # gamma* = 0.1, C* = 25

svm.rad <- svm(charges ~ ., 
               data = datos,
               subset = train.id,
               type = 'eps-regression', 
               kernel = "radial", 
               cost = 25 ,  # C*
               gamma = 0.1, #gamma* 
               scale = TRUE,
               cross = 5)

svm.rad 

mean(svm.rad$MSE) # MSE estimado "in-sample" con 5 folds de VC.

#@3: Estimación de la performance que tendría el modelo seleccionado en el futuro:
pred.outsample = predict(svm.rad, newdata = datos[-train.id,])
sqrt( sum( (pred.outsample - datos$charges[-train.id])^2  ) / 338 ) # A comparar con redes en la próxima clase.
# En promedio el modelo pifia en 5468 dólares anuales el costo de cada asegurado.
### ----------------------------------------------------------------------- End.

#Apéndice: Algunos análisis gráficos.
x11() ; par(mfrow=c(1,2))
hist(pred.outsample)
plot(pred.outsample,datos$charges[-train.id], pch = 20, 
     xlab = 'Predicciones', ylab = 'Gastos reales en test')
# Al modelo le cuesta predecir 'los gastos altos'.