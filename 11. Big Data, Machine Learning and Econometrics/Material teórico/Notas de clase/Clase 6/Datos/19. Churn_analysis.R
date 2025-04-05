rm(list=ls())
Train = load(file='G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 6/Datos/churnTrain.Rdata') # Conjunto entrenamiento.
Test = load(file='G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 6/Datos/churnTest.Rdata')   # Conjunto test.

#################################################################
#### Checks iniciales:                                 ##########
#################################################################
dim(Train)  ### diemnsiones de cada uno del conjuntos 
dim(Test)

head(Train) ### primeras observaciones de la matriz de datos
attach(Train)  ### indexamos los nombres de las columnas de la matriz

variables=attributes(Train)$names # Nombre de las variables
class(Train); str(Train) # Lista de variables y tipo.

cat=c('state','area_code','international_plan','voice_mail_plan','churn')

numericas=c('number_vmail_messages','total_day_charge','total_eve_minutes',
            'total_eve_charge','total_night_minutes','total_night_charge',
            'total_intl_minutes','total_intl_charge')

int=c('number_vmail_messages','total_day_calls','total_eve_calls',
      'total_night_calls','total_intl_calls')


# Un par de Box plots para entender la naturaleza de las variables:
x11();
boxplot(Train[,int],
horizontal=TRUE,
names=c("V1","V2","V3","V4","V5"),
col=c("red","yellow","blue","green","gray"))


### Analisis Multivariante básico para visualizar las correlaciones:
######### Como visualizamos las correlaciones entre los datos?
### Scaterplots en una matriz
cov(Train[numericas])
x11();

plot(Train[numericas],pch='.')
plot(Train[int],pch='.')
#############################################################################