rm(list=ls()); dev.off()
# ------------- Splines multivariantes y selección de modelos -------------#
# Datos: https://archive.ics.uci.edu/ml/datasets/Wine+Quality
datos = read.table('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 3, 4 y 5/Datos/winequality-white.csv',sep=';',
                    header=T,dec='.',na.strings = "")

head(datos,2)

require(psych) || install.packages('psych'); library(psych)
x11()
pairs.panels(datos[,c(5,6,11,12)], cex = 1, method = "pearson", hist.col = "#00AFBB",
             smooth = TRUE, density = TRUE, ellipses = FALSE )
# 'chlorides' y 'free.sulfur.dioxide' relacionados de forma no lineal con 'quality'

library(splines)
# A modo de benchmark consideremos el modelo:
set.seed(1)
train.id = sample(4898,3000) 
reg.splines=lm(quality~alcohol+bs(chlorides, df = 5) +  
                               bs(free.sulfur.dioxide, df = 5),
               data = datos, 
               subset = train.id, 
               weights = rep(1,4898) # Los datos atípicos pueden tener menor peso en la función de RSS.
               )
summary(reg.splines)

pred.qlty = predict(reg.splines, newdata = datos[-train.id,])
sum((pred.qlty - datos$quality[-train.id])^2)/1898# ecm estimado de 0.8073 sobre validación.


# Elegimos "df" por validación cruzada (discutimos otros métodos más eficientes en breve)

valores.df = c(3,4,5,6) # 0 nodos (reg pol), 1, 2 y 3 nodos respectivamente.
ecm.valores.df = c()
for(i in 1:4){
reg.splines=lm(quality~alcohol+bs(chlorides, df=valores.df[i])
                              +bs(free.sulfur.dioxide, df=valores.df[i]),
                 data = datos, subset = train.id, weights = rep(1,4898))
  
pred.qlty         = predict(reg.splines, newdata = datos[-train.id,])
ecm.valores.df[i] =  sum( (pred.qlty - datos$quality[-train.id])^2 ) /1898# estimación del ecm.
}

#x11()
plot(valores.df, ecm.valores.df, type = 'b', main = 'ECM estimado')

reg.splines=lm(quality~alcohol+bs(chlorides, df = 4) +  
                 bs(free.sulfur.dioxide, df = 4),
               data = datos, 
               subset = train.id)

pred.qlty = predict(reg.splines, newdata = datos[-train.id,])
sum( (pred.qlty - datos$quality[-train.id])^2 )/1898# ecm pasa de 0.80 a 0.57
#------------------------------------------------------------------------- End.


# Apéndice:
#@ Si necesitas construír la matriz de diseño para 
#  modelos aditivos polinomiales o de splines haces:

grado = 3
datos2 = data.frame(lapply(datos[,-12], 
                   function(i) poly(i, degree = grado, raw=T)[,1:grado])) 
dim(datos2); # de 11 features pasamos a 33 features.
head(datos2,3)

# datos2 tiene todos los features originales y éstos elevados al cuadrado.
# Para el caso de splines procedes de la misma manera.