# this should be re-done as a .Rmd file and exported to the Wiki


load("data/indicators2005.rda")

p2 <- ggplot(indicators2005, aes(x = FirearmsPer100People2005, y = Suicide, label = country)) +
  geom_smooth(method = "lm") +
  geom_text_repel(colour = "white") +
  geom_point() +
  labs(x = "Civilian firearms per 100 people", 
       y = "Suicide per 100,000")

print(p2 +  scale_x_log10(breaks = c(1, 10, 100)) +
  scale_y_log10())


p3 <- ggplot(indicators2005, aes(x = FirearmsPer100People2005, y = Homicide, label = Alpha_3)) +
  geom_smooth(method = "lm") +
  geom_text_repel(colour = "white") +
  geom_point() +
  labs(x = "Civilian firearms per 100 people", 
       y = "Homicide per 100,000")

print(p3)

p3 +  scale_x_log10(breaks = c(1, 10, 100)) +
  scale_y_log10()


#----other---------
print(
ggplot(indicators2005, aes(x = GNPPerCapitaPPP, y = HDI, label = country)) +
  geom_smooth(method = "lm") +
  geom_text_repel(colour = "white") +
  geom_point() +
  scale_x_log10() +
  ggtitle("Gross National Income compared to Human Development Index, 2005",
         "(or closest year available for some countries missing GNI)")
)


print(
indicators2005 %>%
  filter(!is.na(Suicide)) %>%
  ggplot(aes(x = HDI, y = Suicide, label = country)) +
  geom_smooth(method = "lm") +
  geom_text_repel(colour = "white") +
  geom_point() +
  scale_y_log10()
)

#--------pairs---------------

indicators2005 %>%
  mutate(LogGNI = log(GNPPerCapitaPPP),
         LogFirearms = log(FirearmsPer100People2005),
         LogHomicide = log(Homicide),
         LogSuicide = log(Suicide)) %>%
  select(LogGNI, HDI, gini, LogFirearms, LogHomicide, LogSuicide, rich) %>%
  mutate(rich = ifelse(rich, "Most developed", "Less developed")) %>%
  filter(!is.na(rich)) %>%
  ggpairs(mapping = ggplot2::aes(color = rich))
