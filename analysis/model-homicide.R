

#--------------modelling homicide---------------------
HomicideData <- indicators2005 %>%
  dplyr::select(Homicide2005, GNPPerCapitaPPP, gini, FirearmsPer100People2005, HDI, country, Alcohol)
HomicideData <- HomicideData[complete.cases(HomicideData), ]


hm1 <- lm(log(Homicide2005) ~ log(GNPPerCapitaPPP) + gini +  log(FirearmsPer100People2005), data = HomicideData)
hm2 <- lm(log(Homicide2005) ~ HDI + gini +  log(FirearmsPer100People2005), data = HomicideData)
hm3 <- lm(log(Homicide2005) ~ HDI * gini +  log(FirearmsPer100People2005), data = HomicideData)
hm4 <- lm(log(Homicide2005) ~ HDI * gini, data = HomicideData)
hm5 <- lm(log(Homicide2005) ~ HDI * gini + Alcohol + log(FirearmsPer100People2005), data = HomicideData)
summary(hm1)
summary(hm2)
summary(hm3)
AIC(hm1, hm2, hm3)
anova(hm2, hm3)

summary(hm5)

# diagnostics are fine:
par(mfrow = c(2, 2))
plot(hm3)

train(log(Homicide2005) ~ HDI * gini +  log(FirearmsPer100People2005), method = "lm",
      data = HomicideData,
      trControl = trainControl(method = "boot632", number = 500))

train(log(Homicide2005) ~ HDI * gini, method = "lm",
      data = HomicideData,
      trControl = trainControl(method = "boot632", number = 500))


x <- with(HomicideData, seq(from = min(HDI), to = max(HDI), length.out = 100))
y <- with(HomicideData, seq(from = min(gini), to = max(gini), length.out = 100))
newdata <- expand.grid(
  HDI = x,
  gini = y,
  FirearmsPer100People2005 = log(mean(indicators2005$FirearmsPer100People2005, na.rm = TRUE))
)


z <- matrix(predict(hm3, newdata), nrow = 100)
par(mfrow = c(1, 1), family = "Calibri")
with(newdata, image(x, y, z, 
                    xlab = "Human Development Index (right of chart is higher development)\nContour lines show predicted values.  Numbers in orange are observed suicide rates in actual countries.", 
                    ylab = "Gini coefficient (top of chart is more unequal)",
                    col = viridis(100)))
levs <- seq(from = 0, to = 9, length.out = 20)
with(newdata, contour(x, y, z, add = TRUE, labcex = 1, family = "xkcd",
                      levels = levs, labels = round(exp(levs)), col = "white"))
title(main = "Higher inequality or less development means higher homicide rates")
with(indicators2005, text(HDI, gini, paste(Alpha_2, round(Homicide2005)), col = "orange", family = "xkcd"))
text(0.85, 20, "High development + low inequality =\nlow murder rate", col = "white")
text(0.35, 55, "Lower development + high inequality =\nhigh murder rate", col = "white")
text(0.70, 60, "Highest murder rate is middle income countries with high inequality", col = "black")

#==========bootstrapped estimate of the firearms coefficient========

myfunction <- function(x, i){
  the_data <- x[i, ]
  hm3 <- lm(log(Homicide2005) ~ HDI * gini +  log(FirearmsPer100People2005), data = the_data)
  return(coef(hm3)["log(FirearmsPer100People2005)"])
}

hm3_boot <- boot(HomicideData, myfunction, R = 5000)
plot(hm3_boot)
boot.ci(hm3_boot, type = "bca")

# with log transformation of both the response and explanatory variables, the coefficients
# are the % change in y for a 1% change in x.  So a 1% increase in firearms held leads to
# between a 0.05% and 0.29% increase in homicides
