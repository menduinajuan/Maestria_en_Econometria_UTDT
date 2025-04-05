# Vemos como implementar Ridge, Lasso y Enets con una simulación
library(MASS)
n = 1000

beta = c(1,-5,2,7,3,1,9,-2,-5)          # Valores de los parámetros en la población.
print(beta)

S = diag(length(beta)); S[2,1]=S[1,2] = 0.7; S[3,1]=S[1,3] = -0.5; 
print(S) # Generamos datos para (X_1,...,X_9) de una normal multivariante con esta matriz de covarianzas.
set.seed(1)
X = mvrnorm(n,rpois(9,5),S)             # Features relevantes.

Y = 1 + X%*%beta + rnorm(n,0,1.5)       # Generamos los valores de las respuestas.
X = cbind(X , matrix(runif(500*n),ncol = 500)) # Agrego 500 features que son ruido (p = 509)
dim(X) #n = 1000 observaciones y p = 509 variables (solo las primeras 9 son relevantes)

# Separamos en train y test (hacemos selección de modelo con 5 folds de VC sobre train)
set.seed(123)
id.train <- sample(n, 700)


library(glmnet) # https://glmnet.stanford.edu/index.html

### 1) Ridge:
grid.l =exp(seq(5 , -5 , length = 100)) # El paquete nos permite estimar varios modelos para diferentes valores de 'lambda'
x11();  # no cerrar.                           
plot(grid.l, type = 'b', ylab = expression(lambda), pch = 20) 

# Importante: Las covariables y la variable de respuesta deben ser introducidas en formato "matrix"
ridge.reg = glmnet(x = X[id.train,],  
                   y = Y[id.train] ,  
                   family = 'gaussian',  # modelo de regresión (Y continua).
                   alpha = 0 ,           # Ridge.
                   lambda = grid.l,      # Grilla para lambda.
                   weights = NULL,       # Si tenés datos atípicos, a estos datos les poder dar menos "peso" cuando aprendes los parámetros del modelo. Esta es una opción para evitar tener que quitar filas del data set o eliminar variables.
                   standardize = TRUE,   # Estandarizo covariables? ('TRUE' por defecto).
                   standardize.response = FALSE, #'FALSE' por defecto (no hace falta estandarizar Y en general).
                   intercept = TRUE,     # 'TURE' por defecto.
                   maxit =10000)         # Controlas la 'precisión' en la estimación de los parámetros del modelo.

dim(coef(ridge.reg))   
coef(ridge.reg)[1:5,1:3] # mirá la gráfica con valores de lambda.

# Los parámetros aprendidos se van achicando (SHRINK) conforme se incrementa 'lambda' (disminuye tau):
x11();par(mar = c(5,5,2,1))
plot(ridge.reg, xvar = "lambda", label = TRUE, xlab = expression(log(lambda)))


x11();# Algunos coeficientes pueden cambiar de 'signo' a lo largo del 'path'. 
par(mar = c(4,5,1,1))
matplot(log(grid.l),t(coef(ridge.reg)[2:10,]), type = 'l', lty = 1, lwd = 2, xlab = expression(log(lambda)),ylab = expression(hat(beta)(lambda)))
abline(h=c(0), col = 'gray', lty = 2, lwd = 2)


# Predicciones: Debes especificar un valor de lambda para hacer predicciones.
pred.l_0 <- predict(ridge.reg, s = 0 , newx = X[-id.train,]) # <- 's=0' Regresión Lineal!
head(pred.l_0) # Predicciones sobre test.

sum( (pred.l_0 - Y[-id.train])^2 )/300 # Benchmark (7.6).

# Aprendemos "lambda" por validación cruzada.

set.seed(1) # La librería glmnet implementa VC internamente.
cv.out = cv.glmnet(x = X[id.train,], 
                   y = Y[id.train ],  
                   lambda = grid.l, 
                   alpha = 0,       # Ridge. 
                   nfolds = 5)      
cv.out

x11()           
plot(cv.out)        

cv.out$lambda.min # lambda* (Primera linea vertical desde la izquierda. <- Modelo con menor RSS (estimado por VC))
cv.out$lambda.1se # Segunda linea vertical desde la izquierda. <- Modelo más parsimónico con un RSS (estimado por VC) a menos de 1sd del modelo anterior 

