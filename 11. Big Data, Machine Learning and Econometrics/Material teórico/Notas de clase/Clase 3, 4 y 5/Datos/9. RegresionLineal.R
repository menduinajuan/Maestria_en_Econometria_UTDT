# -------------           Regresión lineal en R          -------------#
rm(list=ls()); dev.off()
setwd('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 3, 4 y 5/Datos')
datos = read.table('winequality-white.csv',sep=';',header=T,dec='.',na.strings = "")

### Chequeo mínimo de la información levantada:
str(datos) # Target: 'quality'.

head(datos, 2)

dim(datos)

### Una idea de la distribución conjunta de las variables
x11()
pairs(~.,data=datos, main="", pch='.', col='black')
cor(datos) # Una primera idea de como impacta cada covariable en la (percepción de la) calidad.

x11()
boxplot(datos$density) # Algunos features presentan instancias atípicas (pueden afectar de forma considerable las estimaciones de los parámetros)

# Descriptiva e histograma de la variable a modelar:
summary(datos$quality); 
barplot(table(datos$quality), xlab = 'Calidad', main = '')

############## TRAIN - TEST data sets.
set.seed(1)
id.train <- sample(dim(datos)[1], 3500) 

# Regresion lineal (benchmark):
reg.lin.bench = lm(quality ~ .,  
                   data = datos, 
                   subset =  id.train) # con 'subset' evitamos duplicar información en la memoria.
summary(reg.lin.bench) 
plot(reg.lin.bench) # <- 'analizando visualmente la bondad de ajuste del modelo' 



x11()
par(mar = c(4,5,1,1))
plot(datos$quality[id.train],reg.lin.bench$fitted.values, 
     pch=20, xlab='quality (Y)', 
     ylab= expression(paste('Predicciones (',hat(Y),')'),sep=''),
     xlim=c(1,10),ylim=c(1,10))

AIC(reg.lin.bench) # <- Slide 43 y https://en.wikipedia.org/wiki/Akaike_information_criterion.
BIC(reg.lin.bench) # <- Slide 43 y https://en.wikipedia.org/wiki/Bayesian_information_criterion


### Sobre el fiting (in sample) de los modelos:
# Cuantificando incertidumbre respecto de los parámetros
confint(reg.lin.bench) # Poco útil en el contexto del ML
#install.packages('car') <- Regiones (elipses) de confianza para pares de parámetros}
library(car); x11()
confidenceEllipse(reg.lin.bench, 
                  fill = T,
                  lwd = 0,
                  which.coef = c("sulphates", "alcohol"),
                  main = "Elipse de confianza (95%)",
                  levels = c(0.95) )

### Cuantificando incertidumbre respecto de las predicciones (interesante).
predict(reg.lin.bench, newdata = datos[1,-12],  interval="confidence") # Predicción puntual e intervalo para la calidad del primer vino del data set.


#### Cuantificando (estimando) la performance  de este modelo:
pred.test = predict(reg.lin.bench,newdata = datos[-id.train,-12]) # Predicciones puntuales en test.
head(pred.test, 3) # Predicciones para el conjunto de test.

pred.test = round(pred.test,0) 
head(pred.test, 3) # Alternativamente usamos modelos de conteo (GLM y regresión 'Poissoneana')

rss.out.sample = sum( (datos[-id.train,12] - pred.test)^2 ) / 1398
rss.out.sample # RSS = 0.653 sobre el conjunto de test.