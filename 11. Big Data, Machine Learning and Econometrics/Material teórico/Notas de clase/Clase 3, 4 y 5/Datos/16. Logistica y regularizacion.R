rm(list=ls()); dev.off()
# -- Pipeline: Regresión logística aditiva + regularización -------------------#
require(glmnet) || install.packages('glmnet'); library(glmnet)
require(ROCR)   || install.packages('ROCR')  ; library(ROCR) 

# Datos: https://archive.ics.uci.edu/ml/datasets/default+of+credit+card+clients
# Paper: https://bradzzz.gitbooks.io/ga-seattle-dsi/content/dsi/dsi_05_classification_databases/2.1-lesson/assets/datasets/DefaultCreditCardClients_yeh_2009.pdf
# Objetivo: Predecir que clientes van a caer en default el mes que viene. 

#- Cargamos datos y depuramos + feature engineering     -----------------------#
setwd('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 3, 4 y 5/Datos')
defaults = read.table('creditdefaults.csv',header = T, sep=',')

dim(defaults) # 30 mil datos y 24 variables.

str(defaults) # WARNING: sex, educ, marriage se cargaron cómo 'integer'.

# Diccionario de variables: (ver slide 18)
# LIMIT_BAL : Amount of the given credit (NT dollar): it includes both the individual consumer credit and his/her family (supplementary) credit.
# SEX:  (1 = male; 2 = female).
# EDUC: Education (1 = graduate school; 2 = university; 3 = high school; 4 = others).
# MARR: Marital status (1 = married; 2 = single; 3 = others).
# AGE: Age in year.
# PAY1 - PAY6:   History of past payment. We tracked the past monthly payment records (from April to September, 2005) as follows: P1 = the repayment status in September, 2005; P2 = the repayment status in August, 2005; . . .;P6 = the repayment status in April, 2005. The measurement scale for the repayment status is: -1 = pay duly; 1 = payment delay for one month; 2 = payment delay for two months; . . .; 8 = payment delay for eight months; 9 = payment delay for nine months and above.
# BILL1 - BILL6: Amount of bill statement (NT dollar). B1 = amount of bill statement in September, 2005; ... B6 = amount of bill statement in April, 2005.
# PAY_AMT1 - PAY_AMT6: Amount of previous payment (NT dollar). PA1 = amount paid in September, 2005; ... PA6 = amount paid in April, 2005.
# default_payment_next_month
table(defaults$default_payment_next_month) # 22% de la base son "Y=1"

# Recodificamos features categóricos como factores:
defaults$SEX       = as.factor(defaults$SEX)
defaults$EDUCATION = as.factor(defaults$EDUCATION)
defaults$MARRIAGE  = as.factor(defaults$MARRIAGE)


table(defaults$PAY1) # Status pago Sept 2005: No condice con la info del diccionario.
# Analizando la tabla, parece que cuando los clientes no usan la tarjeta (no corresp pagar nada)
# en estas columnas se coloca un "-2" (en vez de un "-1").

#@ Ejecutar 1 sola vez @#
defaults$PAY1 = ifelse(defaults$PAY1<0,-1,defaults$PAY1)
defaults$PAY2 = ifelse(defaults$PAY2<0,-1,defaults$PAY2)
defaults$PAY3 = ifelse(defaults$PAY3<0,-1,defaults$PAY3)
defaults$PAY4 = ifelse(defaults$PAY4<0,-1,defaults$PAY4)
defaults$PAY5 = ifelse(defaults$PAY5<0,-1,defaults$PAY5)
defaults$PAY6 = ifelse(defaults$PAY6<0,-1,defaults$PAY6)
table(defaults$PAY1)
#x11()
#barplot(table(defaults$PAY1))

x11() # <-¿Hay segmentos difertes de clientes en la BD? # Quitamos las tarjetas con límites muy altos del modelo?
boxplot(defaults$LIMIT_BAL~defaults$default_payment_next_month) 

table(defaults$default_payment_next_month,defaults$EDUC) 
barplot(table(defaults$default_payment_next_month,defaults$EDUC))

#@ En un contexto aplicado, ANTES de emepezar a modelizar, deberías hacer un
#@ análisis descriptivo más extenso para descartar atípicos, datos faltantes, etc.

#@ Ingeniería de atributos:
apalancamiento         =  defaults$BILL_AMT1/defaults$LIMIT_BAL 
head(apalancamiento, 3) # <- Mide el apalancamiento de cada cliente de tarjeta.

retrasos_acumulados_ultimos3 = pmax(defaults$PAY1,0)+pmax(defaults$PAY2,0)+pmax(defaults$PAY3,0)
head(retrasos_acumulados_ultimos3, 3)

#@ Ingeniería de atributos II: (Modelos aditivos en slide 14 y 15)
library(splines)
bs.lim   = bs(x=defaults$LIMIT_BAL, df = 8); head(bs.lim); dim(bs.lim)

