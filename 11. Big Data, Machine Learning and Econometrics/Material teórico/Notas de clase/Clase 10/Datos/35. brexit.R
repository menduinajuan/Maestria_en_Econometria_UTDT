rm(list=ls())  ;  dev.off()
#--------------- Pipeline para SSA (brexit data) ---------------#
require(ASSA) || install.packages('ASSA')
library(ASSA)
data("brexit") # https://ig.ft.com/sites/brexit-polling/

tail(brexit, 3) # Los datos estan ordenados de más viejo (arriba) a más nuevo (abajo)
head(brexit, 3) # Los datos estan ordenados de más viejo (arriba) a más nuevo (abajo)
##################
attach(brexit)
# Raw polldata (desde 2013 en adelante):
x11()
plot(date[1:266], leave[1:266], pch = 16, xlab = "Time (in years)",
     ylab = "Percentage", ylim = c(0, 66), cex.lab = 1.4, cex.axis = 1.4,
     cex = 1.4)
points(date[1:266], stay[1:266], pch = 16, col = "gray", cex = 1.4)
points(date[1:266], undecided[1:266], pch = 3, cex = 1.4)

# El objetivo es construír modelos de nowcasting para cada serie (datos composicionales)
# Las componentes se pueden interpretar como tendencia y ciclos en las opiniones sobre Brexit.
# El modelo permite en definitiva ensamblar la información de las distintas encuestas.

################################################################################
################# Now casting con SSA (modelos univariantes para cada serie)  ##
################################################################################
  
raw.l <- tsframe(date, leave/100) # Los datos tienen que estar en formato "ASSA" (parecido a ts())

fit.l <- sst(raw.l, l = 100 , m = 5) # (l y m) son hiperparámetros sensibles 

dim(fit.l$erc[[1]]) # Componentes fundamentales de la serie

fit.l$trendline     # Versión "filtrada" (nowcasting) de la serie.

x11()
plot(fit.l, col = 'blue', ylab = 'leave', type = 'l', lwd = 2, ylim = c(0.2,0.65))
points(date, leave/100, pch = 20, lwd = 0.5) # Overfitting

# Ejercicio en clase: Experimentá que pasa al cambiar "l" y "m".

### Ajuste automático de parámetros
fit.l <- sst(raw.l) # (l = 'automatic' y m = 'automatic')
x11()
plot(fit.l, col = 'blue', ylab = 'leave', type = 'l', lwd = 2, ylim = c(0.2,0.65))
points(date, leave/100, pch = 20, lwd = 0.5)

# Hiperparámetros seleccionados de forma automática 
#(utilizando el test basado en el periodograma de los residuos, slide 17):
fit.l$l; fit.l$m

#### Otros outputs gráficos del paquete:
# Componentes elementales (ERC):
dim(fit.l$erc[[1]])
x11()# El fitting que produce el modelo es la suma de estas dos componentes.
plot(fit.l, options = list(type = "components", ncomp = 1:2),                            
     col='red', type = 'l', ylab = '')

# Periodograma (y bandas del 95%) (ver algoritmo en slide 17)
x11(); par(mfrow=c(1,1), mar=c(4,2,1,1))
plot(fit.l, options = list(type = "cpgram"))

# Scree-plot (criterio alternativo para elegir la cantidad de compontes)
x11(); par(mfrow=c(1,1), mar=c(4,2,1,1))
plot(fit.l, options = list(type = "screeplot", ncomp = 1:8))

##### Fitting de las demás series (stay, undecided):
raw.s <- tsframe(date, stay/100)
fit.s <- sst(raw.s)
fit.s$l; fit.s$m # l = 137 y m = 2 para stay

raw.u <- tsframe(date, undecided/100)
fit.u <- sst(raw.u)
fit.u$l; fit.u$m # l = 137 y m = 1 para undecided 

x11()
plot(date[1:266], leave[1:266], pch = 16, xlab = "Time (in years)",
     ylab = "Percentage", ylim = c(0, 66), cex.lab = 1.4, cex.axis = 1.4,
     cex = 1.4)
points(date[1:266], stay[1:266], pch = 16, col = "gray", cex = 1.4)
points(date[1:266], undecided[1:266], pch = 3, cex = 1.4)
lines(date[1:266], fit.l$trendline$y[-c(1:6)]*100, col = "blue", lwd = 3)
lines(date[1:266], fit.s$trendline$y[-c(1:6)]*100, col = "red", lwd = 3)
lines(date[1:266], fit.u$trendline$y[-c(1:6)]*100, col = "black", lwd = 3)

###############################################################################
########################## Forecasting ########################################
###############################################################################

predict(fit.l, p = 5)$forecasts # basado en l = 137 y m = 2
predict(fit.s, p = 5)$forecasts # basado en l = 137 y m = 2
predict(fit.u, p = 5)$forecasts # basado en l = 137 y m = 1
#####--------------------------------------------------- END.


### Apéndice
###############################################################################
############## Modelos multivariantes (MSSA) y extensiones   ##################
###############################################################################
### Referencia: https://www.sciencedirect.com/science/article/abs/pii/S0169207018300943

# El modelo univariante no es consistente con la naturaleza composicional de los datos:
predict(fit.l, p = 1)$forecasts +predict(fit.s, p = 1)$forecasts + predict(fit.u, p = 1)$forecasts

y <- mtsframe(date, Y = brexit[, 1:3]/100) # Serie temporal multivariante

?msst ; ?msstc # Algunos de los modelos multivariantes implementados en el paquete.

fit <- msstc(y, vertical = TRUE) # tiene en cuenta la posible autocorrelación entre las series.
class(fit)

head(fit$trendlines$Y, 3)

head(rowSums(fit$trendlines$Y), 3) # Datos composicionales

fit$m; fit$l; fit$vertical

predict(fit, p = 3)$forecast

rowSums(predict(fit, p = 3)$forecast) # Las estimaciones y las prediciones 'suman 1'.

x11()
plot(date[1:266], leave[1:266], pch = 16, xlab = "Time (in years)",
     ylab = "Percentage", ylim = c(0, 66), cex.lab = 1.4, cex.axis = 1.4,
     cex = 1.4)
points(date[1:266], stay[1:266], pch = 16, col = "gray", cex = 1.4)
points(date[1:266], undecided[1:266], pch = 3, cex = 1.4)
lines(date[1:266], fit$trendlines$Y[-c(1:6),1]*100, col = "blue", lwd = 3)
lines(date[1:266], fit$trendlines$Y[-c(1:6),2]*100, col = "red", lwd = 3)
lines(date[1:266], fit$trendlines$Y[-c(1:6),3]*100, col = "black", lwd = 3)

#### Otros outputs gráficos del paquete:
# Componentes elementales (ERC):
dim(fit$erc[[1]]) #
x11()
plot(fit, options = list(type = "components", ncomp = 1:2))

# Periodogram (y bandas del 95%)
x11()
par(mfrow=c(1,3), mar=c(4,2,1,1))
plot(fit, options = list(type = "cpgrams"))
#### End.