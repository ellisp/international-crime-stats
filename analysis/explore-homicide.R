load("data/indicators2012.rda")


p1 <- ggplot(indicators2012, aes(x = FirearmsPer100People2005, y = HomicideAndSuicide, label = Alpha_3)) +
  geom_smooth(method = "lm") +
  geom_text_repel(colour = "white") +
  geom_point() +
  labs(x = "Civilian firearms per 100 people", 
       y = "Combined suicide and homicides per 100,000")
p1

p1 +  scale_x_log10(breaks = c(1, 10, 100)) +
  scale_y_log10()

p2 <- ggplot(indicators2012, aes(x = FirearmsPer100People2005, y = Suicide, label = Alpha_3)) +
  geom_smooth(method = "lm") +
  geom_text_repel(colour = "white") +
  geom_point() +
  labs(x = "Civilian firearms per 100 people", 
       y = "Suicide per 100,000")
p2

p2 +  scale_x_log10(breaks = c(1, 10, 100)) +
  scale_y_log10()


p3 <- ggplot(indicators2012, aes(x = FirearmsPer100People2005, y = Homicide, label = Alpha_3)) +
  geom_smooth(method = "lm") +
  geom_text_repel(colour = "white") +
  geom_point() +
  labs(x = "Civilian firearms per 100 people", 
       y = "Homicide per 100,000")
p3

p3 +  scale_x_log10(breaks = c(1, 10, 100)) +
  scale_y_log10()


#----other---------
ggplot(indicators2012, aes(x = GNPPerCapitaPPP, y = HDI, label = country)) +
  geom_smooth(method = "lm") +
  geom_text_repel(colour = "white") +
  geom_point() +
  scale_x_log10()



#--------pairs---------------
indicators2012 %>%
  dplyr::select(GNPPerCapitaPPP, gini, HDI, FirearmsPer100People2005, Homicide, Suicide) %>%
  ggpairs() 

indicators2012 %>%
  mutate(LogGNI = log(GNPPerCapitaPPP),
         LogFirearms = log(FirearmsPer100People2005),
         LogHomicide = log(Homicide),
         LogSuicide = log(Suicide)) %>%
  select(LogGNI, HDI, gini, LogFirearms, LogHomicide, LogSuicide, rich) %>%
  mutate(rich = as.factor(rich)) %>%
  filter(!is.na(rich)) %>%
  ggpairs(mapping = ggplot2::aes(color = rich))


#--------------modelling homicide---------------------

m1 <- lm(log(Homicide) ~ log(GNPPerCapitaPPP) + gini +  log(FirearmsPer100People2005), data = indicators2012)
m2 <- lm(log(Homicide) ~ HDI + gini +  log(FirearmsPer100People2005), data = indicators2012)
summary(m1)
summary(m2)
AIC(m1, m2)

# diagnostics are fine:
par(mfrow = c(2, 2))
plot(m1)

#---------------modelling suicide----------------
m3 <- lm(log(Suicide) ~ log(GNPPerCapitaPPP) + gini +  log(FirearmsPer100People2005), data = indicators2012)
m4 <- lm(log(Suicide) ~ HDI + gini +  log(FirearmsPer100People2005), data = indicators2012)
m5 <- lm(log(Suicide) ~ HDI * gini +  log(FirearmsPer100People2005), data = indicators2012)

summary(m3)
summary(m4)
summary(m5)
AIC(m3, m4)

#-------suicide, just rich countries-------------
m4a <- lm(log(Suicide) ~ HDI + gini +  log(FirearmsPer100People2005), data = subset(indicators2012, rich))
summary(m4a)

