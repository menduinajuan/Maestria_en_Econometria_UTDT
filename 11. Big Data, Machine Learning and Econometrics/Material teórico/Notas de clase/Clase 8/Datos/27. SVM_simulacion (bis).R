# -------- otra simulación para demostrar la potencia del modelo a la hora de
#          capturar patronaes no lineales en los datos               --------#
rm(list = ls())
################################################################################
library(ggplot2)
library(caret)

N = 500; K = 4; D = 2 # Dimensión de los datos.
X <- data.frame() # coordenadas de los features. 
y <- data.frame() # Categorías de la respuesta.

set.seed(1)
for (j in (1:K)){
  r <- seq(0.05,1,length.out = N) # rad
  t <- seq((j-1)*4.7,j*4.7, length.out = N) + rnorm(N, sd = 0.3) 
  Xtemp <- data.frame(x =r*sin(t) , y = r*cos(t)) 
  ytemp <- data.frame(matrix(j, N, 1))
  X <- rbind(X, Xtemp)
  y <- rbind(y, ytemp)
}

data <- cbind(X,y)
colnames(data) <- c('X1','X2', 'y')
data$y = as.factor(ifelse(data$y==1|data$y==3,1,2))
x11()
plot(data[,1],data[,2], pch = 20, col = data[,3] , 
     main = 'datos en espiral', xlab = 'X1', ylab = 'X2')
head(data,2)

################### Fitting SVM con Kernel Gaussiano:
library(e1071)

svmfit <- svm(y~., 
              data = data, 
              kernel = "radial", 
              gamma = 1,  #sigma en las slides.       
              cost = 1)   # C en las slides.        
svmfit
x11()
plot(svmfit, data) # Pifiamos un poco en el centro (x1 = 0, x2 = 0).
                   # El modelo (2 hiperparámetros) logra divir en dos el espacio  
                   # de features a través de una función no lineal en (X1,X2).

### VC de los dos hiper-parámetros sensibles del modelo:
tune.out <- tune.svm(y~., 
                     data = data, 
                     kernel = "radial",   # Kernel Gausiano. 
                     gamma = c(0.1,1,10), # valores para 'sigma'        
                     cost=2^(-1:2) ,      # Valores para 'C'
                     scale = TRUE) 

# Notar que computacionalmente al modelo le cuesta escalar en "n".
summary(tune.out)

tune.out$best.parameters 

x11()
plot(tune.out)

# Una vez estimados gamma* y C*
svmfit <- svm(y~., 
              data = data, 
              kernel = "radial", 
              gamma = 10,  #gamma*       
              cost = 1)    #C*        

x11()
plot(svmfit, data)
#-------------------------------------------------------------------------- END.