# Prepares versions of international indicators such as GNI, GINI, suicides, homicides
# Aim is to have a single cross-section data, as close to 2012 as possible.

# Needs:
# * ISO3166, downloaded in .Rprofile
# * sas_df2, created in grooming/download-small-arms-survey-2007.R
# * hdi, created in grooming/import-hdi.R

library(WHO)
library(WDI)

# 2012 is chosen because target variable is suicide or homicide and that's the year
# data are available from the WHO
targetyear <- 2005

#----------WHO data------------------
pop <- get_data("WHS9_86")
alcohol <- get_data("WHOSIS_000011")

who_ind <- pop %>%
  filter(year == 2005) %>%
  # drop regional variables, we only want individual countries:
  filter(!is.na(country)) %>%
  dplyr::select(-gho, -publishstate, -year) %>%
  rename(Pop2005 = value) %>%
  mutate(Pop2005 =  Pop2005 * 1000) %>%
  left_join(alcohol[ , c("country", "value")], by = "country") %>%
  rename(Alcohol = value) %>%
  mutate(Alcohol = ifelse(Alcohol == "<0.1", 0, as.numeric(Alcohol))) %>%
  mutate(country = gsub("C.te d'Ivoire", "Cote d'Ivoire", country)) %>%
  left_join(ISO3166, by = c("country" = "Name"))

#---------OECD data--------------
# select just the target year for suicide and standardised values only
suicide_ty <- suicide %>%
  filter(year == targetyear & variable != "Deaths per 100 000 population (crude rates)") %>%
  select(-COU, -year) %>%
  mutate(variable = ifelse(grepl(" female", variable), "FemaleSuicide", variable),
         variable = ifelse(grepl(" male", variable), "MaleSuicide", variable),
         variable = ifelse(grepl("population", variable), "Suicide", variable))  %>%
  spread(variable, value)

#-----------World Bank data-----------------
# WDIsearch("gini")
# WDIsearch("GNI")
# WDIsearch("suicide") # no results
# [35,] "NY.GNP.PCAP.PP.CD"        "GNI per capita, PPP (current international $)" 

gini_orig <- WDI(indicator = "SI.POV.GINI", start = 2000, end = 2016)
gnp_orig <- WDI(indicator = "NY.GNP.PCAP.PP.CD", start = 2000, end = 2016)
homicide_orig <- WDI(indicator = "VC.IHR.PSRC.P5", start = 2000, end = 2016)

gini <- gini_orig %>%
  rename(value = SI.POV.GINI) %>%
  filter(!is.na(value)) %>%
  filter(year %in% 2000:2016) %>%
  # find year closest to target year
  mutate(yearout = abs(year - targetyear)) %>%
  group_by(iso2c) %>%
  summarise(giniyear = year[yearout == min(yearout)][1],
            gini = value[year == giniyear])

gnp <- gnp_orig %>%
  rename(value = NY.GNP.PCAP.PP.CD) %>%
  filter(!is.na(value)) %>%
  filter(year %in% 2000:2016) %>%
  # find year closest to target year
  mutate(yearout = abs(year - targetyear)) %>%
  group_by(iso2c) %>%
  summarise(gnpyear = year[yearout == min(yearout)][1],
            GNPPerCapitaPPP = value[year == gnpyear])


homicide <- homicide_orig %>%
  rename(value = VC.IHR.PSRC.P5) %>%
  filter(!is.na(value)) %>%
  filter(year %in% 2000:2016) %>%
  # find year closest to target year
  mutate(yearout = abs(year - targetyear)) %>%
  group_by(iso2c) %>%
  summarise(homicideyear = year[yearout == min(yearout)][1],
            Homicide = value[year == homicideyear])

#---------------UNDP HDI-----------
hdi2005 <- hdi %>%
  filter(year %in% c(2000, 2010)) %>%
  group_by(Alpha_2) %>%
  summarise(HDI = mean(HDI, na.rm = TRUE)) # some don't have 2000 values

#--------------combine all together----------------
indicators2005 <- who_ind %>%
  left_join(suicide_ty, by = "Alpha_2") %>%
  left_join(gini, by = c("Alpha_2" = "iso2c")) %>%
  left_join(gnp, by = c("Alpha_2" = "iso2c")) %>%
  left_join(homicide, by = c("Alpha_2" = "iso2c")) %>%
  left_join(sas_df2[ , c("Average total all civilian firearms", "Alpha_2")], by = "Alpha_2") %>%
  mutate(FirearmsPer100People2005 = `Average total all civilian firearms` / Pop2005 * 100) %>%
  left_join(hdi2005, by = "Alpha_2")  %>%
  mutate(rich = HDI > 0.845) %>%
  mutate(worldbankincomegroup = factor(worldbankincomegroup, levels =
                                         c("Low-income", "Lower-middle-income", "Upper-middle-income", "High-income")))

save(indicators2005, file = "data/indicators2005.rda")




