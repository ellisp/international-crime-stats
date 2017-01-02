library(viridis)
library(caret)

load("data/indicators2005.rda")

names(indicators2005)

p2 <- ggplot(indicators2005, aes(x = FirearmsPer100People2005, y = Suicide, label = country)) +
  geom_smooth(method = "lm") +
  geom_text_repel(colour = "white") +
  geom_point() +
  labs(x = "Civilian firearms per 100 people", 
       y = "Suicide per 100,000")
p2

p2 +  scale_x_log10(breaks = c(1, 10, 100)) +
  scale_y_log10()


p3 <- ggplot(indicators2005, aes(x = FirearmsPer100People2005, y = Homicide2005, label = Alpha_3)) +
  geom_smooth(method = "lm") +
  geom_text_repel(colour = "white") +
  geom_point() +
  labs(x = "Civilian firearms per 100 people", 
       y = "Homicide per 100,000")
p3

p3 +  scale_x_log10(breaks = c(1, 10, 100)) +
  scale_y_log10()


#----other---------
ggplot(indicators2005, aes(x = GNPPerCapitaPPP, y = HDI, label = country)) +
  geom_smooth(method = "lm") +
  geom_text_repel(colour = "white") +
  geom_point() +
  scale_x_log10()

indicators2005 %>%
  filter(!is.na(Suicide)) %>%
  ggplot(aes(x = HDI, y = Suicide, label = country)) +
  geom_smooth(method = "lm") +
  geom_text_repel(colour = "white") +
  geom_point() +
  scale_y_log10()


#--------pairs---------------
indicators2005 %>%
  dplyr::select(GNPPerCapitaPPP, gini, HDI, FirearmsPer100People2005, Homicide2005, Suicide) %>%
  ggpairs() 

indicators2005 %>%
  mutate(LogGNI = log(GNPPerCapitaPPP),
         LogFirearms = log(FirearmsPer100People2005),
         LogHomicide = log(Homicide2005),
         LogSuicide = log(Suicide)) %>%
  select(LogGNI, HDI, gini, LogFirearms, LogHomicide, LogSuicide, rich) %>%
  mutate(rich = as.factor(rich)) %>%
  filter(!is.na(rich)) %>%
  ggpairs(mapping = ggplot2::aes(color = rich))


#--------------modelling homicide---------------------

m1 <- lm(log(Homicide2005) ~ log(GNPPerCapitaPPP) + gini +  log(FirearmsPer100People2005), data = indicators2005)
m2 <- lm(log(Homicide2005) ~ HDI + gini +  log(FirearmsPer100People2005), data = indicators2005)
summary(m1)
summary(m2)
AIC(m1, m2)

# diagnostics are fine:
par(mfrow = c(2, 2))
plot(m1)

