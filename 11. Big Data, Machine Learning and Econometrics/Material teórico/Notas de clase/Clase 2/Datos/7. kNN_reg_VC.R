################# kNN en R: https://cran.r-project.org/web/packages/FNN/FNN.pdf
# install.packages('FNN'); 
library(FNN)
###############################################################################
##### 1) Simulando los datos de entrenamiento:
f <- function(X){sin(2*X) + sqrt(X)}
X = seq(0,4*pi,length.out = 200)
set.seed(1) # Fijamos la semilla para que todos tengamos el mismo data set.
Y =  f(X) + rnorm(200)

par(mar=c(4,4,1,1))
plot(X,f(X), type = 'l',ylab='f(X)',
     ylim = c(-3,6),bty='n', lwd = 3, lty = 1)
points(X,Y, pch = 20)


####################################################################
### Validation set approach ########################################
####################################################################
datos = cbind(X,Y)

set.seed(1)
id.train = sample(200,100, replace = FALSE) # que es id.train?

train = datos[ id.train, ] # <- indica que filas de Train selecciono para train.
dim(train)
head(train)

val  = datos[-id.train,]
dim(val)

k.par = c(1,5,10,20,50,80)
MSE = c() # Aquí guardo el error cuadrático medio fuera de la muestra.
for(i in 1:6){
kNNreg = knn.reg(train = as.matrix(train[,1]) ,
                  y = as.matrix(train[,2]),
                  test = as.matrix(val[,1]),
                  k = k.par[i])
pred = kNNreg$pred
MSE[i] = sum( (pred - val[,2])^2 ) / 100 
print(i)
}

cbind(k.par, MSE)

which(MSE == min(MSE))

k.par[which(MSE == min(MSE))] # k-óptimo estimado por VC: Val-Set app.

plot(k.par, MSE, type = 'b', xlab = 'k', ylab = 'Estimación MSE', 
     ylim=c(0.8,2), lwd = 2, pch = 20)
# El valor estimado como adecuado para $k$ es 10.
################ End Validation-Set app.

####################################################################
### LOOCV                   ########################################
####################################################################
MSE = c() # Aquí guardo el error cuadrático medio fuera de la muestra.
sd = c()
for(i in 1:6){
 mse = c() # Aquí guardo el ecm sobre cada muestra de validación.
    for(j in 1:200){
    train = matrix(datos[ -j,], ncol = 2)
    val   = matrix(datos[  j,], ncol = 2)
    
    kNNreg = knn.reg(train = as.matrix(train[,1]) ,
                   y = as.matrix(train[,2]),
                   test = as.matrix(val[,1]),
                   k = k.par[i])
  mse[j] = (kNNreg$pred - val[,2])^2   
       } # end for  en "j"
 
MSE[i] = mean(mse) 
sd[i] = sd(mse)
print(i)} # end for en "i"

cbind(k.par, MSE, sd)

k.par[which(MSE == min(MSE))] # k = 10

points(k.par, MSE, type = 'b', col = 'red', lwd = 2, pch = 20)
# El valor estimado como adecuado para $k$ es 10.
################ End LOOCV.

####################################################################
### B-fold CV               ########################################
####################################################################
n = 200; B = 5
folds <- cut(seq(1,n),breaks=B,labels=FALSE)
folds # Indicador de cada uno de los folds

set.seed(321) # Permuto las observaciones en cada fold.
folds = folds[sample(200,200)]
folds # table(folds)

MSE = c()  # Aquí guardo el error cuadrático medio para cada valor de k.
se  = c()  # Aquí guardo el error estandard para cada valor de k.
for(i in 1:6){ # i recorre los valores del parámetro "k" (ver "k.par[i]" más abajo).
  mse.b = c()      # Vector auxiliar en donde iré guardando el ecm para cada valor de k en cada fold de validación.
  for(j in 1:B){ # j-recorre los folds
    index.train = which(folds!=j) # selecciono observaciones que hacen de train.
    index.val   = which(folds==j) # selecciono observaciones que hacen de validación.
    train = matrix(datos[ index.train,], ncol = 2)
    val   = matrix(datos[ index.val  ,], ncol = 2) # mirar esquema de la diapo 30.
    
    kNNreg = knn.reg(train = as.matrix(train[,1]) ,
                     y = as.matrix(train[,2]),
                     test = as.matrix(val[,1]),
                     k = k.par[i]) # El primer bucle for va cambiando los valores de "k".
    mse.b[j] = sum( (kNNreg$pred - val[,2])^2 ) / 40  
    
  }
MSE[i] = mean(mse.b); 
se[i]  = sd(mse.b);
print(i)  
}

cbind(k.par, MSE, se)

k.par[which(MSE == min(MSE))] # k = 10 

points(k.par,MSE ,type='b', col = 'blue', lwd = 2, pch = 20) #
################################################################################
# Conc: Los datos sugieren elegir un valor de K en el intervalo [10,20].  ######
########################################################################### FIN.