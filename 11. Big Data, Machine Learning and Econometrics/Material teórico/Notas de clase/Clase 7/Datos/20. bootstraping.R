#------------------      Bootstrap       ---------------------#
data("mtcars")
head(mtcars,3)

# mpg Miles/(US) gallon
# disp	Displacement (cu.in.)
# wt	Weight (1000 lbs)
# Diccionario: https://www.rdocumentation.org/packages/datasets/versions/3.6.2/topics/mtcars

reglin = lm(mpg~wt+disp, data = mtcars)
summary(reglin)

summary(reglin)$adj.r.squared 
#(1) ¿Cómo interpretamos esta estimación? 
#(2) ¿Cómo cuantificamos la incertidumbre respecto a esta cantidad?

##### El Bootstrap nos permite dar una respuesta a (2) ###### 
n = dim(mtcars)[1]; 
B = 1000; #(Cantidad de re-muestras)
R2a = c(); # Aquí guardo los valores de los theta* (ver slide 13).

set.seed(1) # (replicabilidad)
for(i in 1:B){
  id = sample(n,n, replace = T) # Re-muestreo con reemplazamiento
  reglin.boots = lm(mpg~wt+disp, data = mtcars, subset = id) # utilizo las remuestras.
  R2a[i] = summary(reglin.boots)$adj.r.squared
  print(i)
}

sd(R2a)  # Estimación del error estandard asociado al estimador R^2_aj
x11();
hist(R2a, xlab = expression(R[aj]^2), main = expression(paste('Distribución empírica del ',R[aj]^2)))

# Intervalo utilizando los cuantiles empíricos:
quantile(R2a,0.975) ; abline(v = quantile(R2a,0.975), col = 'red')
quantile(R2a,0.025) ; abline(v = quantile(R2a,0.025), col = 'red')
# El 95% de los R^2_aj están en el intervalo [0.66,0.86] (poca incertidumbre). 

# Intervalo de confianza aproximados asumiendo normalidad:
alpha = 0.05
summary(reglin)$adj.r.squared - qnorm(1-alpha/2)*sd(R2a)  
summary(reglin)$adj.r.squared + qnorm(1-alpha/2)*sd(R2a) # Virtualmente idéntico al caso anterior.  


# En 5.2 y 5.3.4 de ISLR hay m?s ejemplos y usos pr?cticos del Bootstrap.

### Apéndice boostrap con algunas funciones de del paquete 'boot':
# install.packages(boot)
library(boot)
r_squared <- function(formula, data, indices) { # Función de los datos a bootstrapear.
  remuestra <- data[indices,]  
  fit <- lm(formula, data=remuestra)
  return(summary(fit)$r.square)
} 

output <- boot(data=mtcars, 
               statistic=r_squared, # <- virtualmente cualquier función de los datos para la que queramos estimar un error standard.
               R=1500,              # cantidad de re-muestras boostrap a considerar (valor de "B" en las slides) 
               formula=mpg~wt+disp) 

output 
x11(); plot(output) # t es el estadístico que evaluamos (en este caso el R2a)
boot.ci(output, type="bca")
#---------------------------------------------- Fin Bootstrap.