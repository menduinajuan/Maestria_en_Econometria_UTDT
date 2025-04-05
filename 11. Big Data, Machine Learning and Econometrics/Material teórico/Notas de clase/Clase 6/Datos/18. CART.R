rm(list=ls())
#### Paquetes y librerias a instalar y cargar:########
require(rpart) || install.packages('rpart')###########
require(ROCR)  || install.packages('ROCR') ###########
######################################################
library(rpart); library(ROCR)
setwd('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 6/Datos')

# --------------------- Caso de estudio en Regresión -------------------------#
#### Utilizaremos VC para ajustar un 'arbol de reg o clasific.
load('Hitters2.RData')
head(Hitters2); dim(Hitters2)
# Descriptivo: ISL 6.5 (pp~244) & 8.1 (pp~304)
attach(Hitters2)

# Obejtivo: Predecir el salario en función de la performence histórica.
x11()
par(mfrow=c(1,3)) # Para simplificar solo utilizamos estas 3 variables.
plot(Hits, Salary)
plot(Years, Salary)
plot(HmRun, Salary)
# Solo hacemos selección de modelos (No hay conjunto de TEST)

set.seed(1)
salary.mod <- rpart(Salary ~ Hits + Years + HmRun,
                    method='anova', 
                    data = Hitters2,
                    control = rpart.control(cp = 0.001,   # alfa más pequeño (determina el tamaño del árbol maximal) 
                                            minsplit = 10,# Cantidad mínima de observaciones en un nodo terminal. 
                                            xval = 5))   # cantidad de folds para VC (estimación de alfa*)

x11()
plot(salary.mod,uniform=T,branch=0.1,compress=T,margin=0.1,cex=.5)
text(salary.mod,all=T,use.n=T,cex=.7) # :(

#install.packages('rpart.plot') 
library(rpart.plot)
x11()
rpart.plot(salary.mod, type = 2, cex=0.75)

printcp(salary.mod) # alpha* (cp = 0.0423784)

x11()
plotcp(salary.mod)    # Param de complejidad vs error de prediccion (RSS/RSS_null)

salary.mod$variable.importance # Importancia de cada co-variable (slide )

salary.mod$variable.importance / sum(salary.mod$variable.importance) # Luego discutimos como se calcula.


salary.mod.prune = prune(salary.mod, cp = 0.0423784) # Seleccionamos el modelo adecuado de la secuencia M = {T_(n), T_(n-1)....}
x11() # Árbol "podado"
rpart.plot(salary.mod.prune, type = 2, cex=0.75)

#Predicciones en el conjunto de train (no hay otro conjunto de datos disponible):
pred.rpart = predict(salary.mod.prune,data=Hitters2,type='vector')

head(pred.rpart) # <- Predicciones sobre el conjunto de train.

# Métricas de evaluación (in sample):
# Error cuadrático medio
sum( (pred.rpart - Salary)^2 ) / 263

# Error absoluto medio
sum( abs(pred.rpart - Salary) ) / 263

# Error cuadrático relativo medio
sum( ( (pred.rpart - Salary)/Salary )^2 ) / 263
# Error absoluto relativo medio: (in sample pero con modelo estimado por VC)
sum( abs( (pred.rpart - Salary)/Salary ) ) / 263
################################################################# END.

# --------------------- Caso de estudio en Clasificación ---------------------#
rm(list = ls())
datos = read.table(file = 'data.csv', 
                   sep = ',', dec = '.', header = T,
                 na.strings = c("NA" , "" ), quote = '"'  )
dim(datos)

head(datos,3) # NA = 'missings' (tipico de datos de encuestas largas, ver diccionario de variables!).

# Una de las ventajas de los modelos CART respecto de los modelos 
# lineales es lo robusto que resultan a valores atípicos y el poco pre-proceso
# que necesitamos hacer sobre los datos para fitear el modelo. 
# Los datos faltantes en las variables categóricas pueden ser tratados como una "clase" en si misma o 
# gestionarse de acuerdo a diferentes criterios (imputación, métodos de subrogación, etc).

