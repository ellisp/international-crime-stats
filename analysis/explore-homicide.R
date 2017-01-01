load("data/indicators.rda")



library(GGally)

p1 <- ggplot(combined, aes(x = PopCorrectedFirearms, y = Both, label = CountrySAS)) +
  geom_smooth(method = "lm") +
  geom_text_repel(colour = "white") +
  geom_point() +
  labs(x = "Civilian firearms per 100 people", 
       y = "Combined suicide and homicides per 100,000")
p1


p1 +  scale_x_log10(breaks = c(1, 10, 100)) +
  scale_y_log10()

p2 <- ggplot(combined, aes(x = PopCorrectedFirearms, y = Suicide, label = CountrySAS)) +
  geom_smooth(method = "lm") +
  geom_text_repel(colour = "white") +
  geom_point() +
  labs(x = "Civilian firearms per 100 people", 
       y = "Suicide per 100,000")
p2

p2 +  scale_x_log10(breaks = c(1, 10, 100)) +
  scale_y_log10()


p3 <- ggplot(combined, aes(x = PopCorrectedFirearms, y = Homicide, label = CountrySAS)) +
  geom_smooth(method = "lm") +
  geom_text_repel(colour = "white") +
  geom_point() +
  labs(x = "Civilian firearms per 100 people", 
       y = "Homicide per 100,000")
p3

p3 +  scale_x_log10(breaks = c(1, 10, 100)) +
  scale_y_log10()


combined %>%
  dplyr::select(GNI, Both:Suicide, PopCorrectedFirearms) %>%
  ggpairs() +
  scale_x_log10()

combined %>%
  mutate(LogGNI = log(GNI),
         LogFirearms = log(PopCorrectedFirearms),
         LogHomicide = log(Homicide),
         LogSuicide = log(Suicide)) %>%
  select(LogGNI, LogFirearms, LogHomicide, LogSuicide) %>%
  ggpairs()


#--------------modelling---------------------
pairs(combined[ , c("GNI", "Both", "PopCorrectedFirearms")])
pairs(log(combined[ , c("GNI", "Both", "PopCorrectedFirearms")]))

m1 <- lm(log(Both) ~ log(GNI) + log(PopCorrectedFirearms), data = combined)
summary(m1)

m2 <- lm(log(Homicide) ~ log(GNI) + log(PopCorrectedFirearms), data = combined)
summary(m2)

m3 <- lm(log(Suicide) ~ log(GNI) + log(PopCorrectedFirearms), data = combined)
summary(m3)

# diagnostics all check out fine
par(mfrow = c(2, 2))
plot(m1)
plot(m2)
plot(m3)


library(glmnet)
combined2 <- combined[complete.cases(combined), ]
y = log(combined2$Homicide)
x = with(combined2, cbind(log(GNI), log(PopCorrectedFirearms)))
m4 <- glmnet(y = y, x = x)
summary(m4)
?glmnet
plot(m4)
coef(m4)
coef(m2)
