### Simulando datos de un modelo de regresión con 1 covariables:
set.seed(1)
x = rnorm(n = 100, mean = 0, sd = 1); x = sort(x)
y = 1 + 2*x + rnorm(100,0,1)  # Verdaderos parámetros (beta_0 = 1 y beta_1 = 2).

x[101]= 7; y[101] = -5 # Outlier

x11()
plot(x, y, pch = 20, ylim = c(-5,7), xlim = c(-5,7))
points(x[101], y[101] , col = 'blue', lwd = 4)

summary(lm(y~x)) # hat.beta_1.ols = 0.87 (sensiblemente menor a 2 = beta_1, porqué?)
points(x,0.95+ 0.92*x, type = 'l', col = 'blue', lty = 3)
points(x,1+ 2*x, type = 'l', col = 'gray', lty = 3) # Verdadera función de regresión en la población.


### Gradiente descendiente: (l@s alumn@s implementan en clase)

