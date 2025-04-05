################# kNN en R: https://cran.r-project.org/web/packages/FNN/FNN.pdf
# install.packages('FNN'); 
library(FNN)
################################################################################

##### 1) Simulando datos de entrenamiento:
library(MASS)
set.seed(123) # Fijamos la semilla para que todos tengamos el mismo data set.
X =  rbind(mvrnorm(50,c(-1,-1),diag(2)),mvrnorm(50,c(1,1),diag(2)))
dim(X)

Y =  factor(c(rep('A',50),rep('B',50) ))

par(mar=c(4,4,1,1))
plot(X, pch = 20, ylab=expression(X[2]),xlab=expression(X[1]),
     ylim = c(-4,4),xlim = c(-4,4),bty='n', col = c(rep('red',50),rep('blue',50)))

################################################################################
kNN.class = knn(train = X , test = X, cl = Y, k = 10, prob = TRUE)
# El output de la función knn esta bastante mal organizado.

kNN.class[1:100]    

attr(kNN.class,"prob") 

# Matriz de confusión:
mconf = table(kNN.class[1:100], Y)
print(mconf)
################ End clasificación.