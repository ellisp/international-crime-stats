#---------------modelling suicide----------------
SuicideData <- indicators2005 %>%
  select(Suicide, GNPPerCapitaPPP, gini, FirearmsPer100People2005, HDI, country)
SuicideData <- SuicideData[complete.cases(SuicideData), ]

m3 <- lm(log(Suicide) ~ log(GNPPerCapitaPPP) + gini +  log(FirearmsPer100People2005), data = SuicideData)
m4 <- lm(log(Suicide) ~ HDI + gini +  log(FirearmsPer100People2005), data = SuicideData)
m4b <- lm(log(Suicide) ~ HDI + gini +  log(FirearmsPer100People2005), 
          data = subset(SuicideData, country != "South Africa"))
m5 <- lm(log(Suicide) ~ HDI * gini +  log(FirearmsPer100People2005), data = SuicideData)
m5a <- MASS::lqs(log(Suicide) ~ HDI * gini +  log(FirearmsPer100People2005), data = SuicideData)
m5b <- lm(log(Suicide) ~ HDI * gini +  log(FirearmsPer100People2005), 
          data = subset(SuicideData, country != "South Africa"))
m6 <- lm(log(Suicide) ~ HDI, data = SuicideData)

summary(m3)
summary(m4)
summary(m4b)
summary(m5) # best model with South Africa
summary(m5b) # interaction effect disappears without South Africa
summary(m6) # when inequality not in, there is a strong income effect the other way but beware, this is basically just the collinearity with inequality
AIC(m3, m4, m5)

train(log(Suicide) ~ HDI * gini +  log(FirearmsPer100People2005), method = "lm",
      data = SuicideData,
      trControl = trainControl(method = "boot632", number = 100))

par(mfrow = c(2, 2)); plot(m5)

x <- with(subset(indicators2005, !is.na(Suicide)), seq(from = min(HDI, na.rm = TRUE), to = max(HDI, na.rm = TRUE), length.out = 100))
y <- with(subset(indicators2005, !is.na(Suicide)), seq(from = min(gini, na.rm = TRUE), to = max(gini, na.rm = TRUE), length.out = 100))
newdata <- expand.grid(
  HDI = x,
  gini = y,
  FirearmsPer100People2005 = log(mean(indicators2005$FirearmsPer100People2005, na.rm = TRUE))
)


newdata$predicted <- exp(predict(m5, newdata))

z <- matrix(predict(m5, newdata), nrow = 100)
par(mfrow = c(1, 1), family = "Calibri")
with(newdata, image(x, y, z, 
                    xlab = "\n\nHuman Development Index (right of chart is higher development)\nContour lines show predicted values.  Numbers in orange are observed suicide rates in actual countries.", 
                    ylab = "Gini coefficient (top of chart is more unequal)",
                    col = viridis(100)))
levs <- seq(from = 0, to = 9, length.out = 20)
with(newdata, contour(x, y, z, add = TRUE, labcex = 1, family = "xkcd",
                      levels = levs, labels = round(exp(levs)), col = "white"))
title(main = "Higher inequality or higher development means lower suicide rates")
with(indicators2005, text(HDI, gini, round(Suicide), col = "orange", family = "xkcd"))