table(datos$Party)/5568 # 53% Democrats vs 47% Rep.
###########################################
set.seed(12345); train.id = sample(5568, 4568)
###########################################

set.seed(12345) 
arbol.Party = rpart(Party ~ ., 
                       data=datos,
                       subset = train.id,
                       method="class",                        # 'anova' para regresión.
                       parms = list( split = "gini"),         # Métrica con la que determinan los cortes.
                       control= rpart.control(minsplit = 100, # Cantidad minima de observaciones en nodo (antes de partir)
                                        xval = 5 ,            # cantidad de folds de validación
                                        cp = 0.001,           # Umbral de mejora mínima (equivale a "alpha" en escala [0,1]).
                                        maxdepth = 10,        # Longitud maxima del arbol.
                                        maxsurrogate = 5,
                                        usesurrogate = 2)     # ?rpart.control (https://www.rdocumentation.org/packages/rpart/versions/4.1.16/topics/rpart.control).
                    )
# La gráfica que por defecto da el paquete resulta un poco confusa:
x11()
plot(arbol.Party, uniform=F,branch = .5,compress = T,margin = 0.1,
     main="(incomprensible)")
text(arbol.Party, use.n=T, all=T, cex=.7)

# El paquete 'rpart.plot' produce outputs gráficos más organizados:
#install.packages('rpart.plot') 
library(rpart.plot)
# En c/nodo terminal: "Predicción", "hat(P(Y=Republicano))", % de datos 
x11()
rpart.plot(arbol.Party, type = 2, cex=0.75) # Q109244: ¿Are you a feminist?

summary(arbol.Party)
                     # 1) Tabla con los valores estimados por VC de la tasa de error relativo.
                     # 2) Importancia de cada variable.
                     # 3) Detalles de corte en cada nodo del árbol (analizar el primero).

# Modelos estimados para cada valor de 'cp':
printcp(arbol.Party)   # Resultados estimados por "xval=5" folds de VC

x11()
plotcp(arbol.Party)    # coeficiente de complejidad vs error relativo (VC)
                       # Nota: cp equivale a alpha en escala [0,1].

arbol.Party$variable.importance # Importancia de cada covariable (feature).

# Estimación por VC del tamaño optimo del árbol:

### Como "podar el árbol":
printcp(arbol.Party) # Elegimos el valor de cp (alpha) que minimiza el error 
                     # estimado por VC (columna xerror).

arbol.Party.podado = prune(arbol.Party,cp = 0.0066187 ) # "alpha' optimo depende de la VC.
x11()
rpart.plot(arbol.Party.podado, type = 2 ) # Revisar el diccionario de variables.

# Predicciones (in sample) con el árbol podado:
pred.acp = predict(arbol.Party.podado, type='class')
head(pred.acp,3)
#@@@ con type='prob' devuelve probabilidades (luego vos cambias el umbral)

# Matriz de Confusion (datos de train):
table(pred.acp,datos$Party[train.id])

1-sum(diag(table(pred.acp,datos$Party[train.id])))/4568
#T.Error = 37% (approx) 

# Curva ROC
library(ROCR)
pred.acp = predict(arbol.Party.podado, type='prob')
### Primero obtenemos las propabilidades a posteriori, luego:
pred2 <- prediction(pred.acp[,2], datos$Party[train.id])
perf2 <- performance(pred2,"tpr","fpr")
auc <- performance(pred2,"auc")                                                        #####
as.numeric(auc@y.values) 

x11()
plot(perf2, main="Curva ROC (in-sample) Árbol", colorize=T)
legend(0.5,0.2, paste(' AUC = ',round(as.numeric(auc@y.values),3)),
       cex=1,box.col='transparent',border='transparent')

########################################################################
####### Validando el modelo con el conjunto de Test:   #################
########################################################################
pred.Party.Test = predict(arbol.Party.podado, newdata=datos[-train.id,] ,type='class')
head(pred.Party.Test)


table(pred.Party.Test,datos[-train.id,]$Party)

1-sum(diag(table(pred.Party.Test,datos[-train.id,]$Party)))/1000
# Tasa de Error en Test 38% (próxima clase vemos como mejorar estos resultados).
####################################################################################### END.