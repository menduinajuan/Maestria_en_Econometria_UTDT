#### Minimizamos la función RE(theta) = -log(theta^2+1) + theta^2

#------   Gradiente descendiente  ----------------------------------#

# Primero creo/defino la función RE en la memoria de R:
RE = function(theta){ -log(theta^2+1) + theta^2}
RE(1) # Puedo evaluar la función RE donde quiera.

# Podemos graficar las funciones con el comando plot:
par(mfrow = c(1,2), mar = c(4.4,4.4,1,1))  # Parámetros gráficos 
plot(RE, from = -5, to = 5, xlab = expression(theta),lwd = 2)

# Si hacemos la cuenta, es fácil ver que theta* = 0. Usemos el
# gradiente descendiente para aproximar esta solución numéricamente:
RE_prima = function(theta){ -(2*theta)/(theta^2+1) + 2*theta}
plot(RE_prima, from = -5, to = 5, xlab = expression(theta),lwd = 2)
abline(h = 0, col = 'gray', lty = 4)

theta = -4 # Valor inicial ó lo que llamamos theta_0 (en las slides)
points(theta,0, col='red', pch = 20)

lambda = 0.1
theta = theta - lambda*RE_prima(theta)
print(theta)
points(theta,0, col='blue', pch = 20) # Primera actualización.

theta = theta - lambda*RE_prima(theta)
print(theta)
points(theta,0, col='green', pch = 20) # Segunda actualización.

theta = theta - lambda*RE_prima(theta)
print(theta)
points(theta,0, col='brown', pch = 20) # Tercera actualización.

# Ejercicio en clase: Utilizá el bucle foor para iterar 10mil veces
# usando la regla del gradiente descendiente (y lambda = 0.1)

theta = -4
for (i in 1:10000) {
  theta = theta - lambda*RE_prima(theta)
  print(i)
}
print(theta)

#------   Newton-Raphson   ----------------------------------#
g = RE_prima
g_prima = function(theta){ # Derivada segunda de RE
  2*(theta^2 - 1)/ (theta^2 + 1)^2 + 2 
}

plot(RE, from = -5, to = 5, xlab = expression(theta), lwd = 2, ylab ='g')
plot(RE_prima, from = -5, to = 5, xlab = expression(theta), ylab ="g'" ,lwd = 2)
abline(h = 0, col = 'gray', lty = 4)

theta = -4
points(theta,0, col='red', pch = 20)

theta = theta - g(theta)/g_prima(theta)
print(theta) # Primer update
points(theta,0, col='blue', pch = 20)

theta = theta - g(theta)/g_prima(theta)
print(theta) # Segundo update
points(theta,0, col='green', pch = 20)

theta = theta - g(theta)/g_prima(theta)
print(theta) # Tercer update
points(theta,0, col='brown', pch = 20)


# Ejercicio en clase: Utilizá el bucle foor para iterar sólo 10 veces
# usando la regla del Newton Raphson.

for (i in 1:10) {
  theta = theta - g(theta)/g_prima(theta)
}
print(theta)

#------------------------------------------------------------ End.