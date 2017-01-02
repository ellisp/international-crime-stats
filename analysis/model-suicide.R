#---------------modelling suicide----------------
SuicideData <- indicators2005 %>%
  dplyr::select(Suicide, FemaleSuicide, MaleSuicide, GNPPerCapitaPPP, gini, FirearmsPer100People2005, HDI, country, Alcohol)
SuicideData <- SuicideData[complete.cases(SuicideData), ]

m3 <- lm(log(Suicide) ~ log(GNPPerCapitaPPP) + gini +  log(FirearmsPer100People2005), data = SuicideData)
m4 <- lm(log(Suicide) ~ HDI + gini +  log(FirearmsPer100People2005), data = SuicideData)
m4b <- lm(log(Suicide) ~ HDI + gini +  log(FirearmsPer100People2005), 
          data = subset(SuicideData, country != "South Africa"))
m5 <- lm(log(Suicide) ~ HDI * gini +  log(FirearmsPer100People2005), data = SuicideData)
m5a <- MASS::lqs(log(Suicide) ~ HDI * gini +  log(FirearmsPer100People2005), data = SuicideData)
m5b <- lm(log(Suicide) ~ HDI * gini +  log(FirearmsPer100People2005), 
          data = subset(SuicideData, country != "South Africa"))
m6 <- lm(log(Suicide) ~ GNPPerCapitaPPP * gini +  log(FirearmsPer100People2005), data = SuicideData)
m7 <- lm(log(Suicide) ~ HDI, data = SuicideData)
m8 <- lm(log(Suicide) ~ HDI * gini + Alcohol +  log(FirearmsPer100People2005), data = SuicideData)


summary(m3)
summary(m4)
summary(m4b)
summary(m5) # best model with South Africa
summary(m5b) # interaction effect disappears without South Africa
summary(m7) # when inequality not in, there is a strong income effect the other way but beware, this is basically just the collinearity with inequality
summary(m8)
AIC(m3, m4, m5)


train(log(Suicide) ~ HDI * gini +  log(FirearmsPer100People2005), method = "lm",
      data = SuicideData,
      trControl = trainControl(method = "boot632", number = 500))

train(log(Suicide) ~ GNPPerCapitaPPP * gini +  log(FirearmsPer100People2005), method = "lm",
      data = SuicideData,
      trControl = trainControl(method = "boot632", number = 500))
# not quite as good

par(mfrow = c(2, 2)); plot(m5)

x <- with(SuicideData, seq(from = min(HDI), to = max(HDI), length.out = 100))
y <- with(SuicideData, seq(from = min(gini), to = max(gini), length.out = 100))
x2 <- with(SuicideData, seq(from = min(GNPPerCapitaPPP), to = max(GNPPerCapitaPPP), length.out = 100))
newdata <- expand.grid(
  HDI = x,
  gini = y,
  FirearmsPer100People2005 = log(mean(indicators2005$FirearmsPer100People2005, na.rm = TRUE))
)

png("images/suicide-hdi-gini.png", 8*600, 8*600, res=600)
z <- matrix(predict(m5, newdata), nrow = 100)
par(mfrow = c(1, 1), family = "Calibri")
with(newdata, image(x, y, z, 
                    xlab = "Human Development Index (right of chart is higher development)\nContour lines show predicted values.  Numbers in orange are observed suicide rates in actual countries.", 
                    ylab = "Gini coefficient (top of chart is more unequal)",
                    col = viridis(100)))
levs <- seq(from = 0, to = 9, length.out = 20)
with(newdata, contour(x, y, z, add = TRUE, labcex = 1, family = "xkcd",
                      levels = levs, labels = round(exp(levs)), col = "white"))
title(main = "Higher inequality or higher development means lower suicide rates")
with(indicators2005, text(HDI, gini, round(Suicide), col = "orange", family = "xkcd"))
dev.off()


newdata <- expand.grid(
  GNPPerCapitaPPP = x2,
  gini = y,
  FirearmsPer100People2005 = log(mean(indicators2005$FirearmsPer100People2005, na.rm = TRUE))
)

z <- matrix(predict(m3, newdata), nrow = 100)
par(mfrow = c(1, 1), family = "Calibri")
with(newdata, image(x2, y, z, 
                    xlab = "GNP Per Capita (right of chart is richer)\nContour lines show predicted values.  Numbers in orange are observed suicide rates in actual countries.", 
                    ylab = "Gini coefficient (top of chart is more unequal)",
                    col = viridis(100)))
levs <- seq(from = 0, to = 9, length.out = 20)
with(newdata, contour(x2, y, z, add = TRUE, labcex = 1, family = "xkcd",
                      levels = levs, labels = round(exp(levs)), col = "white"))
title(main = "Higher inequality or higher development means lower suicide rates")
with(indicators2005, text(GNPPerCapitaPPP, gini, round(Suicide), col = "orange", family = "xkcd"))


#=========================sex disag=========================
smm8 <- lm(log(MaleSuicide) ~ HDI * gini + Alcohol *  log(FirearmsPer100People2005), data = SuicideData)
summary(smm8)

