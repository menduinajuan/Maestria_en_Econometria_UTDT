# Regresión logística (Modelos lineales generalizados) en R:
#install.packages('ISLR2')
library(ISLR2)

data <- ISLR2::Default

head(data, 3) # 2 covariables continuas y una categórica.
dim(data)

# Asignando 0 a la categoría "No" y 1 a la categoría "Yes"
data$default <- as.character(data$default)
data$default[data$default == "No"]  <- 0 
data$default[data$default == "Yes"] <- 1 
data$default <- as.numeric(data$default) # También la podés formatear como factor.

str(data) # Todo ok.

table(data$default)/dim(data)[1]*100 # Clases desbalanceadas.

set.seed(1)
id.train <- sample(10000,7000)

# ---- Fiteamos modelos (lineales generalizados) logísticos con la función glm
?glm

logit.df <- glm(default  ~ ., 
                data=data, 
                subset = id.train,
#               weights = NULL, # Para rebalancear las clases (verosimilitud ponderada).
                family=binomial(link="logit"))

summary(logit.df)

pred.train = predict(logit.df , type="response")
head(pred.train)

boxplot(pred.train)

pred.test  = predict(logit.df, newdata = data[-id.train,] , type="response")
head(pred.train)
boxplot(pred.test)


# Función de regresión estimada:
library(ggplot2)
x11()
ggplot(data, aes(x=balance, y=default)) + 
  geom_point(alpha=.5) +
  stat_smooth(method="glm", se=FALSE, method.args = list(family=binomial),
              col="red", lty=2)


# Algunas métricas estadísticas:
logit.df$aic
logit.df$deviance

# Algunas métricas utilizadas en ML (estimadas sobre el conjunto de test/validación):
nu = 0.5 # Umbral

round(head(pred.test,5), 3)

pred.test[pred.test< nu] <- 0
pred.test[pred.test>=nu] <- 1

head(pred.test,5)


mat.conf = table(pred.test, data$default[-id.train])
mat.conf

prec = mat.conf[2,2] / (mat.conf[2,2]+mat.conf[2,1])
prec

rec = mat.conf[2,2] / (mat.conf[2,2]+mat.conf[1,2])
rec # Hay muchos '1' que predecimos como '0' -> recall bajo.

F1 = 2*(prec*rec)/(prec + rec)
F1

pred.all  = predict(logit.df, newdata = data , type="response")
data$prob=pred.all

library(pROC)
g <- roc(default ~ prob, data = data)
g

x11(); plot(g)    ; g$auc