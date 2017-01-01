

hdi_orig <- read.xlsx("raw_data/2015_statistical_annex_tables_all.xlsx",
                 sheet = "Table 2", startRow = 7, rows = 7:199, cols = 1:15)

names(hdi_orig)[1:2] <- c("HDIRank2014", "Country")
hdi <- hdi_orig %>%
  filter(!is.na(HDIRank2014)) %>%
  gather(year, HDI, -HDIRank2014, -Country) %>%
  mutate(HDI = as.numeric(HDI),
         year = as.numeric(year)) %>%
  left_join(ISO3166, by = c("Country" = "Name"))

save(hdi, file = "data/hdi.rda")
