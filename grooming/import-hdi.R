

hdi_orig <- read_csv("raw_data/Human development index (HDI).csv", skip = 1)

names(hdi_orig)[1] <- "HDIRank2014"
hdi <- hdi_orig %>%
  filter(!is.na(HDIRank2014)) %>%
  mutate(Country = gsub("C.+te d'Ivoire", "Cote d'Ivoire", Country)) %>%
  gather(year, HDI, -HDIRank2014, -Country) %>%
  mutate(HDI = as.numeric(HDI),
         year = as.numeric(year)) %>%
  filter(!is.na(HDI)) %>%
  left_join(ISO3166, by = c("Country" = "Name"))


expect_equal(hdi %>% filter(is.na(Alpha_2)) %>% nrow(), 0)
save(hdi, file = "data/hdi.rda")
