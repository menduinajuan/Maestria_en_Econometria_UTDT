# -------- Pipeline para implementar svm's en R -------------------------------#
rm(list=ls()); dev.off()
###########################################################
require(e1071) || install.packages('e1071');library(e1071)#
###########################################################

setwd('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 8/Datos')
datos = read.table(file='CellPhones.csv',header = T, sep=',', dec='.')
head(datos,3)
dim(datos) # 2000 observaciones y 21 features (toy example).

str(datos) # Diccionario de variables:
# battery_power: Total energy a battery can store in one time measured in mAh
# blue: Has bluetooth or not
# clock_speed: speed at which microprocessor executes instructions
# dual_sim: Has dual sim support or not
# fc: Front Camera mega pixels
# four_g: Has 4G or not
# int_memory: Internal Memory in Gigabytes
# m_dep: Mobile Depth in cm
# mobile_wt: Weight of mobile phone
# n_cores: Number of cores of processor
# pc: Primary Camera mega pixels
# px_height: Pixel Resolution Height
# px_width: Pixel Resolution Width
#ram: Random Access Memory in Mega Bytes
# sc_h: Screen Height of mobile in cm
# sc_w: Screen Width of mobile in cm
# talk_time: longest time that a single battery charge will last when you are
# three_g: Has 3G or not
# touch_screen: Has touch screen or not
# wifi: Has wifi or not
# price_range: 0(low cost), 1(medium cost), 2(high cost) and 3(very high cost).

#@1: Analisis Descriptivo mínimo y data pre-proc: 
# Simplifico el problema de clasificación a un problema binario (para simplificar la exposición) 
y_target = as.factor(ifelse(datos[ ,21 ]<=1,'bajo','alto'))
head(y_target,3)

### Variables categóricas en columnas 2,4,6,18,19,20: blue, dual_sim, four_g+three_g, touch_screen y wifi.
install.packages("corrplot")
library(corrplot)
M<-cor(datos[ ,-c(2,4,6,18:21) ])
head(round(M,2))
x11();corrplot(M, method="circle") # <- El modelo no tiene problema para gestionar variables altamente colineales.

# Alternativas al one-hot-encoding para las variables categóricas:
head(datos[ ,c(2,4,6,18:20) ],2) 

x_comb = rowSums(datos[ ,c(2,4,6,18:20) ]) # x_comb da cuenta de la cantidad de atributos del teléfono.
head(x_comb, 3)

x11(); hist(x_comb)                        # Este 'feature' va a sustituír a los features de las columnas 2,4,6,18 a 20 (variables cuali).

#### Alternativamente damos pesos diferentes a cada uno de los features al crear 'x_comb':
# En vez de darles el mismo peso a cada covariable, aprender pesos utilizando      ###
# un modelo de regresion logística 'auxiliar' (datos de train)                     ###
#attach(datos); set.seed(1)                                                        ###
#samp=sample(2000,1500) # id de las filas de train (ver más abajo)                 ###
#reglin.aux = glm(as.factor(ifelse(price_range<=1,'bajo','alto')) ~ blue+dual_sim+ ###
#                                                four_g+three_g+touch_screen+wifi, ###
#                 family = 'binomial',subset = samp) #################################                                            
#x_comb = predict(reglin.aux, newdata = datos, type = 'link') # odd-ratios         ###
#head(x_comb, 3); x11(); hist(x_comb)                                              ###
######################################################################################

# Reorganizamos data quitando features cualitativos y agregando el nuevo target binario:
datos2 = datos[ ,-c(2,4,6,18:21)]      # Quito covariables que no voy a usar.
datos2 = cbind(datos2,x_comb,y_target) # Agrego covariables que voy a usar.
head(datos2, 3) # Notar que todos los features son continuos (la variable de respuesta es obviamente categórica).

# Finalmente particionamos en TRAIN & TEST:
set.seed(1); id.train=sample(2000,1500)

#@2: Fiting de modelo benchmark y selección de modelo con datos de train: 
# LIBSVM: https://www.csie.ntu.edu.tw/~cjlin/papers/guide/guide.pdf # <- Detalles muy técnicos sobre lo que hace la librería en cuestión.
set.seed(1)
svm.bench <-  svm(y_target ~ ., 
               data = datos2,
               subset = id.train,
               type = 'C-classification', # Si "y" es factor "C-class" método por defecto.
               kernel = "linear",         # Support Vector Classifier.
               cost = 0.01,               # Parámetro C (ver efectos en slide 19)
               cross = 10,                # Estima el error por VC
               scale = TRUE)              # Recomendable escalar los features para acelerar el fitting.

summary(svm.bench) #566 vectores soportes

head(svm.bench$SV, 3) # coordenadas de losvectores soporte (slide 14)

head(svm.bench$fitted,3)  # Predicciones sobre la muestra de entrenamiento (ver "R(x_new)" en Slide 8)

svm.bench$accuracies # Tasas de acierto estimada en cada fold.

svm.bench$tot.accuracy # Tasas de acierto global estimada por VC.

pred.out = predict(svm.bench, newdata = datos2[-id.train,]) # Predicciones sobre test.
table(pred.out, datos2$y_target[-id.train]) # Te = 2.8% # <- Error que hubieras alcanzado si seleccionaste este modelo.

### Vamos a intentar optimizar los hiper-parámetros sensibles del modelo: 
# Selección de modelo (VC sobre el parámetro "C")
set.seed(1)
c.param = 2^(-1:5); c.param
tune.out <- tune.svm(y_target ~ ., 
                     data = datos2[id.train,],
                     cross = 5,       # Cantidad de folds.
                     kernel = "linear",  
                     cost=c.param ,  # Grilla de valores para "C".
                     scale = TRUE)

summary(tune.out) # <- Difícil performar mucho mejor mejor que le benchmark.

x11(); plot(tune.out) 

summary(tune.out$best.model) # C* = 1

svm.optim <- svm(y_target ~ ., 
               data = datos2,
               subset = id.train,
               kernel = "linear", 
               cost = 1, # C* 
               scale = TRUE)
##-------------------------------------- Fin de la etapa de selección de modelo.

#@3: Estimación del error del modelo seleccionado sobre test: 
pred.out = predict(svm.optim, newdata = datos2[-id.train,]) # Predicciones sobre test.
table(pred.out, datos2$y_target[-id.train]) # Te = 1.4% # Ojo, son muy poquitos datos.
####### ---------------------------------- ----------- End.