coef(ridge.reg)[,which(grid.l==cv.out$lambda.min)] # VALORES ESTIMADOS DE LOS PARÁMETROS del modelo asociado a lambda1sd.
# Nota: Todos los (parámetros estimados de) modelos entre estas dos líneas verticales son 'estadísticamente' equivalentes en un sentido predictivo.
#       Mientras más grande sea 'lambda' más regularizado (parsimónico) resulta el modelo, por este motivo a veces se elige el valor el lambda de la 'línea punteada derecha'
#      ("Las diferencias en el ECM estimados de todos los modelos entre ambas líneas verticales no son estadísticamente signigicativas")

bestlam = cv.out$lambda.min
bestlam

# Datos en Tabla de la slide 18:
# head(cbind(cv.out$lambda,cv.out$cvm,cv.out$cvsd),3) # lambda, ecme estimado, se
# which(cv.out$lambda == bestlam)
# cbind(cv.out$lambda,cv.out$cvm,cv.out$cvsd)[72,]

# Una vez que aprendimos el mejor valor de lambda ('bestlam'):
pred.ridge.best <- predict(ridge.reg, s = bestlam , newx = X[-id.train,])
ecm.ridge = sum( (pred.ridge.best - Y[-id.train])^2 )/300 # Mejora del 4% respecto de MCO.
ecm.ridge # Sobre la muestra TEST (mejora del orden de 0.15).

#--- > @@@@@(volver a diapos) < ---@@@@@#

# Lasso (alpha = 1)

grid.l =exp(seq(5 , -5 , length = 100)) 
set.seed(1)
lasso.reg = glmnet(x = X[id.train,] , 
                   y = Y[id.train ], 
                   family = 'gaussian',  
                   alpha = 1 ,   # Lasso   
                   lambda = grid.l)

x11()
par(mar = c(5,5,2,1), mfrow = c(1,2))
plot(lasso.reg, xvar = "lambda", label = TRUE, xlab = expression(log(lambda)))
plot(ridge.reg, xvar = "lambda", label = TRUE, xlab = expression(log(lambda)))
# Las covariables "ruido" son las primeras en desaparecer del modelo (modelo descarta lo inecesario).

x11();# Ninguna estimación cambia de 'signo' a lo largo del 'path'. 
par(mar = c(4,5,1,1))
matplot(log(grid.l),t(coef(lasso.reg)[2:10,]), type = 'l', lty = 1, lwd = 2, xlab = expression(log(lambda)),ylab = expression(hat(beta)(lambda)))
abline(h=c(0), col = 'gray', lty = 2, lwd = 2)


## CV LASSO: (igual que el caso Ridge)
set.seed(1)
cv.out = cv.glmnet(x = X[id.train,], 
                   y = Y[id.train], 
                   lambda = grid.l, 
                   alpha = 1,       # Lasso. 
                   nfolds = 5)      
cv.out

x11()
plot(cv.out) 

bestlam = cv.out$lambda.1se
bestlam

# which(cv.out$lambda == bestlam)
# cbind(cv.out$lambda,cv.out$cvm,cv.out$cvsd)[71,]


# Una vez que estimamos el mejor valor de lambda (bestlam):
pred.lasso.best <- predict(lasso.reg, s = bestlam , newx = X[-id.train,])
ecm.lasso = sum( (pred.lasso.best - Y[-id.train])^2 )/300 #
ecm.lasso # Reducción del 63% respecto de mco y del 60% respecto de ridge.
#-------------------------------------------------------------------------- END.

########### Modelos lineales generalizados + Lasso, ridge y ENets:
#family = 'binomial' --> Modelos Logísticos con regularización
#family = 'poisson' --> Modelos de conteo con regularización


# ¿El modelo más parsimónico (con 11 features) 
#  incluye a las 9 covariables relevantes?
lasso = glmnet(x = X, y = Y, family = 'gaussian',  
               alpha = 1, lambda = bestlam)

which(lasso$beta!=0) # ('sparsistency')
#---------------------------------------------------------- End.