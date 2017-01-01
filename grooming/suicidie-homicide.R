library(WHO)
library(WDI)
library(fuzzyjoin)

codes <- get_codes()
dim(codes) # 2230 codes


codes[grepl("omicide", codes$display), ]
View(codes[grepl("opulation", codes$display), ])


WDIsearch("gini")



# VIOLENCE_HOMICIDERATE  # per 100,000
# MH_12 # age standardised per 100,000
# SDGSUICIDE # crude  per 100,000


suicide_standard <- get_data("MH_12")
suicide_crude <- get_data("SDGSUICIDE")
homicide_crude <- get_data("VIOLENCE_HOMICIDERATE")
homicide_crude$sex <- "Both sexes"

pop <- get_data("WHS9_86")
gini <- WDI(indicator = "SI.POV.GINI", start = 2000, end = 2016)

gini %>%
  rename(gini = SI.POV.GINI) %>%
  filter(!is.na(gini)) %>%
  filter(year %in% 2000:2016) %>%
  # find year closest to 2005
  mutate(yearout = abs(year - 2005)) %>%
  group_by(country) %>%
  summarise(bestyear = year[yearout == min(yearout)][1],
            gini = gini[year == bestyear])


total_deaths <- rbind(suicide_crude, homicide_crude) %>%
  mutate(value = as.numeric(value))  %>%
  filter(sex == "Both sexes") %>%
  mutate(cause = ifelse(grepl("suicide", gho), "Suicide", "Homicide")) %>%
  dplyr::select(-gho) %>%
  spread(cause, value) %>%
  mutate(Both = Homicide + Suicide) %>%
  left_join(filter(pop, year == 2005)[ , c("country", "value")]) %>%
  rename(Pop2005 = value) %>%
  mutate(Pop2005 =  Pop2005 * 1000) %>%
  arrange(Both) %>%
  mutate(country = factor(country, levels = country)) %>%
  # remove non-country regions:
  filter(!is.na(country)) %>%
  rename(Country = country) %>%
  # rename countries to match those in the gun ownership data %>%
  mutate(CountrySAS = Country,
         CountrySAS = gsub("Bolivia \\(Plurinational State of\\)", "Bolivia", CountrySAS),
         CountrySAS = gsub("Venezuela \\(Bolivarian Republic of\\)", "Venezuela", CountrySAS),
         CountrySAS = gsub("Russian Federation", "Russia", CountrySAS),
         CountrySAS = gsub("Iran \\(Islamic Republic of\\)", "Iran", CountrySAS),
         CountrySAS = gsub("United Arab Emirates", "UAE", CountrySAS),
         CountrySAS = gsub("Brunei Darussalam", "Brunei", CountrySAS),
         CountrySAS = gsub("Cabo Verde", "Cape Verde", CountrySAS),
         CountrySAS = gsub("Timor-Leste", "East Timor", CountrySAS),
         CountrySAS = gsub("Democratic People\'s Republic of Korea", "Korea, North", CountrySAS),
         CountrySAS = gsub("Republic of Korea", "Korea, South", CountrySAS),
         CountrySAS = gsub("Côte d'Ivoire", "Ivory Coast", CountrySAS),
         CountrySAS = gsub("Lao People's Democratic Republic", "Laos", CountrySAS),
         CountrySAS = gsub("Syrian Arab Republic", "Syria", CountrySAS),
         CountrySAS = gsub("Trinidad and Tobago", "Trinidad & Tobago", CountrySAS),
         CountrySAS = gsub("United Kingdom.*", "United Kingdom", CountrySAS),
         CountrySAS = gsub("Viet Nam", "Vietnam", CountrySAS)) %>%
  select(-publishstate, -sex)

gini2 <- gini %>%
  mutate(CountrySAS = country,
         CountrySAS = gsub("Venezuela, RB", "Venezuela", CountrySAS),
         CountrySAS = gsub("Iran, Islamic Rep.", "Iran", CountrySAS),
         CountrySAS = gsub("United Arab Emirates", "UAE", CountrySAS),
         CountrySAS = gsub("Brunei Darussalam", "Brunei", CountrySAS),
         CountrySAS = gsub("Cabo Verde", "Cape Verde", CountrySAS),
         CountrySAS = gsub("Timor-Leste", "East Timor", CountrySAS),
         CountrySAS = gsub("^Korea, Dem. People.+", "Korea, North", CountrySAS),
         CountrySAS = gsub("Korea, Rep.", "Korea, South", CountrySAS),
         CountrySAS = gsub("C.te d'Ivoire", "Ivory Coast", CountrySAS),
         CountrySAS = gsub("Lao PDR", "Laos", CountrySAS),
         CountrySAS = gsub("Syrian Arab Republic", "Syria", CountrySAS),
         CountrySAS = gsub("Trinidad and Tobago", "Trinidad & Tobago", CountrySAS),
         CountrySAS = gsub("United States", "United States of America", CountrySAS),
         CountrySAS = gsub("Russian Federation", "Russia", CountrySAS),
         CountrySAS = gsub("Egypt, Arab Rep.", "Egypt", CountrySAS))

sort(unique(sas_df2$Country)[!unique(sas_df2$Country) %in% unique(gini2$CountrySAS)])
sort(unique(gini2$country))



total_deaths  %>%
  filter(!is.na(Both)) %>%
  ggplot(aes(x = Both, y = CountrySAS, label = Country, colour = region))  +
  geom_text(size = 2) 

total_deaths %>%
  filter(!is.na(Both)) %>%
  dplyr::select(Country, Suicide, Homicide) %>%
  gather(cause, value, -Country) %>%
  ggplot(aes(weight = value, x = Country, fill = cause)) +
  geom_bar(position = "stack") +
  coord_flip() +
  labs(x = "", y = "Deaths per 100,000") +
  theme(axis.text.y = element_text(size = 6))




combined <- total_deaths %>%
  dplyr::select(CountrySAS, Suicide, Homicide, Both, Pop2005) %>%
  right_join(sas_df2, by = c("CountrySAS" = "Country")) %>%
  rename(GNI = `GNI (2005$) per capita`) %>%
  mutate(PopCorrectedFirearms = `Average total all civilian firearms`/ Pop2005 * 100)


combined %>%
  ggplot(aes(x = OriginalAverageFirearms, y = PopCorrectedFirearms, label = CountrySAS)) +
  geom_text() +
  scale_x_log10() +
  scale_y_log10()


ggplot(combined, aes(x = OriginalPopulation2005, y = Pop2005, label = CountrySAS)) +
  geom_text() +
  scale_x_log10() +
  scale_y_log10()

# countries with guns info that can't be merged:
sas_df2$Country[!sas_df2$Country %in% total_deaths$CountrySAS] 
sort(as.character(total_deaths$Country))




#============all the below should be moved into an analysis script once the data shape is stabilised========
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
