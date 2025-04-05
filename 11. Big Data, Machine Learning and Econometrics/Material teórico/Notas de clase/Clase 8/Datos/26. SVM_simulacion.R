rm(list = ls())
################################################################################
# Simulemos datos como los de la slide 29 (y la Fig. 9.9 en ISL, pp 353): ######
set.seed(12345)                                                           ###### 
x <- matrix(rnorm(200*2), ncol = 2)                                       ######
x[1:100,] <- x[1:100,] + 2.5                                              ######
x[101:150,] <- x[101:150,] - 2.5                                          ######  
y <- c(rep(1,150), rep(2,50))                                             ######
dat <- data.frame(x=x,y=as.factor(y))                                     ######
                                                                          ######
library(ggplot2)                                                          ###### 
x11()                                                                     ######
ggplot(data = dat, aes(x = x.1, y = x.2, color = y)) +                    ###### # <- ver figura en slide 29
  geom_point(size = 2) +                                                  ######
  scale_color_manual(values=c("#00BFFF", "pink")) +                       ######
  theme(legend.position = "none")                                         ######
################################################################################ 
head(dat, 3)

library(e1071)
################### Fitting SVM con Kernel Gaussiano:
head(dat,3)
svmfit <- svm(y~., # como "y" es factor, hace por defecto type = "C-classification",
              data = dat, 
              kernel = "radial",   # Kernel Gausiano. 
              gamma = 10,          # Parámetro "sigma" del Kernel en las slides.
              cost = 10)           # Parámetro C en las slides.
svmfit
x11()
plot(svmfit, dat) # Modelo no lineal en el "input-space" (ver 30)
                  # Las cruces se corresponden con los datos que son vectores soporte.

### VC de los dos hiper-parámetros sensibles del modelo:
tune.out <- tune.svm(y~., 
                     data = dat, 
                     kernel = "radial",   # Kernel Gausiano. 
                     gamma = c(0.1,1,10), # valores para 'sigma'        
                     cost=2^(-1:2) ,      # Valores para 'C'
                     scale = TRUE)

summary(tune.out)

tune.out$best.parameters

x11()
plot(tune.out)


svmfit <- svm(y~., # como "y" es factor, hace por defecto type = "C-classification",
              data = dat, 
              kernel = "radial",   # Kernel Gausiano. 
              gamma = 1,          # Parámetro "sigma" del Kernel en las slides.
              cost = 0.5)           # Parámetro C en las slides.
x11(); plot(svmfit, dat)
# El resto de outputs y los procedimientos para hacer selección de modelos
# es equivalente a lo discutido en el ejemplo de "precios de celulares".
#-------------------------------------------------------------------------- END.

################################################################
##################Apéndice: SVM para problemas multiclase   ####
################################################################
x <- rbind(x, matrix(rnorm(50*2), ncol = 2))
y <- c(y, rep(0,50))
x[y==0,2] <- x[y==0,2] + 2.5
dat <- data.frame(x=x, y=as.factor(y))

x11()
ggplot(data = dat, aes(x = x.2, y = x.1, color = y, shape = y)) + 
  geom_point(size = 2) +
  scale_color_manual(values=c("#00BA00","#00BFFF","#8B008B")) +
  theme(legend.position = "none")

# La libreria e1071 transforma los problemas multicalse en varios problemas 
# binarios utilizando la estategia uno contra uno (ver slides de regresión logística).

svmfit <- svm(y~., 
              data = dat, 
              kernel = "radial", 
              cost = 10, 
              gamma = 1)
x11()
plot(svmfit, dat)

ypred <- predict(svmfit, dat)
(misclass <- table(predict = ypred, truth = dat$y))

##### Los parámtros "C" y "gamma" los tienes que 
##### estimar/aprender por VC (idem al contexto de clasificaci?n binaria).