bs.billamt1 = bs(x=defaults$BILL_AMT1, df = 8)
bs.billamt2 = bs(x=defaults$BILL_AMT2, df = 8)
bs.billamt3 = bs(x=defaults$BILL_AMT3, df = 8)
bs.billamt4 = bs(x=defaults$BILL_AMT4, df = 8)
bs.billamt5 = bs(x=defaults$BILL_AMT5, df = 8)
bs.billamt6 = bs(x=defaults$BILL_AMT6, df = 8)


grad.lib = 8
bs.payamt = data.frame(lapply(defaults[,c(18:23)], # col 18 a 23 se cooresp con PAYMENTAMT 
                           function(i) bs(i, df = grad.lib)[,1:grad.lib])) 
dim(bs.payamt); # todo junto en una sola línea de código.

defaults = cbind(defaults[,-c(1,12:23)],      # quito features que use con bs().
                 bs.lim, bs.billamt1 , bs.billamt2, # agrego los features correspondientes a bs()
                 bs.billamt3, bs.billamt4, bs.billamt5, 
                 bs.billamt6 , bs.payamt, 
                 apalancamiento,retrasos_acumulados_ultimos3) # Ingeniería de attrb 

dim(defaults) # 117 features ("p" grande, quizá tiene sentido 'regularizar'-- slide 15).

head(defaults,2) # la columna 11 contiene la variable a modelar.

# Para hacer regresión logística aditiva + regularización necesitamos que los datos esten en formato matriz (glmnet)
X <- model.matrix( ~ .-1, defaults[ , -11]) 
dim(X) # 124 features (one--hot encoding para los factores: Sexo, Educ y Marriage)

Y = as.matrix(defaults[, 11])

#- Separamos en TRAIN (selección y fitting) y TEST (estimación del 'error')            
set.seed(1) 
id.train = sample(30000,round(30000*0.5,0))

############################################################
##3- Comenzamos haciendo "selección de modelos" con lasso (idem para Ridge o ENets, ver slide 15)
set.seed(1)
grid.l = c(0.00001,0.01,0.05,1,5) # Deberías explorar una grilla más fina de parámetros.
cv.out = cv.glmnet(X[id.train, ], 
                   Y[id.train], 
                   family = 'binomial',     # Modelo de regresión logística.
                   weights = NULL,          # Ver slide 20 (Extensiones II)
                   type.measure="deviance", # Dev = -2*Verosimilitud (ver slide 8)
                   # type.measure="auc",    # Si queremos cross-validamos con el "AUC".
                   lambda = grid.l,         # con lambda = 0, hacemos regresión logística sin regularización.
                   alpha = 1,               # Lasso
                   nfolds = 5)

x11()
plot (cv.out) # La devianza y el auc son métricas que no dependen del umbral (el modelo seleccionado no dependerá del umbral)

# bestlam = cv.out$lambda.min
bestlam = cv.out$lambda.1se
bestlam # [1] lambda* = 0.01 (explora sobre una malla más amplia de valores para lambda entre 0 y 0.01).

# 3.2 Fiteamos el modelo seleccionado con todos los datos de train:
addtiv.logit.lasso = glmnet(x = X[id.train,] , y = Y[id.train],
                        family = 'binomial', 
                        alpha = 1,  
                        lambda = bestlam) #lambda*

pred = predict(addtiv.logit.lasso, 
               s = bestlam ,        # lambda = 0.01
               newx = X[id.train,], # Datos de Train 
               type = 'response') 

round(head(pred,5),3) # Predicciones sobre la muestra de train

#-----  Graficando ROC y calculando el AUC        -----------------------------#
pred2 <- prediction(pred, Y[id.train])                                     #####
perf <- performance(pred2,"tpr","fpr")                                     #####
x11(); plot(perf, main="Curva ROC", colorize=T) # Curva ROC datos train.   #####
auc <- performance(pred2,"auc")                                            #####
as.numeric(auc@y.values) # 0.76                                            #####
# https://ipa-tys.github.io/ROCR/articles/ROCR.html
#-------------------------------------------------------------------------------

round(head(pred,5),3) # ¿Qué umbral utilizo para clasificar?

# 3.3 Criterios para determinar el umbral (nu) con el que clasificamos:
# 3.3.1 Regla naive: Utilizo la prior estimada con los datos (ver slide 7):
table(Y[id.train])/15000*100

y_hat.train = as.numeric(pred>= 0.223) # Clasificamos con nu = 0.223 (prior estimada)
head(cbind(pred,y_hat.train),4) 

# Algunas métricas de performance in sample (para nu = 0.223): (VER SLIDE 9)
matriz.confusion = table(y_hat.train, Y[id.train]) 
matriz.confusion/15000*100

