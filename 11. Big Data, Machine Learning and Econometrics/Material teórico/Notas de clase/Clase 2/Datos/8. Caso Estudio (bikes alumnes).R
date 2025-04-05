rm(list = ls()); dev.off()
# install.packages("FNN")
library(FNN)
datos = read.table('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 2/Datos/bikes.csv',
                   sep=',',header=T,dec='.',na.strings = "NA")
str(datos)
#### Diccionario de variables:
# instant: record index
# dteday : date
# season : season (1:winter, 2:spring, 3:summer, 4:fall)
# yr : year (0: 2011, 1:2012)
# mnth : month ( 1 to 12)
# holiday : weather day is holiday (1) or not (0).
# weekday : day of the week
# workingday : if day is neither weekend nor holiday is 1, otherwise is 0.
# weathersit: 
#1: Clear, Few clouds, Partly cloudy, Partly cloudy
# 2: Mist + Cloudy, Mist + Broken clouds, Mist + Few clouds, Mist
# 3: Light Snow, Light Rain + Thunderstorm + Scattered clouds, Light Rain + Scattered clouds
# 4: Heavy Rain + Ice Pallets + Thunderstorm + Mist, Snow + Fog
# temp : Normalized temperature in Celsius. The values are derived via (t-t_min)/(t_max-t_min), t_min=-8, t_max=+39 (only in hourly scale)
# atemp: Normalized feeling temperature in Celsius. The values are derived via (t-t_min)/(t_max-t_min), t_min=-16, t_max=+50 (only in hourly scale)
# hum: Normalized humidity. The values are divided to 100 (max)
# windspeed: Normalized wind speed. The values are divided to 67 (max)
# casual: count of casual users
# registered: count of registered users
# cnt: count of total rental bikes including both casual and registered

attach(datos) 

#@ Vamos a poner a competir dos modelos: Reg lin vs K-vecinos <- un solo feature "temp".
#@ Con TRAIN + VAL seleccionamos el mejor modelo (y sus eventuales hiperparámetros)
#@ Una vez que elegiste modelo, estimamos el error predictivo sobre TEST.


##### ETAPA I: Selección de Modelo:
########################################################
########## Validation set approach #####################
########################################################
# 1 Separar los datos en TRAIN, VALIDACIÓN y TEST:
n = length(cnt)
set.seed(1)
id <- sample(1:3,size=n,replace=TRUE,prob=c(0.6,0.3,0.1))
table(id)

# TRAIN
train.X = matrix(datos[id==1,c(10)],ncol=1) # Solo uso "temp" como 'regresor' (con Delfina resuelven el caso completo).
train.Y = matrix(datos[id==1,c(16)],ncol=1)   

# VALID
val.X = matrix(datos[id==2,c(10)],ncol=1)
val.Y = matrix(datos[id==2,c(16)],ncol=1)   

# TEST
test.X = matrix(datos[id==3,c(10)],ncol=1)   
test.Y = matrix(datos[id==3,c(16)],ncol=1) 

#@@@ Benchmark:
reglin = lm(cnt~temp, data = datos, subset = which(id!=3)) # Estimamos con Train+validación (no hacemos selección de modelo).  
summary(reglin) 

help(predict)
predict(reglin, newdata = data.frame(temp = test.X)) # Estimar el ECM con el conjunto de test.