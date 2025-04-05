# -------- Potencia de las svm's en Regresi贸n -------------------------------#
rm(list=ls()); dev.off()
require(e1071) || install.packages('e1071');library(e1071)#

# 1 OLS vs SVM (modelo lineal)
set.seed(12345)
x = runif(500,min=0, max = 5);
f = function(x){1+ 5*x} # VErdadera funci贸n de regresi贸n.
y = f(x) + rnorm(500,0,2)
#No cerrar el gr谩fico.

x11()
par(mar = c(4,4,1,1))
plot(x,y, pch = 20, col = rgb(red = 0, green = 0, blue = 0, alpha = 0.1))
plot(f, from = 0, to = 5, lwd = 3, add = T) # Verdadera funci贸n de regresi贸n (esto pretendemos estimar).

# Fitting ols:
ols <- lm(y~x)
summary(ols)
points(x, ols$fitted, type = 'l', col = 'red', lwd = 2, lty = 3)

# Fitting svm (kernel lineal):
datos = data.frame(y,x)
svm.reg <- svm(y ~ x, 
               data = datos,
               type = 'eps-regression', 
               kernel = "linear", # Nucleo lineal. 
               cost = 10^4)

svm.reg 
pred.outsample = predict(svm.reg, newdata = data.frame(x=seq(0,5,by=0.1))) # Estimaci髇 de f(x) v韆 svm's
points(seq(0,5,by=0.1), pred.outsample, type = 'l', lwd = 2, lty = 2, col = 'blue')
### ----------------------------------------------------------------------- End.


# 2: SVM para modelar funciones no lineales de regresi髇
set.seed(54321)
x = runif(500,min=0, max = 10);
f = function(x){log(x) + sqrt(x)*exp(-(x-3)^2) + 5*sin(x*pi)*exp(-(x-6)^2)} # VErdadera funci贸n de regresi贸n.
y = f(x) + rnorm(500)
#No cerrar el gr谩fico.
x11()
par(mar = c(4,4,1,1))
plot(x,y, pch = 20, col = rgb(red = 0, green = 0, blue = 0, alpha = 0.1), ylim = c(-3,8))
plot(f, from = 0, to = 10, lwd = 2, add = T) # Verdadera funci贸n de regresi贸n (esto pretendemos estimar).

datos = data.frame(y,x)
svm.reg <- svm(y ~ x, 
               data = datos,
               type = 'eps-regression', 
               kernel = "radial", # Nucleo gaussiano. 
               cost = 1,
               gamma = 1)

svm.reg 

# Estimaci贸n de f(X) con datos de train y una svm. 
pred.outsample = predict(svm.reg, newdata = data.frame(x=seq(0,10,by=0.05)))
points(seq(0,10,by=0.05), pred.outsample, type = 'l', lwd = 2, lty = 1, col = 'blue')
# Investiga que pasa con el fitting al cambiar el kernel, gamma (sigma) y cost (C).
### ----------------------------------------------------------------------- End.