sum(diag(matriz.confusion))/sum(matriz.confusion)*100         # Acierto 
(1 - sum(diag(matriz.confusion))/sum(matriz.confusion))*100   # T. Error

TN = sum( (y_hat.train==0 & Y[id.train]==0 )) 
TN/sum(Y[id.train]==0)*100 # Especificidad =TN /N.

TP = sum( y_hat.train==1 & Y[id.train]==1 )
TP/sum(Y[id.train]==1)*100 # Sensitividad (o recall) baja.

FP = sum( y_hat.train == 1 & Y[id.train]==0 ) # False +
FN = sum( y_hat.train == 0 & Y[id.train]==1 ) # False -

prec = TP/(TP + FP); print(prec)

rec = TP/(TP + FN) ; print(rec)

F1 = 2*(prec*rec)/(prec + rec)*100 # (ver slide 9)
F1 # Recordar que F1 = 0 modelo muy malo vs F1 = 100 modelo muy bueno. 

# 3.3.2 Elijo "nu" maximizando el F_beta (beta = 1 o beta = 1.5?)
nu = seq(0.01,0.6,length.out = 100)
F1 = F1.5 =  c();
for(i in 1:100){
  y_hat.train = as.numeric(pred >= nu[i])
  TP = sum( y_hat.train == 1 & Y[id.train]==1 )    # True +
  FP = sum( y_hat.train == 1 & Y[id.train]==0 )    # False +
  FN = sum( y_hat.train == 0 & Y[id.train]==1 )    # False -
  TN = sum( y_hat.train == 0 & Y[id.train]==0 )    # TRUE -
  prec = TP/(TP + FP) ; rec = TP/(TP + FN)
  F1[i]   = 2*(prec*rec)/(prec + rec)*100
  F1.5[i] = (1+1.5^2)*(prec*rec)/(1.5^2*prec + rec)*100 # 
}
x11(); plot(nu, F1, type = 'b', main = expression(paste('Optimización del umbral (',nu,')')), pch = 20, xlab = expression(nu), ylim = c(0,70), ylab = 'Score F')

tresh.opt = nu[which(F1==max(F1))]; tresh.opt # nu > la probabilidad a priori!
abline(v = tresh.opt , col = 'red', lty = 2 )

points(nu, F1.5, type = 'b', pch = 20, col = 'gray') # Cuando beta crece, Fbeta le da más importancia a Precisión.
abline(v = nu[which(F1.5==max(F1.5))] , col = 'gray', lty = 2 )
tresh.opt = nu[which(F1.5==max(F1.5))]; tresh.opt  # Analiza que ocurre con las métricas de abajo cuando utilizas el F1.5 para clasificar (en particular que ocurre con la sensibilidad del modelo!)

# Fin de la etapa de selección de modelo y calibración del umbral.

#--- Cuantificando la calidad del modelo seleccionado y estimado sobre test:
pred.test = predict(addtiv.logit.lasso, 
               s = bestlam , 
               newx = X[-id.train,], # Sobre "test"
               type = 'response') 


round(head(pred.test,5),3)

y_hat.test = as.numeric(pred.test>= tresh.opt) # Thresh = 0.176 (para beta = 1.5).
head(y_hat.test) # Predicciones en base al tresh.opt = 0.176

# Métricas para valorar el modelo:
matriz.confusion = table(y_hat.test, Y[-id.train])
matriz.confusion/15000*100

sum(diag(matriz.confusion))/sum(matriz.confusion)*100         # Acierto (TA)
(1 - sum(diag(matriz.confusion))/sum(matriz.confusion))*100   # T. Error(TE)

TP = sum( y_hat.test==1 & Y[-id.train]==1 )
TP/sum(Y[-id.train]==1)*100 # Sensitividad o recall. <- bastante más alta! :)

TN = sum( (y_hat.test==0 & Y[-id.train]==0 )) 
TN/sum(Y[-id.train]==0)*100 # Especificidad =TN /N. <- precio que pagamos por tener alta sensitividad.

# Curva ROC y AUC computada con los datos de Test:
pred2 <- prediction(pred.test, Y[-id.train])
perf <- performance(pred2,"tpr","fpr")                                                 
plot(perf, main="Curva ROC", colorize=T) # Curva ROC datos test.                      
auc <- performance(pred2,"auc")                                                        
as.numeric(auc@y.values) # 0.75

#---------------------------------------------------------------- END
#### Tarea: Asumiendo que por cada falso "0" el banco pierde 5 unidades monetarias, y por 
#### cada falsos "1" el costo implícito promedio estimado es de 1 unidad monetaria  
#### luego la utilidad esperada del banco (estimada sobre test)
-5*FN - 1*FP + 1*TN # Cantidad que depende de "nu"
# Tarea: Re-estima el umbral optimo para el modelo de manera de maximizar la utilidad esperada del banco.