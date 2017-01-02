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
targetyear <- 2012

#----------WHO data------------------
# codes <- get_codes()
# dim(codes) # 2230 codes
# codes[grepl("omicide", codes$display), ]
# View(codes[grepl("opulation", codes$display), ])
# VIOLENCE_HOMICIDERATE  # per 100,000
# MH_12 # age standardised per 100,000
# SDGSUICIDE # crude  per 100,000
suicide_crude <- get_data("SDGSUICIDE")
homicide_crude <- get_data("VIOLENCE_HOMICIDERATE")
homicide_crude$sex <- "Both sexes"
pop <- get_data("WHS9_86")

expect_equal(unique(homicide_crude$year), targetyear)

who_ind <- rbind(suicide_crude, homicide_crude) %>%
  mutate(value = as.numeric(value))  %>%
  filter(sex == "Both sexes") %>%
  select(-publishstate, -sex) %>%
  mutate(cause = ifelse(grepl("suicide", gho), "Suicide", "Homicide")) %>%
  dplyr::select(-gho) %>%
  spread(cause, value) %>%
  mutate(HomicideAndSuicide = Homicide + Suicide) %>%
  left_join(filter(pop, year == 2005)[ , c("country", "value")], by = "country") %>%
  # drop regional variables, we only want individual countries:
  filter(!is.na(country)) %>%
  rename(Pop2005 = value) %>%
  mutate(Pop2005 =  Pop2005 * 1000) %>%
  mutate(country = gsub("C.te d'Ivoire", "Cote d'Ivoire", country)) %>%
  left_join(ISO3166, by = c("country" = "Name"))

#-----------World Bank data-----------------
# WDIsearch("gini")
# WDIsearch("GNI")
# [35,] "NY.GNP.PCAP.PP.CD"        "GNI per capita, PPP (current international $)" 

gini_orig <- WDI(indicator = "SI.POV.GINI", start = 2000, end = 2016)
gnp_orig <- WDI(indicator = "NY.GNP.PCAP.PP.CD", start = 2000, end = 2016)

gini <- gini_orig %>%
  rename(value = SI.POV.GINI) %>%
  filter(!is.na(value)) %>%
  filter(year %in% 2000:2016) %>%
  # find year closest to 2012
  mutate(yearout = abs(year - targetyear)) %>%
  group_by(iso2c) %>%
  summarise(giniyear = year[yearout == min(yearout)][1],
            gini = value[year == giniyear])

gnp <- gnp_orig %>%
  rename(value = NY.GNP.PCAP.PP.CD) %>%
  filter(!is.na(value)) %>%
  filter(year %in% 2000:2016) %>%
  # find year closest to 2012
  mutate(yearout = abs(year - targetyear)) %>%
  group_by(iso2c) %>%
  summarise(gnpyear = year[yearout == min(yearout)][1],
            GNPPerCapitaPPP = value[year == gnpyear])


#---------------UNDP HDI-----------
hdi2012 <- hdi %>%
  filter(year == targetyear) %>%
  select(Alpha_2, HDI)

#--------------combine all together----------------
indicators2012 <- who_ind %>%
  select(-year) %>%
  left_join(gini, by = c("Alpha_2" = "iso2c")) %>%
  left_join(gnp, by = c("Alpha_2" = "iso2c")) %>%
  left_join(sas_df2[ , c("Average total all civilian firearms", "Alpha_2")], by = "Alpha_2") %>%
  mutate(FirearmsPer100People2005 = `Average total all civilian firearms` / Pop2005 * 100) %>%
  left_join(hdi2012, by = "Alpha_2")  %>%
  mutate(rich = HDI > 0.87) 

save(indicators2012, file = "data/indicators2012.rda")




