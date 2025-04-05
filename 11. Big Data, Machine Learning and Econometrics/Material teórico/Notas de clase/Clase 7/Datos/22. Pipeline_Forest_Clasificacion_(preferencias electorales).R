rm(list=ls())
#------------------ Random Forest  ---------------------#

require(randomForest) || install.packages('randomForest')#
setwd('G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/11. Big Data, Machine Learning and Econometrics/Material teórico/Notas de clase/Clase 7/Datos')
datos = read.table(file = 'encuesta.txt', sep = ',', dec = '.', header = T)
head(datos, 3) # Ver diccionario de variables en campus.

datos$Party = as.factor(datos$Party) # formato RandomForest para clasificación. 

set.seed(321)
id.train = sample(5568, 4568) 
###@ Brief: Sobre test CART tiene un error de 38% y Baggin 33%.

# ?randomForest
forest.bench = randomForest(Party~.,
                          data=datos[id.train,],
                          mtry =  10, # m = 10 (si m = cantidad features entonces estamos haciendo Bagging)
                          ntree=500,                  # B
                          sample = 3000, # tamaño de cada re-muestra bootstrap.
                          maxnodes = 10,  # cantidad máxima de nodos terminales en c/ árbol.
                          nodesize = 150, # cantidad mínima de datos en nodo terminal.
                          importance=T,   # Computar importancia de c/ covariable.
 #                         proximity = T,    #computa la matriz de proximidad entre observaciones.
                          # na.action =  na.roughfix # imputa perdidos con mediana / moda. 
                          # na.action = rfImpute     # imputa perdidos con datos próximos.
                          # na.action = na.omit      # descarta valores perdidos. 
                          )

#@ Respecto del Fitting del modelo:
head(forest.bench$oob.times,3) # nro de veces q c/obs quedó out-of-bag. 
head(forest.bench$votes,3)     # (OOB)

head(forest.bench$predicted,3) # (ídem pero catagorías).
forest.bench$confusion         # Matriz de confusión (OOB)

# Performance: (estimaciones OOB)
forest.bench # (888 + 610)/4586 = 32.8% (un poquito mejor que Bagging)

# Importancia de cada variable: (+ alto = más contribución).
# www.stat.berkeley.edu/~breiman/RandomForests/cc_home.htm#varimp
X11()
varImpPlot(forest.bench, main ='Importancia de cada feature')
#head(forest.bench$importance,5) # Misma info, en una tabla.

#### Matriz de similaridad: "proximity = T" (@Linea:24)
#dim(forest.bench$proximity) # Matriz de proximidades.
#MDSplot(forest.bench, fac=datos[id.train,6] , k = 2) # k = nro dim.
#####################################################

############### Sintonía fina de hiper-parámetros (OOB):
valores.m = c(20,50,100)      # valores de "m"
valores.maxnode = c(20,50,100)  # Complejidad de árboles en el bosque.
parametros = expand.grid(valores.m = valores.m,valores.maxnode = valores.maxnode) 
# En la práctica exploramos una grilla mucho más grande.
head(parametros,3) # Matriz de 12 filas x 2 columnas.

te = c() # Tasa de error estimada por OOB.
set.seed(1)
for(i in 1:dim(parametros)[1]){ # i recorre la grilla de parámetros.
    forest.oob  = randomForest(Party~.,
                              data=datos[id.train,],
                              mtry = parametros[i,1], # m
                              ntree=500,              # Mientras más grande, mejor.
                              sample = 3000,          # Tamaño de cada re-muestra bootstrap
                              maxnodes = parametros[i,2], # complejidad de cada árbol del bosque
                              nodesize = 150, 
                              proximity =F)  
  te[i] = 1 - sum(diag(forest.oob$confusion[,-3]))/4568
  print(i)
}

cbind(parametros,te) # Estimaciones de la TE por OOB.

which(min(te)==te)
parametros[5,] # m* = 50, maxnode* = 50 (estimaciones de mala calidad porque B es relativamente pequeño)

library("scatterplot3d"); x11()
scatterplot3d(cbind(parametros,te),type = "h", color = "blue")

# Re-entrenamaos con m* y maxnodes*:
set.seed(123)
modelo.final = randomForest(Party~.,
                            data=datos[id.train,],
                            mtry   = 50,     # m*
                            ntree  = 500,              
                            sample = 3000, 
                            maxnodes = 50, # complejidad*
                            nodesize = 150,
                            importance = F, 
                            proximity  = F
)  
##---- FIN de selección de modelo.

#### Extrapolamos como funcionaría el modelo seleccionado con el conjunto de test:
pred.rfor.test = predict(modelo.final,newdata=datos[-id.train,])
matriz.conf = table(pred.rfor.test,datos$Party[-id.train])
matriz.conf
1-sum(diag(matriz.conf))/1000 # 31.9% ;)
                              # vs Modelo CART 38% vs Bagging 33%
#------------------------------------------------------------ END.