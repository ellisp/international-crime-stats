library(rsdmx)
url <- "http://stats.oecd.org/restsdmx/sdmx.ashx/GetData/HEALTH_STAT/CICDHARM.TXCRUDTX+TXCMILTX.AUS+AUT+BEL+CAN+CHL+CZE+DNK+EST+FIN+FRA+DEU+GRC+HUN+ISL+IRL+ISR+ITA+JPN+KOR+LVA+LUX+MEX+NLD+NZL+NOR+POL+PRT+SVK+SVN+ESP+SWE+CHE+TUR+GBR+USA+NMEC+BRA+CHN+COL+CRI+IND+IDN+LTU+RUS+ZAF/all?startTime=2000&endTime=2015"

# Deaths per 100,000 population, crude and standardise
if(!exists("suic_sdmx")){
  dataset <- readSDMX(url) 
  suic_sdmx <- as.data.frame(dataset) # takes about 10 seconds on an i5
}

suicide <- suic_sdmx %>%
  mutate(variable = ifelse(UNIT == "TXCRUDTX", "Crude", "Standardised")) %>%
  rename(year = obsTime, Suicide = obsValue) %>%
  select(year, COU, Suicide, variable) %>%
  left_join(distinct(ISO3166[ , c("Alpha_3", "Alpha_2")]), by = c("COU" = "Alpha_3"))

save(suicide, file = "data/suicide.rda")
