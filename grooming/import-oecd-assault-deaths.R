# originally based on see http://ellisp.github.io/blog/2015/11/26/violent-deaths


#----------Import and mung the death from assault data---------------
# load deaths by assault from OECD.Stat
if(!exists("assaults_deaths_sdmx")){
  myUrl <- "http://stats.oecd.org/restsdmx/sdmx.ashx/GetData/HEALTH_STAT/CICDHOCD.TXCMFETF+TXCMHOTH+TXCMILTX.AUS+AUT+BEL+CAN+CHL+CZE+DNK+EST+FIN+FRA+DEU+GRC+HUN+ISL+IRL+ISR+ITA+JPN+KOR+LUX+MEX+NLD+NZL+NOR+POL+PRT+SVK+SVN+ESP+SWE+CHE+TUR+GBR+USA+NMEC+BRA+CHN+COL+CRI+IND+IDN+LVA+LTU+RUS+ZAF/all?startTime=1960&endTime=2018"
  dataset <- readSDMX(myUrl) 
  assaults_deaths_sdmx <- as.data.frame(dataset) 
}


# mung:
oecd_assaults <- assaults_deaths_sdmx %>%
  # match country codes to country names:
  left_join(ISO_3166_1[ , c("Name", "Alpha_3", "Alpha_2")], by = c("COU" = "Alpha_3")) %>%
  # more friendly names:
  rename(Country = Name,
         Year = obsTime,
         Value = obsValue) %>%
  # limit to columns we want:
  select(UNIT, Country, Year, Value, Alpha_2) %>%
  # make graphics-friendly versions of Unit and Year variables:
  mutate(Unit = ifelse(UNIT == "TXCMILTX", 
                       "Deaths per 100 000 population", "Deaths per 100 000 males"),
         Unit = ifelse(UNIT == "TXCMFETF", "Deaths per 100 000 females", Unit),
         Unit = factor(Unit, levels = 
                         c("Deaths per 100 000 females",    "Deaths per 100 000 population", "Deaths per 100 000 males")),
         Year = as.numeric(Year)) %>%
  # not enough data for Turkey to be useful so we knock it out:
  filter(Country != "Turkey") %>%
  as_tibble()

# create country x Unit summaries since 1990
oecd_assaults_sum <- oecd_assaults %>%
  filter(Year > 1990) %>%
  group_by(Country, Unit, Alpha_2) %>%
  summarise(Value = mean(Value)) %>%
  ungroup() %>%
  mutate(Unit = as.character(Unit),
         Unit = ifelse(grepl("female", Unit), "Female", Unit),
         Unit = ifelse(grepl(" males", Unit), "Male", Unit),
         Unit = ifelse(grepl("population", Unit), "Population", Unit)) %>%
  spread(Unit, Value) %>%
  arrange(Female) %>%
  mutate(Country = factor(Country, levels = Country))

save(oecd_assaults, file = "data/oecd_assaults.rda")
save(oecd_assaults_sum, file = "data/oecd_assaults_sum.rda")
